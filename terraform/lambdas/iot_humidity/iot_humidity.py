import boto3
import json
import math
import random
import os
from datetime import datetime
from confluent_kafka import Producer

SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
KAFKA_TOPIC = "humidity"
KAFKA_CONFIG = {
    "bootstrap.servers": os.environ.get("KAFKA_BOOTSTRAP_SERVER"),
    "security.protocol": "SASL_SSL",
    "sasl.mechanisms": "PLAIN",
    "sasl.username": os.environ.get("KAFKA_API_KEY"),
    "sasl.password": os.environ.get("KAFKA_API_SECRET"),
    "session.timeout.ms": 45000,
    "client.id": os.environ.get("KAFKA_CLIENT_ID")
}
F1_TRACKS = [
    "monaco", "silverstone", "monza", "spa", "suzuka",
    "hungaroring", "bahrain", "cota", "interlagos", "yas_marina"
]

sns_client = boto3.client("sns")
producer = Producer(KAFKA_CONFIG)  # Reuse producer across invocations


def simulate_humidity(track_name):
    now = datetime.utcnow()
    hour = now.hour
    base = 60
    amplitude = 20
    noise = 5
    humidity = base + amplitude * math.sin((hour / 24) * 2 * math.pi - math.pi / 2)
    humidity += random.uniform(-noise, noise)
    humidity = max(0, min(100, humidity))
    return {
        "datetime": now.isoformat(),
        "track": track_name,
        "humidity": round(humidity, 1)
    }

def produce_to_kafka(record, topic=KAFKA_TOPIC):
    producer.produce(
        topic,
        key=record["track"].encode("utf-8"),
        value=json.dumps(record).encode("utf-8")
    )

def handler(event, context):
    try:
        # Generate data for all tracks
        records = [simulate_humidity(track) for track in F1_TRACKS]

        # Send all tracks as a single SNS message
        sns_message = json.dumps(records)
        sns_client.publish(TopicArn=SNS_TOPIC_ARN, Message=sns_message)

        # Send each track as a separate Kafka message (JSON object)
        for record in records:
            produce_to_kafka(record)

        # Flush Kafka producer at the end
        producer.flush()

        return {
            "statusCode": 200,
            "body": json.dumps({"message": f"humidity data pushed to SNS and Kafka topic {KAFKA_TOPIC}"})
        }

    except Exception as e:
        print(e)
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
