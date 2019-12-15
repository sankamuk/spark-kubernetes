# Spark on Kubernetes (Airflow Job Scheduling)


### Create Namespace

```
kubectl create namespace spark
```

### Create Service Account in Namespace

```
kubectl create serviceaccount sparkadmin -n spark
```

### Provide administration access to Service Account to Namespace

```
kubectl create rolebinding sparkRoleBinding --clusterrole=admin --serviceaccount=spark:sparkadmin --namespace=spark
```

### Get Access Token to programatically use Service Account

```
TOKENNAME=$(kubectl get serviceaccount sparkadmin -n spark -o jsonpath='{.secrets[0].name}')
TOKEN=$(kubectl get secret sparkadmin-token-n48dc -n spark -o jsonpath='{.data.token}' | base64 -D)
echo "${TOKEN}" > VOLUMES/app/sparkadmin.token
kubectl get secret sparkadmin-token-n48dc -n spark -o jsonpath='{.data.ca\.crt}' | base64 -D > VOLUMES/app/ca.crt
```

### Create Persistent Storage to host Spark Application defination and History

```
kubectl create -f storage.yml 

persistentvolume/airflow-volume created
persistentvolumeclaim/airflow-volume-claim created
persistentvolume/spark-history-volume created
persistentvolumeclaim/spark-history-volume-claim created
```

### Execute Airflow Instance 

```
kubectl create -f airflow.yml

pod/airflow created
service/airflow created
service/spark-client created
service/spark-client-bm created
```

### Define Spark Job as DAG
```
kubectl -n spark exec airflow cp /apps/airflow_spark_application_v1.py /root/airflow/dags/
```

### Execute DAG
```
kubectl -n spark exec airflow airflow unpause airflow_spark_application_v1
kubectl -n spark exec airflow airflow trigger_dag airflow_spark_application_v1
```



