#!/bin/bash

set -e          # exit on command errors
set -o nounset  # abort on unbound variable
set -o pipefail # capture fail exit codes in piped commands

apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -y docker-ce

export EXTERNAL_LB="${EXTERNAL_LB}"

export LOCAL_IP=$(wget -qO- http://169.254.169.254/latest/meta-data/local-ipv4)

export INSTANCE_TYPE=$(wget -qO- http://169.254.169.254/latest/meta-data/instance-type)

export NODE_AZ=$(wget -qO- http://169.254.169.254/latest/meta-data/placement/availability-zone/)

export NODE_REGION=$(echo $NODE_AZ | sed 's/.$//')

export ENABLE_CLOUDWATCH_LOGS="${ENABLE_CLOUDWATCH_LOGS}"

export AWS_REGION="${AWS_REGION}"

export MANAGER_SECURITY_GROUP_ID="${MANAGER_SECURITY_GROUP_ID}"

export WORKER_SECURITY_GROUP_ID="${WORKER_SECURITY_GROUP_ID}"

export DYNAMODB_TABLE="${DYNAMODB_TABLE}"

export ACCOUNT_ID="${ACCOUNT_ID}"

export VPC_ID="${VPC_ID}"

export SWARM_QUEUE="${SWARM_QUEUE}"

export CLEANUP_QUEUE="${CLEANUP_QUEUE}"

export RUN_VACUUM="${RUN_VACUUM}"

export LOG_GROUP_NAME="${LOG_GROUP_NAME}"

export DOCKER_EXPERIMENTAL='false'

export NODE_TYPE='worker'

echo '{"experimental": '$DOCKER_EXPERIMENTAL', "labels":["os=linux", "region='$NODE_REGION'", "availability_zone='$NODE_AZ'", "instance_type='$INSTANCE_TYPE'", "node_type='$NODE_TYPE'"] ' > /etc/docker/daemon.json

if [ $ENABLE_CLOUDWATCH_LOGS == 'yes' ] ; then
   echo ', "log-driver": "awslogs", "log-opts": {"awslogs-group": "'$LOG_GROUP_NAME'", "tag": "{{.Name}}-{{.ID}}" }}' >> /etc/docker/daemon.json
else
   echo ' }' >> /etc/docker/daemon.json
fi

systemctl enable docker
systemctl restart docker

sleep 5

docker run \
  --log-driver=json-file \
  --restart=no \
  -d \
  -e DYNAMODB_TABLE=$DYNAMODB_TABLE \
  -e NODE_TYPE=$NODE_TYPE \
  -e REGION=$AWS_REGION \
  -e ACCOUNT_ID=$ACCOUNT_ID \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/log:/var/log \
  pecigonzalo/docker-init-aws

docker run \
  --log-driver=json-file \
  --name=guide-aws \
  --restart=always \
  -d \
  -e DYNAMODB_TABLE=$DYNAMODB_TABLE \
  -e NODE_TYPE=$NODE_TYPE \
  -e REGION=$AWS_REGION \
  -e VPC_ID=$VPC_ID \
  -e SWARM_QUEUE="$SWARM_QUEUE" \
  -e CLEANUP_QUEUE="$CLEANUP_QUEUE" \
  -e RUN_VACUUM=$RUN_VACUUM \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  pecigonzalo/docker-guide-aws

docker run \
  --log-driver=json-file \
  --name=status-aws \
  --restart=always \
  -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p $LOCAL_IP:44554:5000 \
  pecigonzalo/docker-status-aws


# Worker user data
