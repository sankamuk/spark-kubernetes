#!/bin/bash

if [ ! -f /root/airflow/airflow.db ] ; then
    airflow initdb
    mkdir -p /root/airflow/dags
    cp /apps/airflow_*py /root/airflow/dags/
fi

airflow scheduler &

sleep 10

airflow webserver 
