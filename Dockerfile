FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive
# dpkg --add-architecture i386
# apt-get build-dep -a i386 wine # does not work
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
&&  apt update -qq -y && apt dist-upgrade -qq -y \
&&  apt-get build-dep wine -qq -y && apt install clang mingw-w64 git ccache -qq -y \
&&  apt-get clean -qq -y

WORKDIR /workspace
ENTRYPOINT ["/bin/bash", "build.sh"]
