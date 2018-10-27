FROM microsoft/dotnet:2.1-sdk AS build-env
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# copy everything else and build
COPY . ./
RUN dotnet publish -c Debug -o out

# build runtime image
FROM microsoft/dotnet:2.1-sdk 
WORKDIR /app
COPY --from=build-env /app/ .
ENTRYPOINT ["dotnet", "watch", "run", "--urls", "http://0.0.0.0:5000;https://0.0.0.0:5001"]

