FROM debian:jessie

RUN echo deb http://ftp.uk.debian.org/debian jessie-backports main >> /etc/apt/sources.list
RUN echo deb http://ftp.uk.debian.org/debian unstable main contrib non-free >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    azure-cli \
    bash \
    bash-completion \
    build-essential \
    clang \
    cmake \
    ctags \
    curl \
    ffmpeg \
    flake8 \
    gettext \
    git \
    gnupg2 \
    golang \
    gradle \
    kubernetes-client \
    locales \
    man-db \
    maven \
    ninja-build \
    nodejs \
    openssl \
    pssh \
    python \
    python3 \
    rbenv \
    rsync \
    ruby \
    shellcheck \
    ssh \
    tmux \
    tree \
    unrar \
    vim \
    vim-nox \
    virtualenvwrapper \
    wget

# Setup docker inside
WORKDIR /tmp
RUN wget --quiet https://get.docker.com/builds/Linux/x86_64/docker-1.13.1.tgz && \
    tar xzf docker-1.13.1.tgz && \
    cp /tmp/docker/docker /usr/bin/docker
ENV DOCKER_HOST=unix:///root/docker.sock

RUN apt-get install -y npm && \
    npm install -g \
        grunt \
        grunt-cli \
        jshint

# Configure timezone and locale
RUN echo "Europe/Budapest" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

# Clean up apt
RUN apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /root/.ssh/cm_sockets
RUN mkdir /root/.config

ENV TERM=xterm-256color

WORKDIR /root
