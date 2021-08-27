FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
&&  apt update -qq -y && apt dist-upgrade -qq -y && apt-get build-dep wine -qq -y && apt install mingw-w64 git -qq -y && apt-get clean -qq -y

#COPY build.sh .
WORKDIR /workspace
ENTRYPOINT ["/bin/bash", "build.sh"]
