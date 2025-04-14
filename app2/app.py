import boto3
import os
import time
import logging
import json
import signal
import sys
from flask import Flask, jsonify
from botocore.exceptions import ClientError
from threading import Thread, Event

# Configure logging with timestamp and formatting
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Environment variables with proper validation
AWS_REGION = os.getenv('AWS_REGION', 'us-west-2')
QUEUE_URL = os.getenv('QUEUE_URL')
BUCKET_NAME = os.getenv('BUCKET_NAME')
PULL_INTERVAL = int(os.getenv('PULL_INTERVAL', 5))
MAX_RETRIES = int(os.getenv('MAX_RETRIES', 3))

# Exit if required environment variables are missing
missing_vars = []
if not QUEUE_URL:
    missing_vars.append("QUEUE_URL")
if not BUCKET_NAME:
    missing_vars.append("BUCKET_NAME")

if missing_vars:
    logger.error(f"Required environment variables not set: {', '.join(missing_vars)}")
    sys.exit(1)

# Create a session for connection pooling
session = boto3.session.Session(region_name=AWS_REGION)
sqs = session.client('sqs')
s3 = session.client('s3')

# Create Flask app
app = Flask(__name__)

# Event to signal graceful shutdown
shutdown_event = Event()

@app.route('/health', methods=['GET'])
def health_check():
    """Basic health check endpoint"""
    return jsonify({'status': 'healthy'}), 200

@app.route('/liveness', methods=['GET'])
def liveness_check():
    """More comprehensive liveness check that tests AWS connections"""
    try:
        # Test SQS connection
        sqs.get_queue_attributes(
            QueueUrl=QUEUE_URL,
            AttributeNames=['ApproximateNumberOfMessages']
        )
        
        # Test S3 connection
        s3.list_objects_v2(Bucket=BUCKET_NAME, MaxKeys=1)
        
        return jsonify({
            'status': 'alive',
            'connections': {
                'sqs': 'ok',
                's3': 'ok'
            }
        }), 200
    except ClientError as e:
        logger.error(f"Liveness check failed: {e}")
        return jsonify({
            'status': 'failing',
            'error': str(e)
        }), 500

def process_message(message):
    """Process a single SQS message"""
    try:
        body = message['Body']
        receipt_handle = message['ReceiptHandle']
        message_id = message.get('MessageId', 'unknown')
        
        logger.info(f"Processing message: {message_id}")
        
        # Parse JSON if the body is JSON
        try:
            parsed_body = json.loads(body)
            # Use the parsed body if needed
        except json.JSONDecodeError:
            logger.warning(f"Message {message_id} is not valid JSON, treating as raw text")
        
        # Upload to S3 with a more structured key
        s3_key = f"messages/{time.strftime('%Y/%m/%d/%H')}_{message_id}.json"
        
        s3.put_object(
            Bucket=BUCKET_NAME, 
            Key=s3_key, 
            Body=body,
            ContentType='application/json'
        )
        logger.info(f"Uploaded message {message_id} to S3 with key: {s3_key}")
        
        # Delete message from SQS
        sqs.delete_message(QueueUrl=QUEUE_URL, ReceiptHandle=receipt_handle)
        logger.info(f"Deleted message {message_id} from SQS")
        
        return True
    except ClientError as e:
        logger.error(f"AWS error processing message {message.get('MessageId', 'unknown')}: {e}")
        return False
    except Exception as e:
        logger.error(f"Unexpected error processing message {message.get('MessageId', 'unknown')}: {e}", exc_info=True)
        return False

def process_messages():
    """Main message processing loop with retry logic"""
    while not shutdown_event.is_set():
        try:
            logger.info("Polling messages from SQS queue...")
            response = sqs.receive_message(
                QueueUrl=QUEUE_URL, 
                MaxNumberOfMessages=10, 
                WaitTimeSeconds=10,
                AttributeNames=['All']
            )
            
            messages = response.get('Messages', [])
            if not messages:
                logger.info("No messages received from the queue.")
                # Exit immediately if in test mode to avoid infinite loop
                if os.getenv('TESTING') == 'True':
                    break
            else:
                logger.info(f"Received {len(messages)} messages from SQS")
                
                for message in messages:
                    retries = 0
                    success = False
                    
                    while not success and retries < MAX_RETRIES and not shutdown_event.is_set():
                        success = process_message(message)
                        if not success:
                            retries += 1
                            if retries < MAX_RETRIES:
                                backoff_time = 2 ** retries  # Exponential backoff
                                logger.info(f"Retrying message {message.get('MessageId', 'unknown')} in {backoff_time} seconds (attempt {retries+1}/{MAX_RETRIES})")
                                time.sleep(backoff_time)
                            else:
                                logger.error(f"Failed to process message {message.get('MessageId', 'unknown')} after {MAX_RETRIES} attempts")
                                # Could implement a dead-letter mechanism here
                                
        except ClientError as e:
            logger.error(f"AWS error polling SQS: {e}")
            if os.getenv('TESTING') == 'True':
                break
            time.sleep(PULL_INTERVAL)  # Wait before retrying
        except Exception as e:
            logger.error(f"Unexpected error in message processing loop: {e}", exc_info=True)
            if os.getenv('TESTING') == 'True':
                break
            time.sleep(PULL_INTERVAL)  # Wait before retrying
            
        if not shutdown_event.is_set():
            # Exit the loop if in test mode to prevent infinite loops
            if os.getenv('TESTING') == 'True':
                break
            time.sleep(PULL_INTERVAL)

def handle_shutdown(sig, frame):
    """Handle graceful shutdown on signals"""
    logger.info(f"Received signal {sig}, shutting down gracefully...")
    shutdown_event.set()

if __name__ == '__main__':
    # Register signal handlers for graceful shutdown
    signal.signal(signal.SIGINT, handle_shutdown)
    signal.signal(signal.SIGTERM, handle_shutdown)
    
    # Start message processing in a daemon thread
    message_thread = Thread(target=process_messages)
    message_thread.daemon = True
    message_thread.start()
    
    logger.info("Starting Flask application")
    # Using 0.0.0.0 to listen on all available network interfaces
    app.run(host='0.0.0.0', port=5001, threaded=True)
    
    # Wait for the message thread to finish when shutting down
    logger.info("Flask server stopped, waiting for message thread to finish...")
    shutdown_event.set()  # Ensure the event is set
    message_thread.join(timeout=30)  # Wait up to 30 seconds
    logger.info("Shutdown complete")