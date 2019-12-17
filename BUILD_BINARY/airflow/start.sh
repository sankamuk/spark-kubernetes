#!/bin/bash

airflow initdb

airflow scheduler &

mkdir -p /root/airflow/dags
cp /apps/airflow_*py /root/airflow/dags/

sleep 15

airflow webserver 
