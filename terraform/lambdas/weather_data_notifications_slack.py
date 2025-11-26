import json
import boto3
import os

SLACK_WEBHOOK_URL = os.environ.get("SLACK_WEBHOOK_URL")

def handler(event, context):
    for record in event.get('Records', []):
        # just take the body as-is
        message = record['body']
        
        # use messageId as filename
        key = f"{record['messageId']}.json"
        
        print(f"Got record: {record['messageId']}")
    
    return {"status": "ok"}
