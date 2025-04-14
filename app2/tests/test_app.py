import unittest
from unittest.mock import patch, MagicMock
import os
import json

# Mock the environment variables before importing app
os.environ['QUEUE_URL'] = 'test-queue-url'
os.environ['BUCKET_NAME'] = 'test-bucket'

# Import only the process_message function from app, not the whole app
# to prevent the continuous polling loop from starting
from app import process_message

class Testapp2(unittest.TestCase):
    """Test suite for the message processing functionality of app 2."""
    
    @patch('app.s3.put_object')
    @patch('app.sqs.delete_message')
    def test_successful_message_processing(self, mock_delete, mock_put):
        """
        Test the happy path scenario where a message is successfully:
        1. Stored in S3
        2. Deleted from the queue
        """
        # Create a test message
        test_message = {
            'Body': '{"key": "value"}',
            'ReceiptHandle': 'handle1',
            'MessageId': 'test-message-id'
        }
        
        # Configure mocks
        mock_put.return_value = {}
        mock_delete.return_value = {}

        # Call the function we're testing
        result = process_message(test_message)

        # Verify the result and mock calls
        self.assertTrue(result)
        mock_put.assert_called_once()
        self.assertEqual(mock_put.call_args[1]['Body'], '{"key": "value"}')
        self.assertEqual(mock_put.call_args[1]['Bucket'], 'test-bucket')
        
        mock_delete.assert_called_once_with(
            QueueUrl='test-queue-url',
            ReceiptHandle='handle1'
        )
    
    @patch('app.s3.put_object')
    @patch('app.sqs.delete_message')
    def test_s3_upload_error(self, mock_delete, mock_put):
        """
        Test error handling when S3 upload fails:
        1. The message should not be deleted from the queue
        2. The function should return False
        """
        # Create a test message
        test_message = {
            'Body': '{"key": "value"}',
            'ReceiptHandle': 'handle1',
            'MessageId': 'test-message-id'
        }
        
        # Simulate S3 upload failure
        mock_put.side_effect = Exception("S3 upload failed")
        
        # Call the function we're testing
        result = process_message(test_message)
        
        # Verify the result
        self.assertFalse(result)
        mock_delete.assert_not_called()
        
    @patch('app.s3.put_object')
    @patch('app.sqs.delete_message')
    def test_non_json_message(self, mock_delete, mock_put):
        """
        Test handling non-JSON message body:
        1. The message should still be processed
        2. The raw body should be stored in S3
        """
        # Create a test message with non-JSON body
        test_message = {
            'Body': 'Plain text message',
            'ReceiptHandle': 'handle2',
            'MessageId': 'test-message-id'
        }
        
        # Configure mocks
        mock_put.return_value = {}
        mock_delete.return_value = {}

        # Call the function we're testing
        result = process_message(test_message)

        # Verify the result
        self.assertTrue(result)
        mock_put.assert_called_once()
        self.assertEqual(mock_put.call_args[1]['Body'], 'Plain text message')
