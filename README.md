# Spark on Kubernetes

Production ready Apache Spark runtime on Kubernetes.


## Features:
* Dynamic Infrastructure. Every job execution should easily setup the cluster before start and delete after job completion.
* Spark Standalone Cluster Manager.
* History events stored in Persistent Storage. History visible via a Spark History server in On-Demand basis.
* Support Airflow based Job Scheduling.


## Usage:

### Image Build

Execute build script to build Spark or Airflow(for Airflow based deployment model) image. Example below we build Spark image for spark namespace.

```
./build kube clean,stop,build spark spark
```

### Choose directory as per your deployment model.

- build_kubernetes_airflow -> Airflow scheduled Spark Jobs.
- build_kubernetes_manual -> Manual Setup Spark Infrastructure on Kubernetes. 
- build_local_docker -> Setup Spark Infrastructure over single node docker.



