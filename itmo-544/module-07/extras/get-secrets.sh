#!/bin/bash

DB_SECRET=$(aws secretsmanager get-secret-value \
    --secret-id SECRETNAME \
    --query SecretString \
    --output text)

DB_USER=$(echo $DB_SECRET | jq -r '.username')
DB_PASSWORD=$(echo $DB_SECRET | jq -r '.password')


