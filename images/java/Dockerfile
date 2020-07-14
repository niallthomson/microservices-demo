# build stage build the jar with all our resources
FROM maven:3.5-jdk-8 as build-env

ARG JAR_PATH

VOLUME /tmp
WORKDIR /

ADD ./pom.xml .

RUN mvn dependency:go-offline -B

COPY ./src ./src

RUN mvn -DskipTests package
RUN mv /$JAR_PATH /app.jar

# package stage
FROM openjdk:8-jdk-slim
WORKDIR /

# copy only the built jar and nothing else
COPY --from=build-env /app.jar /

EXPOSE 8080

ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app.jar"]