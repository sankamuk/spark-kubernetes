#!/bin/bash

airflow initdb

airflow scheduler &

mkdir -p /root/airflow/dags

sleep 10

airflow webserver 
