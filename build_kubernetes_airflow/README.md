# Spark on Kubernetes (Airflow Job Scheduling)


### Overview : Job Execution

Below is deatail about how the project automate Spark Job execution with an on demand Spark Cluster.

- You have a Storage minifest file which creates 3 Kubernetes Persistent Volumes.
	* Airflow history volume, this will save database, logs and DAG's for container failure recovery.
	* Spark History volume, this volume will be mounted on any Spark Cluster node, this will store event logs of all Spark Application in any cluster. This volume will also be mounted on History Server to visualize history.
	* Application volume, this contains the DAG, build script for cluster creation and deletion and also you application (in our sample it is the most simplest PySpark job ever). This will be mounted on the Airflow container for it to trigger the DAG. ***NOTE*** Since i am running Minikube i can mount my local volume in container with [hostPath](https://kubernetes.io/docs/setup/learning-environment/minikube/#persistent-volumes) . This feature will not be available in your Multinode Kubernetes cluster, thus you may need to find a way to load application and deployment script in your Airflow container(Init Container). 

- You have a Airflow manifest, containing below resources.
	* Deployment Controller of a single replica Airflow container. 
	* Airflow UI service exposed as a Nodeport. ***NOTE*** For your Multinode Kubernetes cluster choose Ingress.
	* Spark Application Driver port. Note the DAG has a Spark job in client mode thus the Airflow container will host the job driver, this need to expose its port to workers. This is exposed as ClusterIP as no external expose required.
	* Spark BlockManagerMaster port, exposed as a service. This is exposed as ClusterIP as no external expose required.

- You have a History Server manifest, containing below resources.
	* An Spark History Server Pod defination.
	* History Server UI exposed as a service with Nodeport to have external access.

- Now in you application folder you have a Airflow DAG, which has below stages.
	* Cluster creation, this is done by calling Kubernetes API. This deploys one Spark Master and one Spark Worker, also expose Spark Master UI port via Nodeport. Note Worker Deployment can be upscaled on need.
	* Airflow Connection creation, as you need a Airflow Spark Cluster connection to run Spark Operator.
	* Spark job launched via SparkSubmitOperator, Client mode is selected to allow driver can be hosted on the Airflow container.
	* Once job completes Airflow Spark connection is deleted and Spark Cluster is deleted.

- It also has the Cluster creation scripts.

- Your application that will be lanched by the Spark Submit.



### Overview : Directory and Files

- Utility script to perform deployments and view service exposure. Use 'help' to view options.

- Storage deployment descriptor to deploy Persistent Volumes.

- Airflow deployment descriptor to deploy Airflow.

- History deployment descriptor to deploy Spark History Server to view job history.

- VOLUME folder is your persistent volume home for job.

- VOLUME/history/spark is your persistent volume home for Spark history.

- VOLUME/history/airflow is your persistent volume home for Airflow history.

- VOLUME/apps is your persistent volume home for job artifacts.




### Customise : Run your application (Python)

Now i have provided the most simplest PySpark job ever (not coincidental, wanted to prove the most complex things have simplest stuff at its core ... :D:D:D ), obviously it will serve no purpose for you. You would like to run your own job, how you do it is explained below.

- Name your main application job file as app.py and place in VOLUME/apps.

- Pack all your dependency module as zip and place in VOLUME/apps directory.

- Add a "py_files=<YOUR ZIP NAME>" paramter in your SparkSubmitOperator.

```

spark_application = SparkSubmitOperator(
    task_id='spark_application',
    dag=dag,
    conn_id='spark_remote',
    conf={ 'spark.driver.host': host_ip },
    py_files='/apps/job_dependency.zip',
    application='/apps/app.py'
)

```

### Customise : Run your application (Java)

To execute Java jobs follow on.

- Place your jar in VOLUME/apps directory.

- Add 'java_class=<Your Class>' and 'application=<PATH to JAR>' paramter in your SparkSubmitOperator.

```

spark_application = SparkSubmitOperator(
    task_id='spark_application',
    dag=dag,
    conn_id='spark_remote',
    conf={ 'spark.driver.host': host_ip },
    java_class='your.package.Class',
    application='/apps/app.jar'
)

```



### Customise : Run interactive notebook (Zeppelin) - To be completed


### Customise : Run on Kubernetes Cluster - To be completed





