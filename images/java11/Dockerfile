# Build Stage
FROM maven:3.6.3-adoptopenjdk-11 as build-env

ARG JAR_PATH

VOLUME /tmp
WORKDIR /

ADD ./pom.xml .

RUN mvn dependency:go-offline -B

COPY ./src ./src

RUN mvn -DskipTests package
RUN mv /$JAR_PATH /app.jar

# Package Stage
FROM adoptopenjdk:11-jre-openj9

ENV APPUSER=appuser
ENV APPUID=1000
ENV APPGID=1000

RUN addgroup --gid $APPGID "$APPUSER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "/app" \
    --ingroup "$APPUSER" \
    --uid "$APPUID" \
    "$APPUSER"

WORKDIR /app
USER appuser

COPY --chown=appuser:appuser --from=build-env /app.jar .

EXPOSE 8080

CMD exec java $JAVA_OPTS -jar /app/app.jar