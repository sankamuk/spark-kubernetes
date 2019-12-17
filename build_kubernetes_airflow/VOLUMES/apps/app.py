from pyspark import SparkConf
from pyspark import SparkContext

conf = SparkConf()
conf.setAppName('PySpark on Airflow')
sc = SparkContext(conf=conf)

rdd = sc.parallelize(range(10)).collect()
print rdd
