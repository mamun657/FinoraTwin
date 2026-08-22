FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore "FinoraTwin.Api/FinoraTwin.Api.csproj"
RUN dotnet publish "FinoraTwin.Api/FinoraTwin.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://0.0.0.0:10000
ENV DOTNET_USE_POLLING_FILE_WATCHER=true
ENV DOTNET_HOSTING_OPTIMIZATION__DETECTION=false
EXPOSE 10000
ENTRYPOINT ["dotnet", "FinoraTwin.Api.dll"]