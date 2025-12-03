import json
import os
import requests  # Make sure 'requests' is available in your Lambda environment

SLACK_WEBHOOK_URL = os.environ.get("SLACK_WEBHOOK_URL")

def handler(event, context):
    for record in event.get('Records', []):
        message = record['body']

        # Prepare payload for Slack
        slack_payload = {
            "text": message
        }

        try:
            response = requests.post(
                SLACK_WEBHOOK_URL,
                data=json.dumps(slack_payload),
                headers={'Content-Type': 'application/json'}
            )
            response.raise_for_status()
            print(f"Sent message to Slack for record {record['messageId']}")
        except requests.exceptions.RequestException as e:
            print(f"Failed to send message to Slack for record {record['messageId']}: {e}")
    
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Notification/s sent to Slack"})
    }
