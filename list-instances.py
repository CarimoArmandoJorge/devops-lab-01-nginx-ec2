#!/usr/bin/env python3
import boto3

REGION = "us-east-1"

def list_running_instances():
    ec2 = boto3.client("ec2", region_name=REGION)

    filters = [{"Name": "instance-state-name", "Values": ["running"]}]
    response = ec2.describe_instances(Filters=filters)

    count = 0
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            instance_id = instance["InstanceId"]
            instance_type = instance["InstanceType"]
            print(f"RUNNING - ID: {instance_id} | Type: {instance_type}")
            count += 1

    print(f"\nTotal running instances: {count}")

if __name__ == "__main__":
    list_running_instances()
