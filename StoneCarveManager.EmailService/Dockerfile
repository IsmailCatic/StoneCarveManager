FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5200

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["StoneCarveManager.EmailService/StoneCarveManager.EmailService.csproj", "StoneCarveManager.EmailService/"]
COPY ["StoneCarveManager.Model/StoneCarveManager.Model.csproj", "StoneCarveManager.Model/"]
COPY ["StoneCarveManager.Services/StoneCarveManager.Services.csproj", "StoneCarveManager.Services/"]
RUN dotnet restore "StoneCarveManager.EmailService/StoneCarveManager.EmailService.csproj"
COPY . .
RUN dotnet build "StoneCarveManager.EmailService/StoneCarveManager.EmailService.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "StoneCarveManager.EmailService/StoneCarveManager.EmailService.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "StoneCarveManager.EmailService.dll"]