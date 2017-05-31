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

> hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.3.jar wordcount /input/README.txt /output/wordcounts
