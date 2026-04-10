# ── Build stage ──────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Restore dependencies (layer-cached unless .csproj files change)
COPY src/Api/Api.csproj             src/Api/
COPY src/Domain/Domain.csproj       src/Domain/
COPY src/Infrastructure/Infrastructure.csproj src/Infrastructure/
COPY tests/UnitTests/UnitTests.csproj         tests/UnitTests/
COPY SituationistEvents.sln .
RUN dotnet restore

# Copy everything and publish
COPY . .
RUN dotnet publish src/Api/Api.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

# ── Runtime stage ─────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Non-root user for security
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "Api.dll"]
