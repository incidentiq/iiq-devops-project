FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app
COPY TodoApi.csproj TodoApi.csproj
RUN dotnet restore
COPY . ./
RUN dotnet publish -c Release -o Release

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/Release .
ENV ASPNETCORE_URLS=http://+:5000
ENTRYPOINT [ "dotnet", "TodoApi.dll" ]