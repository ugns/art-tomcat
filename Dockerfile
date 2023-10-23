ARG ART_BASE_IMAGE=tomcat:9-jdk11
ARG ART_BUILD_IMAGE=debian:latest

FROM $ART_BUILD_IMAGE as builder
WORKDIR /
RUN apt update && \
    apt install -y wget unzip
RUN wget -O art-latest.zip https://sourceforge.net/projects/art/files/latest/download && \
    unzip art-latest.zip

FROM $ART_BASE_IMAGE
ENV CATALINA_OPTS="-Dart.configDirectory=/art"
COPY --from=builder /art-*/art.war /usr/local/tomcat/webapps/
RUN mkdir /art && \
    mkdir /work && \
    mkdir /export
VOLUME /work
VOLUME /export