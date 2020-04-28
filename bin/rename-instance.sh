#!/usr/bin/env bash
id_doc=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document)
instance_id=$(echo $id_doc | jq -r .instanceId)
instance_region=$(echo $id_doc | jq -r .region)
tags=$(aws ec2 describe-tags --region $instance_region --filters "Name=resource-id,Values=$instance_id")
group=$(echo $instance_environment | jq -r '.Tags[] | select(.Key == "Group") | .Value')
env=$(echo $instance_environment | jq -r '.Tags[] | select(.Key == "Environment") | .Value')
name="$group-$env $instance_id"
aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=$name
