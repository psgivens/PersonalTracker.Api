FROM pomodoro-dotnet-stage AS build-env
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# build runtime image
FROM microsoft/dotnet:2.1-sdk 

WORKDIR /app
COPY --from=build-env /app/ .
CMD ["dotnet", "run", "--urls", "http://0.0.0.0:80"]
