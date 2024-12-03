#!/bin/bash

# https://docs.aws.amazon.com/cli/latest/reference/sqs/get-queue-url.html

echo "*********************************************************************************************"
echo "Querying SQS URL now..." 
QUEUE_URL=$(aws sqs get-queue-url \
    --queue-name ${24} \
    --query 'QueueUrl' --output text)
echo "Queue URL: $QUEUE_URL"

echo "*********************************************************************************************"
echo "Querying SNS Topic ARN now..." 
TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, \`$TOPIC_NAME\`)].TopicArn | [0]" --output text)
echo "SNS Topic ARN: $TOPIC_ARN"

echo "*********************************************************************************************"
echo "Querying SQS ARN now..." 
QUEUE_ARN=$(aws sqs get-queue-attributes --queue-url "$QUEUE_URL" --attribute-names QueueArn --query "Attributes.QueueArn" --output text)
echo "SQS Queue ARN: $QUEUE_ARN"


echo "*********************************************************************************************"
echo "Querying Subscription ARN now..."
SUBSCRIPTION_ARN=$(aws sns subscribe --topic-arn "$TOPIC_ARN" --protocol sqs --notification-endpoint "$QUEUE_ARN" --query "SubscriptionArn" --output text)
if [ "$SUBSCRIPTION_ARN" == "None" ] || [ -z "$SUBSCRIPTION_ARN" ]; then
    echo "Error: Failed to subscribe SQS Queue to SNS Topic."
    exit 1
fi
echo "Subscription ARN: $SUBSCRIPTION_ARN"

POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "$QUEUE_ARN",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "$TOPIC_ARN"
        }
      }
    }
  ]
}
EOF
)


echo "*********************************************************************************************"
echo "Setting Queue attributes now..."
aws sqs set-queue-attributes --queue-url "$QUEUE_URL" --attributes "Policy=$POLICY"
echo "SQS Queue Policy updated to allow messages from SNS Topic."

echo "*********************************************************************************************"
echo "Subscription setup complete."
echo "*********************************************************************************************"