import boto3
import json
import os
import requests
from datetime import datetime

OPENWEATHERMAP_API_KEY = os.environ.get("OPENWEATHERMAP_API_KEY")
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")

sns_client = boto3.client("sns")

def handler(event, context):
    print("Received scheduled event:", event)

    # Construct the API URL for OpenWeatherMap
    url = f'https://api.openweathermap.org/data/2.5/weather?q=London,uk&APPID={OPENWEATHERMAP_API_KEY}'

    try:
        # 1. Fetch weather data from OpenWeatherMap API
        response = requests.get(url)
        response.raise_for_status()
        weather_data = response.json()
        message = {
            "status": "processed",
            "message": "Weather data pulled successfully",
            "data": weather_data
        }

        print(message)

        # 2. Publish to SNS
        sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=json.dumps(message.get("message", {}))
        )

        # 3. Push to Kafka (Confluent Cloud)

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "weather data pushed to SNS and Kafka"})
        }

    except requests.exceptions.HTTPError as e:
        print(f"HTTP error fetching OpenWeatherMap data: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Failed to fetch weather data"})
        }

    except Exception as e:
        print(f"Unexpected error: {e}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "An unexpected error occurred"})
        }
