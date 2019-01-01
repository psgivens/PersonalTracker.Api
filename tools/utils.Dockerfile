FROM ubuntu

RUN apt-get update \
    && apt-get install -y \
        vim \
        iproute2 \
        iputils-ping \
        dnsutils \
        curl \
        telnet-ssl
