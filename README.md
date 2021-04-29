# SBT Dockerized

It is a docker images used with Drone to build Scala Projects on SBT. 

The original idea belongs to [Eugene Yokota](https://github.com/eed3si9n)
[https://github.com/eed3si9n/docker-sbt](https://github.com/eed3si9n/docker-sbt)

Changes:
- [x] base image `adoptopenjdk/openjdk11:alpine-slim`
- [x] sbt 1.3.10
- [x] `curl` package added constantly. (used by [Codecov Bash Uploader](https://github.com/codecov/codecov-bash))

Changelog:
- July 28, 2020
    - [x] sbt 1.3.13
- Nov 26, 2020
    - [x] sbt 1.4.4    
- Apr 14, 2021
    - [x] sbt 1.5.0
- Apr 29, 2021
    - [x] sbt 1.5.1	