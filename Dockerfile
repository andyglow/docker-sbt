# BORROWED FROM
# https://github.com/eed3si9n/docker-sbt/blob/master/jdk11/alpine/Dockerfile

FROM adoptopenjdk/openjdk11:alpine-slim

LABEL maintainer="andyglow@gmail.com"

RUN set -x \
  && SBT_VER="1.4.4" \
  && ESUM="2efae0876119af7bfce8b3621b43b08c51381352916ac9de6156b1251ec26d45" \
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
  && echo "ThisBuild / scalaVersion := \"2.13.4\"" >> build.sbt \
  && mkdir -p project \
  && echo "sbt.version=1.4.4" >> project/build.properties \
  && echo "object Test" >> Test.scala \
  && sbt compile \
  && sbt compile \
  && rm Test.scala \
  && rm -rf project \
  && rm -rf target \
  && rm build.sbt