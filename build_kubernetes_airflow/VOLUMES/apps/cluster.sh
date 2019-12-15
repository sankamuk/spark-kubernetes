#!/bin/bash

cd /apps
if [ $1 == "create" ] ; then

  echo "Starting the deployment"

  TOKEN=$(< sparkadmin.token)

  curl -sSk --cacert ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d@master_deployment.json https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/spark/deployments

  curl -sSk --cacert ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d@service_deployment.json https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/spark/services

  curl -sSk --cacert ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d@service_ui_deployment.json https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/spark/services

  curl -sSk --cacert ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d@worker_deployment.json https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/spark/deployments

  echo "Completed deployment."

elif [ $1 == "delete" ] ; then

  echo "Deleteing the deployment"

  TOKEN=$(< sparkadmin.token)

  curl -sSk --cacert ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X DELETE https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/spark/services/spark-master

  curl -sSk --cacert ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X DELETE https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/spark/services/spark-master-ui

  curl -sSk --cacert ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X DELETE https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/spark/deployments/spark-worker

  curl -sSk --cacert ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X DELETE https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/spark/deployments/spark

  echo "Completed deleting."

elif [ $1 == "test" ] ; then

  echo "Waiting for cluster start..."
  nc -vz spark-master 7700
  is_up=$?
  count=1
  while [ ${is_up} -ne 0 -a ${count} -lt 5 ]
  do
    echo "Cluster didnot started yet, waiting for 5 seconds."
    sleep 5
    nc -vz spark-master 7700
    is_up=$?
    count=$(expr $count + 1)
  done
  if [ $count -eq 5 ] 
  then
    echo "Cluster did not start."
    exit 1
  fi
  echo "Cluster started."

elif [ $1 == "connection_create" ] ; then

  echo "Creating cluster connection..."
  airflow connections -a --conn_id 'spark_remote' --conn_type 'spark' --conn_host "spark://spark-master:7700" --conn_extra '{"deploy_mode": "client", "spark_home": "/sdh/spark2", "spark_binary": "/sdh/spark2/bin/spark-submit"}'

elif [ $1 == "connection_delete" ] ; then

  echo "Deleting cluster connection..."
  airflow connections -d --conn_id 'spark_remote'

else

  echo "Wrong parameter passed."
  exit 1

fi