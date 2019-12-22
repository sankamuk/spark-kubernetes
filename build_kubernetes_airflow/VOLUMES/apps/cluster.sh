#!/bin/bash

cd /apps
if [ $1 == "create" ] ; then

  echo "Starting the deployment"

  # Getting Service Account credential
  TOKEN=$(< /secrets/token)
  NAMESPACE=$(< /secrets/namespace)

  # Deploy Spark Master
  curl -sSk --cacert /secrets/ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d@master_deployment.json https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/${NAMESPACE}/deployments

  # Deploy Master Service
  curl -sSk --cacert /secrets/ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d@service_deployment.json https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/${NAMESPACE}/services

  # Deploy Master UI Service 
  curl -sSk --cacert /secrets/ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d@service_ui_deployment.json https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/${NAMESPACE}/services

  # Deploy Worker
  curl -sSk --cacert /secrets/ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X POST -d@worker_deployment.json https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/${NAMESPACE}/deployments

  # Create Airflow Spark Connection Configuration
  airflow connections -a --conn_id 'spark_remote' --conn_type 'spark' --conn_host "spark://spark-master-__APP-ID__:7700" --conn_extra '{"deploy_mode": "client", "spark_home": "/sdh/spark2", "spark_binary": "/sdh/spark2/bin/spark-submit"}'

  echo "Completed deployment."

elif [ $1 == "delete" ] ; then

  echo "Deleteing the deployment"

  # Getting Service Account credential
  TOKEN=$(< /secrets/token)
  NAMESPACE=$(< /secrets/namespace)

  # UnDeploy Spark Master Service
  curl -sSk --cacert /secrets/ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X DELETE https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/${NAMESPACE}/services/spark-master-__APP-ID__

  # UnDeploy Master UI Service
  curl -sSk --cacert /secrets/ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X DELETE https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/${NAMESPACE}/services/spark-master-ui-__APP-ID__

  # UnDeploy Worker
  curl -sSk --cacert /secrets/ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X DELETE https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/${NAMESPACE}/deployments/spark-worker-__APP-ID__

  # UnDeploy Spark Master 
  curl -sSk --cacert /secrets/ca.crt -H "content-type: application/json" -H "Authorization: Bearer $TOKEN" -X DELETE https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/${NAMESPACE}/deployments/spark-__APP-ID__


  # Deleting Airflow Spark Connection
  airflow connections -d --conn_id 'spark_remote'

  echo "Completed deleting."

elif [ $1 == "test" ] ; then

  echo "Waiting for cluster start..."
  nc -vz spark-master-__APP-ID__ 7700
  is_up=$?
  count=1
  while [ ${is_up} -ne 0 -a ${count} -lt 5 ]
  do
    echo "Cluster didnot started yet, waiting for 5 seconds."
    sleep 5
    nc -vz spark-master-__APP-ID__ 7700
    is_up=$?
    count=$(expr $count + 1)
  done
  if [ $count -eq 5 ] 
  then
    echo "Cluster did not start."
    exit 1
  fi
  echo "Cluster started."

else

  echo "Wrong parameter passed."
  exit 1

fi
