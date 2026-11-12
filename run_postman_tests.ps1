# ==============================================================================
# Script de Ejecución Automatizada de Pruebas Postman / Newman — ApexFit
# Proyecto de Aula FullStack — Entrega 3
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  APEXFIT - EJECUTOR DE PRUEBAS AUTOMATIZADAS (NEWMAN)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$collectionPath = "$PSScriptRoot\postman_collections\ApexFit_JWT_Security.postman_collection.json"
$environmentPath = "$PSScriptRoot\postman_environments\ApexFit_Local.postman_environment.json"

if (!(Test-Path $collectionPath)) {
    Write-Host "❌ Error: No se encontró la colección en $collectionPath" -ForegroundColor Red
    exit 1
}

Write-Host "Verificando si el backend de Spring Boot está en ejecución en http://localhost:8080 ..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/v1/ejercicios" -Method GET -TimeoutSec 3 -ErrorAction SilentlyContinue
} catch {
    if ($_.Exception.Response.StatusCode.value__ -eq 401) {
        Write-Host "✅ Backend detectado y respondiendo en el puerto 8080." -ForegroundColor Green
    } else {
        Write-Host "⚠️  Advertencia: No se pudo contactar http://localhost:8080." -ForegroundColor Yellow
        Write-Host "Asegúrate de haber iniciado el backend con: cd ..\apexfit\apexfit-backend; .\mvnw spring-boot:run" -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "Iniciando ejecución de 47 tests automatizados con Newman..." -ForegroundColor Cyan
npx -y newman run "$collectionPath" -e "$environmentPath" --delay-request 50 --reporters cli

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  Ejecución finalizada." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
