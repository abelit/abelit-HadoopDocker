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

RUN mkdir -p /root/bigdata

ENV JAVA_VERSION=1.8.0_112
ENV HADOOP_VERSION=2.7.3
ENV SPARK_VERSION=2.0.2

# Install Java
ADD ./packages/jdk-8u112-linux-x64.tar.gz /root/bigdata/
RUN ln -s /root/bigdata/jdk1.8.0_112 /root/bigdata/jdk

# Install Hadoop
ADD ./packages/hadoop-2.7.3.tar.gz /root/bigdata/
RUN ln -s /root/bigdata/hadoop-2.7.3 /root/bigdata/hadoop

# Install Spark
# ADD ./packages/spark-2.0.2-bin-hadoop2.7.tgz /root/bigdata/ \
#    && ln -s /root/bigdata/spark-2.0.2-bin-hadoop2.7 /root/bigdata/spark

# Java Environment
# ENV JAVA_HOME=/root/bigdata/jdk
# ENV JRE_HOME=${JAVA_HOME}/jre
# ENV CLASSPARH=$CLASSPATH:${JAVA_HOME}/lib:${JRE_HOME}/lib
# ENV PATH=$PATH:${JAVA_HOME}/bin:${JRE_HOME}/bin

# Hadoop Environment
# ENV HADOOP_HOME=/root/bigdata/hadoop
# ENV HADOOP_MAPRED_HOME=${HADOOP_HOME}/share/hadoop/mapreduce
# ENV HADOOP_COMMON_HOME=${HADOOP_HOME}/share/hadoop/common
# ENV HADOOP_HDFS_HOME=${HADOOP_HOME}/share/hadoop/hdfs
# ENV HADOOP_YARN_HOME=${HADOOP_HOME}/share/hadoop/yarn
# ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
# ENV HDFS_CONF_DIR=${HADOOP_HOME}/etc/hadoop
# ENV YARN_CONF_DIR=${HADOOP_HOME}/etc/hadoop
# ENV PATH=$PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin

WORKDIR /root/bigdata

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
