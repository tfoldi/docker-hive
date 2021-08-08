FROM openjdk:8u212-jre

ARG HADOOP_VERSION=3.3.1
ARG HIVE_VERSION=3.1.2
ARG SPARK_VERSION=3.1.2

WORKDIR /opt


ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-${HIVE_VERSION}-bin
ENV SPARK_HOME=/opt/spark-${SPARK_VERSION}-bin-hadoop3.2

ENV HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.901.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-${HADOOP_VERSION}.jar

RUN curl -L https://mirrors.ocf.berkeley.edu/apache/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz | tar zxf - && \
    curl -L https://downloads.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz | tar zxf - && \
    curl -L https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    rm -f ${HIVE_HOME}/lib/guava-*jar && \
    cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-*jar ${HIVE_HOME}/lib/

COPY conf/hive-site.xml ${HIVE_HOME}/conf

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    apt update && \
    apt install -y procps net-tools vim

#USER hive
WORKDIR $HIVE_HOME
EXPOSE 9083

ENTRYPOINT ["bin/hive"]
CMD ["--service", "metastore"]

#./hive --service hiveserver2 --hiveconf hive.server2.thrift.port=10000 --hiveconf hive.root.logger=INFO,console --hiveconf hive.execution.engine=spark

# export SPARK_DIST_CLASSPATH=$(/opt/hadoop-3.3.1/bin/hadoop classpath)