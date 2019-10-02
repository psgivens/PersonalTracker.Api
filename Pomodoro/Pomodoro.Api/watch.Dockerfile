FROM pomodoro-dotnet-stage AS build-env
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.csproj ./
COPY . ./
RUN dotnet restore

# copy everything else and build
RUN dotnet publish -c Debug -o out

# build runtime image
FROM microsoft/dotnet:2.2-sdk 

RUN mkdir /vsdbg
COPY --from=build-env /vsdbg/ /vsdbg/

WORKDIR /app
COPY --from=build-env /app/ .
ENTRYPOINT ["dotnet"]
CMD ["watch", "run"]
# ENTRYPOINT ["dotnet", "watch", "run", "--urls", "http://0.0.0.0:8003"]

