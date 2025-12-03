import boto3
import json
import math
import random
import os
from datetime import datetime
from confluent_kafka import Producer

SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
KAFKA_TOPIC = "air_temperature"

KAFKA_CONFIG = {
    "bootstrap.servers": "pkc-ldvj1.ap-southeast-2.aws.confluent.cloud:9092",
    "security.protocol": "SASL_SSL",
    "sasl.mechanisms": "PLAIN",
    "sasl.username": "O72VPOFPHCCFUXU3",
    "sasl.password": "cfltKMGYgABXF37VSEtDGXFZIFgYJIQVnakP2K6tYreHi31ljwF0u4qdqDdtCGIg",
    "session.timeout.ms": 45000,
    "client.id": "ccloud-python-client-03d6e46f-f9f6-4270-b070-d0a2f3ef5af0"
}

sns_client = boto3.client("sns")
producer = Producer(KAFKA_CONFIG)  # Reuse producer across invocations

F1_TRACKS = [
    "monaco", "silverstone", "monza", "spa", "suzuka",
    "hungaroring", "bahrain", "cota", "interlagos", "yas_marina"
]

def simulate_air_temperature(track_name):
    now = datetime.utcnow()
    hour = now.hour
    base_temp = 25
    amplitude = 5
    noise_range = 1
    temp = base_temp + amplitude * math.sin((hour / 24) * 2 * math.pi - math.pi / 2)
    temp += random.uniform(-noise_range, noise_range)
    return {
        "datetime": now.isoformat(),
        "track": track_name,
        "air_temperature": round(temp, 1)
    }

def produce_to_kafka(record, topic=KAFKA_TOPIC):
    # Convert dict to JSON string and encode as bytes
    producer.produce(topic, key=str(record["track"]).encode("utf-8"), value=json.dumps(record).encode("utf-8"))

def handler(event, context):
    try:
        # Generate data for all tracks
        records = [simulate_air_temperature(track) for track in F1_TRACKS]

        # Send all tracks as a single SNS message
        sns_message = json.dumps(records)
        sns_client.publish(TopicArn=SNS_TOPIC_ARN, Message=sns_message)

        # Send each track as a separate Kafka message
        for record in records:
            produce_to_kafka(record)

        # Flush Kafka producer at the end
        producer.flush()

        return {
            "statusCode": 200,
            "body": json.dumps({"message": f"Air temperature data pushed to SNS and Kafka topic {KAFKA_TOPIC}"})
        }

    except Exception as e:
        print(e)
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
