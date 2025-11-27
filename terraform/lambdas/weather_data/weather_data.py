import boto3
import json
import os

SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
sns_client = boto3.client("sns")

def handler(event, context):
    print("Received event:", event)

    data = {
        "id": 123,
        "status": "processed",
        "message": "API data pulled successfully"
    }

    sns_client.publish(
        TopicArn=SNS_TOPIC_ARN,
        Message=json.dumps(data)
    )
    
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Event published to SNS"})
    }
