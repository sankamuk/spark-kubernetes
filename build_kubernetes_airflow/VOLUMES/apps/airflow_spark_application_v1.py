import socket
from builtins import range
from datetime import timedelta,datetime

import airflow
from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.contrib.operators.spark_submit_operator import SparkSubmitOperator

host_name = socket.gethostname()
host_ip = socket.gethostbyname(host_name)

dag = DAG(
    dag_id='airflow_spark_application_v1',
    schedule_interval='0 0 * * *',
    start_date=datetime(2019, 12, 11),
    dagrun_timeout=timedelta(minutes=60),
    catchup=False
)

cluster_create = BashOperator(
    task_id='cluster_create',
    bash_command="/apps/cluster.sh create ",
    dag=dag
)

cluster_start_wait = BashOperator(
    task_id='cluster_start_wait',
    bash_command="/apps/cluster.sh test ",
    dag=dag
)

cluster_connection_create = BashOperator(
    task_id='cluster_connection_create',
    bash_command="/apps/cluster.sh connection_create ",
    dag=dag
)

spark_application = SparkSubmitOperator(
    task_id='spark_application',
    dag=dag,
    conn_id='spark_remote',
    conf={ 'spark.driver.host': host_ip },
    application='/apps/app.py'
)

cluster_connection_delete = BashOperator(
    task_id='cluster_connection_delete',
    bash_command="/apps/cluster.sh connection_delete ",
    dag=dag
)

cluster_delete = BashOperator(
    task_id='cluster_delete',
    bash_command="/apps/cluster.sh delete ",
    dag=dag
)

cluster_create >> cluster_start_wait >> cluster_connection_create >> spark_application >> cluster_connection_delete >> cluster_delete
