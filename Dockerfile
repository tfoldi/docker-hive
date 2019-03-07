FROM debian:9

WORKDIR /opt

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
ENV HADOOP_HOME=/opt/hadoop-2.9.2
ENV HIVE_HOME=/opt/apache-hive-2.3.4-bin

RUN apt-get update && \
    apt-get -y install curl openjdk-8-jre-headless && \
    curl -L https://www-us.apache.org/dist/hive/hive-2.3.4/apache-hive-2.3.4-bin.tar.gz | tar zxf - && \
    curl -L https://www-us.apache.org/dist/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz | tar zxf -

ADD hive-site.xml hive-log4j2.properties ${HIVE_HOME}/conf/

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME}

USER hive
WORKDIR $HIVE_HOME
EXPOSE 9083

ENTRYPOINT ["bin/hive"]
CMD ["--service", "metastore"]
