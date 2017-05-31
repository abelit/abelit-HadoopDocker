# abelit-BigData

## Build hadoop image
> docker build -t "ubuntu:hadoop" .

## Run "hadoopcluster.sh"
> ./hadoopcluster.sh

## Initial hdfs when running hadoop firstly.
> hadoop namenode -format

## Start hadoop
> start-all.sh

## Create dirs based hdfs
> hadoop dfs -mkdir /input

> hadoop dfs -put README.txt /input

> hadoop dfs -ls /

## Run mapreduce job to count words
> hadoop jar hadoop-2.7.3/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.3.jar wordcount /input/README.txt /output/wordcounts


## Show resuts of mapreduce counting the words
> hadoop dfs -cat /output/wordcounts/part-r-00000
