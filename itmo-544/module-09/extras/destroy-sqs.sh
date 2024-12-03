#!/bin/bash

echo "*********************************************************************************************"
echo "Querying SQS URL now..." 
QUEUE_URL=$(aws sqs get-queue-url --queue-name ${24} --query 'QueueUrl' --output text)
echo "Queue URL: $QUEUE_URL"

echo "*********************************************************************************************"
echo "Deleting SQS Queue: $QUEUE_URL"
aws sqs delete-queue --queue-url "$QUEUE_URL"
echo "SQS Queue deleted successfully."

echo "*********************************************************************************************"
