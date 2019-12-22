# Sample Spark Job Runner with Airflow on Kubernetes

import socket
from builtins import range
from datetime import timedelta,datetime

import airflow
from airflow.models import DAG
from airflow.utils.trigger_rule import TriggerRule
from airflow.operators.bash_operator import BashOperator
from airflow.contrib.operators.spark_submit_operator import SparkSubmitOperator

# Collecting Host IP (used to identify Spark Client to Spark Executor)
host_name = socket.gethostname()
host_ip = socket.gethostbyname(host_name)

# DAG configuration
dag = DAG(
    dag_id='airflow_spark_application_v1',
    schedule_interval='0 0 * * *',
    start_date=datetime(2019, 12, 11),
    dagrun_timeout=timedelta(minutes=60),
    catchup=False
)

# Create Spark Cluster
cluster_create = BashOperator(
    task_id='cluster_create',
    bash_command="/apps/cluster.sh create ",
    dag=dag
)

# Wait for Cluster to Startup
cluster_start_wait = BashOperator(
    task_id='cluster_start_wait',
    bash_command="/apps/cluster.sh test ",
    dag=dag
)

# Execute Spark Job in Client Mode
spark_application = SparkSubmitOperator(
    task_id='spark_application',
    dag=dag,
    conn_id='spark_remote',
    conf={ 'spark.driver.host': host_ip },
    application='/apps/app.py'
)

# Delete Spark Cluster
cluster_delete = BashOperator(
    task_id='cluster_delete',
    bash_command="/apps/cluster.sh delete ",
    dag=dag
)

# Delete Spark Cluster on Failure
cluster_delete_onfailure = BashOperator(
    task_id='cluster_delete_onfailure',
    bash_command="/apps/cluster.sh delete ",
    trigger_rule=TriggerRule.ONE_FAILED,
    dag=dag
)

# DAG Task Ordering
cluster_create >> cluster_start_wait >> spark_application >> cluster_delete >> cluster_delete_onfailure
