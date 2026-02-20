FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5200

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["CineMatic.EmailService/CineMatic.EmailService.csproj", "CineMatic.EmailService/"]
COPY ["CineMatic.Model/CineMatic.Model.csproj", "CineMatic.Model/"]
COPY ["CineMatic.Services/CineMatic.Services.csproj", "CineMatic.Services/"]
RUN dotnet restore "CineMatic.EmailService/CineMatic.EmailService.csproj"
COPY . .
RUN dotnet build "CineMatic.EmailService/CineMatic.EmailService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CineMatic.EmailService/CineMatic.EmailService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CineMatic.EmailService.dll"]