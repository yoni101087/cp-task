from flask import Flask, request, jsonify
import boto3
import os
import time
import json
from datetime import datetime
import logging
from threading import Thread
from botocore.exceptions import ClientError

app = Flask(__name__)

# Improve logging with timestamps and log level
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Environment variables with proper defaults
AWS_REGION = os.getenv('AWS_REGION', 'us-west-2')
QUEUE_URL = os.getenv('QUEUE_URL')
TOKEN_PARAM_NAME = os.getenv('TOKEN_PARAM_NAME')

# Validate required environment variables
if not QUEUE_URL:
    logger.error("QUEUE_URL environment variable is not set")
    raise ValueError("QUEUE_URL environment variable is required")
    
if not TOKEN_PARAM_NAME:
    logger.error("TOKEN_PARAM_NAME environment variable is not set")
    raise ValueError("TOKEN_PARAM_NAME environment variable is required")

# AWS SQS and SSM clients
sqs = boto3.client('sqs', region_name=AWS_REGION)
ssm = boto3.client('ssm', region_name=AWS_REGION)

def log_heartbeat():
    while True:
        logger.info("App is up and running...")
        time.sleep(10)

# Start the heartbeat logging in a separate thread
heartbeat_thread = Thread(target=log_heartbeat, daemon=True)
heartbeat_thread.start()

@app.route('/', methods=['POST'])
def process_request():
    logger.info("Processing request...")

    # Log the original client IP from the load balancer
    client_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    logger.info(f"Request received from client IP: {client_ip}")

    try:
        # Parse JSON payload
        if not request.is_json:
            logger.warning("Request payload is not JSON")
            return jsonify({'error': 'Request must be JSON'}), 400
            
        payload = request.json
        token = payload.get('token')
        data = payload.get('data')
        
        if not token or not data:
            logger.warning("Missing token or data in payload")
            return jsonify({'error': 'Missing token or data in request'}), 400

        try:
            # Validate token
            stored_token = ssm.get_parameter(Name=TOKEN_PARAM_NAME, WithDecryption=True)['Parameter']['Value']
            if token != stored_token:
                logger.warning("Invalid token provided.")
                return jsonify({'error': 'Invalid token'}), 401
        except ClientError as e:
            logger.error(f"Error retrieving token from SSM: {str(e)}")
            return jsonify({'error': 'Error validating authentication'}), 500

        # Validate required fields in data
        required_fields = ['email_subject', 'email_sender', 'email_timestream', 'email_content']
        missing_fields = [field for field in required_fields if field not in data]
        if missing_fields:
            logger.warning(f"Missing required fields: {', '.join(missing_fields)}")
            return jsonify({'error': f'Missing required fields: {", ".join(missing_fields)}'}), 400

        # Validate email_timestream
        email_timestream = data.get('email_timestream')
        try:
            # Ensure the timestamp is valid and not in the future
            email_timestamp = int(email_timestream)
            if email_timestamp > int(time.time()):
                logger.warning("email_timestream is in the future.")
                return jsonify({'error': 'email_timestream cannot be in the future'}), 400
        except (ValueError, TypeError):
            logger.warning("Invalid email_timestream format.")
            return jsonify({'error': 'Invalid email_timestream format'}), 400

        # Publish to SQS using proper JSON serialization
        try:
            sqs.send_message(
                QueueUrl=QUEUE_URL, 
                MessageBody=json.dumps(data)
            )
            logger.info("Message successfully published to SQS.")
            return jsonify({'message': 'Message published to SQS'}), 200
        except ClientError as e:
            logger.error(f"Failed to publish message to SQS: {str(e)}")
            return jsonify({'error': 'Failed to publish message'}), 500

    except Exception as e:
        logger.error(f"An unexpected error occurred: {str(e)}", exc_info=True)
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()}), 200

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port)