FROM ubuntu:16.04

MAINTAINER Abelit <ychenid@live.com>

# Add source
RUN echo "deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse" > /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list \
    && apt-get update

# Install ssh
RUN apt-get -y install openssh-server openssh-client

# SSH Key Passwordless
RUN ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa \
    && ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

RUN sed -i '/StrictHostKeyChecking/s/#//g' /etc/ssh/ssh_config \
    && sed -i '/StrictHostKeyChecking/s/ask/no/g' /etc/ssh/ssh_config \
    && sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config \
    && echo "UsePAM no" >> /etc/ssh/sshd_config

RUN mkdir -p /root/hadoop

# Install java
ADD jdk-8u112-linux-x64.tar.gz /root/hadoop/
#RUN tar -zxvf /root/hadoop/jdk-8u112-linux-x64.tar.gz -C /root/hadoop/ \
#    && rm -f /root/hadoop/jdk-8u112-linux-x64.tar.gz

# Install Hadoop
ADD hadoop-2.7.3.tar.gz /root/hadoop/
#RUN tar -zxvf /root/hadoop/hadoop-2.7.3.tar.gz -C /root/hadoop/ \
#    && rm -f /root/hadoop/hadoop-2.7.3.tar.gz

# Install Spark
# ADD spark-2.0.2-bin-hadoop2.7.tgz /root/hadoop/spark-2.0.2-bin-hadoop2.7.tgz
# RUN tar -zxvf /root/hadoop/spark-2.0.2-bin-hadoop2.7.tgz -C /root/hadoop/ \
#    && rm -f /root/hadoop/spark-2.0.2-bin-hadoop2.7.tgz

# Java Environment
ENV JAVA_HOME=/root/hadoop/jdk1.8.0_112
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPARH=$CLASSPATH:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV PATH=$PATH:${JAVA_HOME}/bin:${JRE_HOME}/bin

# Scala Environment
ENV SCALA_HOME=/root/hadoop/scala-2.11.8
ENV PATH=$PATH:${SCALA_HOME}/bin

# Hadoop Environment
ENV HADOOP_HOME=/root/hadoop/hadoop-2.7.3
ENV HADOOP_MAPRED_HOME=${HADOOP_HOME}/share/hadoop/mapreduce
ENV HADOOP_COMMON_HOME=${HADOOP_HOME}/share/hadoop/common
ENV HADOOP_HDFS_HOME=${HADOOP_HOME}/share/hadoop/hdfs
ENV HADOOP_YARN_HOME=${HADOOP_HOME}/share/hadoop/yarn
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV HDFS_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV YARN_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV PATH=$PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

# Spark Environment
ENV SPARK_HOME=/root/hadoop/spark-2.0.2-bin-hadoop2.7
ENV SPARK_CONF_DIR=${SPARK_HOME}/conf
ENV PATH=$PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

# Hive Environment
ENV HIVE_HOME=/root/hadoop/apache-hive-2.1.0-bin
ENV HIVE_CONF_DIR=${HIVE_HOME}/conf
ENV PATH=$PATH:${HIVE_HOME}/bin

# Mahout Environment
ENV MAHOUT_HOME=/root/hadoop/apache-mahout-distribution-0.12.2
ENV MAHOUT_CONF_DIR=${MAHOUT_HOME}/conf
ENV PATH=$PATH:${MAHOUT_HOME}/bin

# Hbase Environment
ENV HBASE_HOME=/root/hadoop/hbase-1.2.4
ENV HBASE_CONF_DIR=${HBASE_HOME}/conf
ENV PATH=$PATH:${HBASE_HOME}/bin

# Zookeeper Envirionment
ENV ZK_HOME=/root/hadoop/zookeeper-3.4.9
ENV ZK_CONF_DIR=${ZK_HOME}/conf
ENV PATH=$PATH:${ZK_HOME}/bin

# Pig Environment
ENV PIG_HOME=/root/hadoop/pig-0.16.0
ENV PIG_CLASSPATH=${HADOOP_HOME}/etc/hadoop
ENV PATH=$PATH:${PIG_HOME}/bin

# Sqoop Environment
ENV SQOOP_HOME=/root/hadoop/sqoop-1.99.7-bin-hadoop200
ENV SQOOP_CONF_DIR=${SQOOP_HOME}/conf
ENV SQOOP_SERVER_EXTRA_LIB=${SQOOP_HOME}/tools/lib
ENV PATH=$PATH:${SQOOP_HOME}/bin



WORKDIR /root/hadoop

#RUN service ssh start \
#    sed -i '/^exit.*/i\/etc/init.d/ssh start' /etc/rc.local

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000

# Mapred ports
EXPOSE 10020 19888

# Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088

# Other ports
RUN mkdir /var/run/sshd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
