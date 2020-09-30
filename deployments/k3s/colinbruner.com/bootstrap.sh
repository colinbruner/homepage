#!/bin/bash

LOG_FILE="k3s_deployment.log"

echo "Starting deployment" > $LOG_FILE

echo "Creating homepage namespace"
kubectl apply -f homepage.json 2>&1 >> $LOG_FILE
echo "Creating service nodeports"
kubectl apply -f service.yaml 2>&1 >> $LOG_FILE
echo "Creating k3s deployment"
kubectl apply -f deploy.yaml 2>&1 >> $LOG_FILE 

echo "Deployment complete" >> $LOG_FILE
