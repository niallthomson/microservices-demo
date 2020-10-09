
FROM openjdk:8-jre-alpine

ENV ACTIVEMQ_DATA="/data"

RUN mkdir /$ACTIVEMQ_DATA

RUN wget -O activemq.tar.gz http://archive.apache.org/dist/activemq/5.16.0/apache-activemq-5.16.0-bin.tar.gz \
  && tar -xzf activemq.tar.gz \
  && rm activemq.tar.gz

CMD ["apache-activemq-5.16.0/bin/activemq", "console"]