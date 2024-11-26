#!/bin/bash

echo "Deleting db-instances now..."

aws rds delete-db-instance \
    --db-instance-identifier ${19} \
    --skip-final-snapshot


echo "Waiting for db-instances to be deleted..."

aws rds wait db-instance-deleted \
    --db-instance-identifier ${19}


echo "DB-Instances are deleted!!"