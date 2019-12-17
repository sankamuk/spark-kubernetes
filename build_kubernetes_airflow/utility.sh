#!/bin/bash

script_home="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${script_home}

usage(){
echo "Your need to pass one of the below option to perform below task."
echo "- deployairflow: Deploy your Airflow Instance."
echo "- deploystorage: Deploy all required persistent volumes."
echo "- deployhistory: Deploy History Server Instance to view Spark Jobs."
echo "- airflowui:     Check Airflow UI address."
echo "- sparkui:       Check Spark Master UI."
echo "- historyui:     Check Spark History Server UI."

}

case $1 in
deployairflow) kubectl create -f airflow.yml
               ;;;
deploystorage) kubectl create -f storage.yml
               ;;;
deployhistory) kubectl create -f history.yml
               ;;;
airflowui)     minikube service airflow-__APP-ID__ --url -n __APP-NAMESPACE__
               ;;;
sparkui)       minikube service spark-master-ui-__APP-ID__ --url -n __APP-NAMESPACE__
               ;;;
historyui)     minikube service history-__APP-ID__ --url -n __APP-NAMESPACE__
               ;;;
*)             usage
               ;;;
esac
