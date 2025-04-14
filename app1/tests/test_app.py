import unittest
from unittest.mock import patch, MagicMock
import os
import json

# Mock the environment variables before importing app
os.environ['QUEUE_URL'] = 'mock-queue-url'
os.environ['TOKEN_PARAM_NAME'] = 'mock-token-param'

# Now import the app after environment variables are set
from app import app

class Testapp1(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()
        # Configure the app for testing
        app.config['TESTING'] = True

    @patch('app.ssm.get_parameter')
    @patch('app.sqs.send_message')
    def test_token_validation(self, mock_sqs, mock_ssm):
        """
        Test that the API validates authentication tokens correctly.
        It should return 401 Unauthorized when an invalid token is provided.
        """
        # Mock the SSM parameter store response
        mock_ssm.return_value = {'Parameter': {'Value': 'valid-token'}}
        mock_sqs.return_value = {}

        response = self.client.post('/', json={
            'token': 'invalid-token',
            'data': {
                'email_subject': 'Test',
                'email_sender': 'test@example.com',
                'email_timestream': '1234567890',
                'email_content': 'Hello World'
            }
        })
        self.assertEqual(response.status_code, 401)
        self.assertIn('Invalid token', response.json.get('error', ''))

    @patch('app.ssm.get_parameter')
    @patch('app.sqs.send_message')
    def test_missing_fields(self, mock_sqs, mock_ssm):
        """
        Test that the API properly validates required fields in the request payload.
        It should return 400 Bad Request when required fields are missing.
        """
        # Mock the SSM parameter store response
        mock_ssm.return_value = {'Parameter': {'Value': 'valid-token'}}
        mock_sqs.return_value = {}

        response = self.client.post('/', json={
            'token': 'valid-token',
            'data': {'email_subject': 'Test'}
        })
        self.assertEqual(response.status_code, 400)
        self.assertIn('Missing required fields', response.json.get('error', ''))

    @patch('app.sqs.send_message')
    @patch('app.ssm.get_parameter')
    def test_sqs_message_publishing(self, mock_ssm, mock_sqs):
        """
        Test that the API successfully publishes messages to SQS when all
        required data is provided and the token is valid. It should return
        a 200 OK response on success.
        """
        mock_ssm.return_value = {'Parameter': {'Value': 'valid-token'}}
        mock_sqs.return_value = {}
        
        response = self.client.post('/', json={
            'token': 'valid-token',
            'data': {
                'email_subject': 'Test',
                'email_sender': 'test@example.com',
                'email_timestream': '1234567890',
                'email_content': 'Hello World'
            }
        })
        self.assertEqual(response.status_code, 200)
        mock_sqs.assert_called_once()
