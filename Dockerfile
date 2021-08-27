FROM ubuntu:rolling

RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
&&  apt update -qq -y && apt dist-upgrade -qq -y && apt-get build-dep wine -qq -y && apt install mingw-w64 git -qq -y && apt-get clean -qq -y
