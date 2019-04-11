FROM pomodoro-dotnet-stage AS build-env
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# copy everything else and build
COPY . ./
RUN dotnet publish -c Debug -o out

# build runtime image
FROM microsoft/dotnet:2.1-aspnetcore-runtime 
RUN mkdir /vsdbg
COPY --from=build-env /vsdbg/ /vsdbg/

WORKDIR /app
COPY --from=build-env /app/out/ .
ENTRYPOINT ["dotnet", "Pomodoro.Api.dll"]

