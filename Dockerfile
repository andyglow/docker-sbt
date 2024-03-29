# BORROWED FROM
# https://github.com/eed3si9n/docker-sbt/blob/master/jdk11/alpine/Dockerfile

FROM adoptopenjdk/openjdk11:alpine-slim

LABEL maintainer="andyglow@gmail.com"

RUN set -x \
  && SBT_VER="1.5.5" \
  && ESUM="c0fcd50cf5c91ed27ad01c5c6a8717b62700c87a50ff9b0e7573b227acb2b3c9" \
  && SBT_URL="https://github.com/sbt/sbt/releases/download/v${SBT_VER}/sbt-${SBT_VER}.tgz" \
  && apk add curl \
  && apk add shadow \
  && apk add bash \
  && apk add openssh \
  && apk add rsync \
  && apk add git \
  && curl -Ls ${SBT_URL} > /tmp/sbt-${SBT_VER}.tgz \
  && sha256sum /tmp/sbt-${SBT_VER}.tgz \
  && (echo "${ESUM}  /tmp/sbt-${SBT_VER}.tgz" | sha256sum -c -) \
  && mkdir /opt/sbt \
  && tar -zxf /tmp/sbt-${SBT_VER}.tgz -C /opt/sbt \
  && sed -i -r 's#run \"\$\@\"#unset JAVA_TOOL_OPTIONS\nrun \"\$\@\"#g' /opt/sbt/sbt/bin/sbt \
  && rm -rf /tmp/sbt-${SBT_VER}.tgz /var/cache/apk/*

WORKDIR /opt/workspace

ENTRYPOINT ["sbt"]

ENV PATH="/opt/sbt/sbt/bin:$PATH" \
    JAVA_OPTS="-XX:+UseContainerSupport -Dfile.encoding=UTF-8" \
    SBT_OPTS="-Xmx2048M -Xss2M"

RUN set -x \
  && echo "ThisBuild / scalaVersion := \"2.13.6\"" >> build.sbt \
  && mkdir -p project \
  && echo "sbt.version=1.5.5" >> project/build.properties \
  && echo "object Test" >> Test.scala \
  && sbt compile \
  && sbt compile \
  && rm Test.scala \
  && rm -rf project \
  && rm -rf target \
  && rm build.sbt