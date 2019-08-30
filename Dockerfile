FROM mcr.microsoft.com/dotnet/core/aspnet:3.0-alpine

WORKDIR /webapp

COPY /webapp /webapp

EXPOSE 5000/tcp

ENV ASPNETCORE_URLS http://*:5000

ENTRYPOINT dotnet dotnetdemo.dll