FROM microsoft/dotnet:2.1-sdk

RUN apt update && apt install -y unzip
RUN mkdir -p /vsdbg
RUN curl -sSL https://aka.ms/getvsdbgsh \
  | /bin/sh /dev/stdin -v latest -l /vsdbg