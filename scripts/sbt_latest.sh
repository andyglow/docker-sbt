#!/bin/sh

set -e
latest_file=$(mktemp /tmp/sbt-latest.XXXXXX)
latest_asset=$(mktemp /tmp/sbt-asset.XXXXXX)

curl -s -o $latest_file \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/sbt/sbt/releases/latest 
  
version=$(cat $latest_file | jq -r '.name')
url=$(cat $latest_file | jq -r '.assets[] | select(.content_type == "application/gzip") | .browser_download_url')

curl -Ls $url > $latest_asset
esum=$(sha256sum $latest_asset | tr " " "\n" | head -n 1)

echo $version
echo $url
echo $esum

mk_build () {
tag_prefix=$1
base_image=$2
dockerfile=$(mktemp "/tmp/sbt-dockerfile-$tag_prefix.XXXXXX")
cat > "$dockerfile" <<-EOF

FROM $base_image

LABEL maintainer="andyglow@gmail.com"

RUN set -x \
  && SBT_VER="$version" \
  && ESUM="$esum" \
  && SBT_URL="https://github.com/sbt/sbt/releases/download/v\${SBT_VER}/sbt-\${SBT_VER}.tgz" \
  && apk add curl \
  && apk add shadow \
  && apk add bash \
  && apk add openssh \
  && apk add rsync \
  && apk add git \
  && curl -Ls \${SBT_URL} > /tmp/sbt-\${SBT_VER}.tgz \
  && sha256sum /tmp/sbt-\${SBT_VER}.tgz \
  && (echo "\${ESUM}  /tmp/sbt-\${SBT_VER}.tgz" | sha256sum -c -) \
  && mkdir /opt/sbt \
  && tar -zxf /tmp/sbt-\${SBT_VER}.tgz -C /opt/sbt \
  && rm -rf /tmp/sbt-\${SBT_VER}.tgz /var/cache/apk/*

WORKDIR /opt/workspace

ENTRYPOINT ["sbt"]

ENV PATH="/opt/sbt/sbt/bin:/opt/java/openjdk/bin/:/opt/openjdk-17/bin:$PATH" \
    JAVA_OPTS="-XX:+UseContainerSupport -Dfile.encoding=UTF-8" \
    SBT_OPTS="-Xmx2048M -Xss2M"

RUN set -x \
  && java -version \
  && echo "ThisBuild / scalaVersion := \"2.13.6\"" >> build.sbt \
  && mkdir -p project \
  && echo "sbt.version=$version" >> project/build.properties \
  && echo "object Test" >> Test.scala \
  && sbt compile \
  && sbt compile \
  && rm Test.scala \
  && rm -rf project \
  && rm -rf target \
  && rm build.sbt

EOF

docker_tag="$tag_prefix-$version"
docker build -t andyglow/sbt:$docker_tag -t andyglow/sbt -f $dockerfile .
docker push andyglow/sbt:$docker_tag
docker push andyglow/sbt:latest

rm $dockerfile
}

mk_build "jdk11" "adoptopenjdk/openjdk11:alpine-slim"
mk_build "jdk17" "openjdk:17-jdk-alpine"

rm $latest_asset $latest_file