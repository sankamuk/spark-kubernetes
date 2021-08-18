# Spark on Kubernetes

![Kubernetes](https://img.shields.io/badge/platform-Kubernetes-brightgreen.svg)
![Apache Spark](https://img.shields.io/badge/library-Spark-brightgreen.svg)
![Apache Airflow](https://img.shields.io/badge/scheduler-Airflow-brightgreen.svg)
![Shell](https://img.shields.io/badge/language-shell-brightgreen.svg)

Production ready Apache Spark runtime on Kubernetes.


- [Features](#features)
- [Project Detail](#project-detail)
- [Usage](#usage)
  * [Understanding the Build Tool](#understanding-the-build-tool)
  * [Check Prerequisite](#check-prerequisite)
  * [Run Build Tool](#run-build-tool)
  * [Deploy your Environment](#deploy-your-environment)
  * [Check your Job Status](#check-your-job-status)
  * [Run History Server your Spark Job Dashboard](#run-history-server-your-spark-job-dashboard)
  * [Delete your deployment](#delete-your-deployment)
- [Congigure Your Application](#configure-your-application)
- [Demo videos](#demo-videos)
- [TO DO](#to-do)


## Features:

* Dynamic Infrastructure. Every job execution should easily setup the cluster before start and delete after job completion.
* Spark Standalone Cluster Manager.
* History events stored in Persistent Storage. History visible via a Spark History server in On-Demand basis.
* Support Airflow based Job Scheduling.



## Project Detail:

- This project starts with prerequisite of a running Kubernetes cluster. 
- Here we have used Minikube (easily modifiable for any Kubernetes cluster).
- It deploys an Airflow instance with an single DAG (Spark Job) deployed.
- The DAG creates Spark Cluster, creates nessesory Airflow configurations, executes Spark Job and tear down the Spark Cluster.
- Airflow instance will act as the single instance running in the cluster. Note this project is by no mean aimed to show how to build a enterprise ready Airflow instance over Kubernetes so that all Spark Job can use the same Airlow instance. The aim is just to get the Airflow based orchestration going over Kubernetes for our Spark Job.
- A history server can be ran on demand to view status and monitor the Spark Jobs over time.



## Usage:

### Understanding the Build Tool

This projects key utility is the "Build Tool". It performs all nesesory setup for executing your job. But before you can use this you need to follow and check your environment detail in the "Check Prerequisite" section. Also you should provide the tool your Namespace (since deployments will be done on that specific Namespace) and Application Name.

Tool should be provided a list (comma separated) of action. Below provide details about the actions.

- ***clean***: This action cleans up the environment and all images from your Kubernetes cluster. Once executed before any deployment you need to execute the build and envconfig actions must be run.

- ***stop***: This stops any running instance of your environment. You will need to reploy you applications after this action.

- ***build***: This build all nessesory docker images for the project.

- ***envconfig***: This configures your Kubernetes cluster for the deployment. It creates Namespace, create Service Account and provides nessesory rights for deployments using the service account. Note you need to run this if you keep creating new applications (Spark Job Deployment) with the same project base.

- ***genconfig***: This creates a new application configuration to deploy a new Spark Job. Once you run this action you will have a sub directory in your project home with name of your application. Note you can generate multiple application configuration using the same project.

***Example***: To build, create kubernetes environment and then generate deployment artifiact for an Application named TST using a namespace SPK you should run the build tool as

```
./build -actions=build,envconfig,genconfig -namespace=SPK -appname=TST -runtime=kube
```


### Check Prerequisite

- Check you have bash installed as the script as BASH based.

```
$ ls -ltr /bin/bash
```

- Check you have minikube installed and kubectl present in your path.

```
$ which minikube


$ which kubectl

```

***NOTE***: Incase you are searching for documentation for installing Minikube, start [here](https://kubernetes.io/docs/tasks/tools/install-minikube/ "Minikube Install").

- Check your Minikube instance is running.

```
$ minikube status

host: Running
kubelet: Running
apiserver: Running
kubectl: Correctly Configured: pointing to minikube-vm at 192.168.99.100

```

- Before you start using it download the project.

```
$ jar xvf <(curl -sL https://github.com/sankamuk/spark-kubernetes/archive/master.zip)
```

***NOTE:*** This way fo download often remove files permssion, creates issue specially for the bash script and can render your job execution issue. Thus after you download you can just give give execution right to all your bash scripts.
```
$ find . -type f -name *.sh -exec chmod a+x '{}' \;
$ find . -type f -name build -exec chmod a+x '{}' \;
```

### Run Build Tool 

Lets build the images and set up our cluster to host our application ***test*** in a dedicated namespace ***spark***
 and generate all required deploument artifact.

```
$ ./build -actions=build,envconfig,genconfig -namespace=spark -appname=test -runtime=kube
```

***NOTE***: Your build process should take some time to build images. Once complete you should expect a folder names test in your project root directory.


### Deploy your Environment

- Deploy your persistent storage to publish your application in Airflow Executor and Spark History volume all over.

```
$ ./test/utility.sh deploystorage
``` 

- Deploy your Airflow instance which will orchestrate your Spark Job.

```
$ ./test/utility.sh deployairflow
```


### Check your Job Status

- Get your Airflow UI. 

```
$ ./test/utility.sh airflowui
```

- Enable disbale your DAG, trigger or let is run as per schedule from your Airflow UI. Also check your Job execution status and logs.


### Run History Server your Spark Job Dashboard

- Run History Server Instance

```
$ ./test/utility.sh deployhistory
```

- Check History Server UI

```
$ ./test/utility.sh historyui
```


### Delete your deployment

Once you are done you can clean up the whole setup using "Build Tool". Note here you should mention your application name and the Namespace where your application was deployed.

```
$ ./build -actions=stop,clean -namespace=spark -appname=test -runtime=kube

```



## Configure Your Application

For detail about how to configure the project to run your application you should read the README inside the build_kubernetes_airflow architecture folder. There you will find details about the kubernetes deployment artifact.



## Demo videos

* Environment Check - https://youtu.be/zvAUDvWUhHc
* Build - https://youtu.be/_oHNaCszRgs 		https://youtu.be/p86_qYBQH0M
* Deploy Your Job - https://youtu.be/Ec3LAEsqfvw
* Validate - https://youtu.be/gE61rOSI1p4		https://youtu.be/T0xjiXcGEGs
* Cleanup - https://youtu.be/T0xjiXcGEGs


## TO DO

- Log aggregation.
- Security evaluation.



