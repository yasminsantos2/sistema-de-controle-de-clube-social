# ==========================================================
# AUTOMATED DATABASE FLOW TEST - CLUBE SOCIAL
# ==========================================================

$propFile = "src/main/resources/application.properties"
if (-not (Test-Path $propFile)) {
    Write-Error "Arquivo application.properties não encontrado!"
    exit 1
}

# 1. Extração de configurações (com defaults se não encontrar variáveis)
$content = Get-Content $propFile -Raw
$dbHost = if ($content -match "DB_HOST:([^}:]+)") { $Matches[1] } else { "localhost" }
$dbPort = if ($content -match "DB_PORT:([^}:]+)") { $Matches[1] } else { "5432" }
$dbName = if ($content -match "DB_NAME:([^}:]+)") { $Matches[1] } else { "clube_social_db" }
$dbUser = if ($content -match "DB_USERNAME:([^}:]+)") { $Matches[1] } else { "postgres" }
$dbPass = if ($content -match "DB_PASSWORD:([^}:]+)") { $Matches[1] } else { "32213115" }

# 2. Descoberta do psql.exe
$psqlPath = "psql" # Tenta o padrão primeiro
if (-not (Get-Command $psqlPath -ErrorAction SilentlyContinue)) {
    Write-Host "psql não encontrado no PATH. Tentando localização padrão..." -ForegroundColor Yellow
    $searchPaths = @(
        "C:\Program Files\PostgreSQL\*\bin\psql.exe",
        "C:\Program Files (x86)\PostgreSQL\*\bin\psql.exe"
    )
    foreach ($p in $searchPaths) {
        $found = Resolve-Path $p -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $psqlPath = $found.Path
            break
        }
    }
}

if (-not (Get-Command $psqlPath -ErrorAction SilentlyContinue)) {
    Write-Error "Não foi possível localizar o psql.exe automaticamente. Por favor, adicione o diretório 'bin' do PostgreSQL ao seu PATH ou edite este script."
    exit 1
}

$env:PGPASSWORD = $dbPass

function Run-Sql {
    param([string]$sql)
    return & $psqlPath -h $dbHost -p $dbPort -U $dbUser -d $dbName -t -A -c "$sql"
}

Write-Host "--- Iniciando Simulação e Validação Automatizada ---" -ForegroundColor Cyan

# PASSO -1: Inicializando Esquema (Flyway)
$v1File = "src/main/resources/db/migration/V1__initial_schema.sql"
$v2File = "src/main/resources/db/migration/V2__create_table_candidatos.sql"

function Init-Migration {
    param([string]$file)
    if (Test-Path $file) {
        Write-Host "[*] Inicializando migração $(Split-Path $file -Leaf)..." -NoNewline
        & $psqlPath -h $dbHost -p $dbPort -U $dbUser -d $dbName -f $file > $null 2>&1
        Write-Host " OK" -ForegroundColor Green
    }
}

Init-Migration $v1File
Init-Migration $v2File

# PASSO 0: Limpeza
Write-Host "[0/5] Limpando ambiente de teste..." -NoNewline
Run-Sql "DELETE FROM socios WHERE cpf IN ('55544433322', '11122233344');" | Out-Null
Run-Sql "DELETE FROM candidatos WHERE cpf = '99988877766';" | Out-Null
Write-Host " OK" -ForegroundColor Green

# PASSO 1 ... (mantidos os passos anteriores)
# ...

# PASSO 5: Teste de Candidatos
Write-Host "[5/5] Testando Fluxo de Candidato..." -NoNewline
Run-Sql "INSERT INTO candidatos (nome, cpf, email, status) VALUES ('Candidato Teste', '99988877766', 'teste@candidato.com', 'PENDENTE');" | Out-Null

$candStatus = Run-Sql "SELECT status FROM candidatos WHERE cpf = '99988877766';"
if ($candStatus -eq "PENDENTE") {
    Write-Host " [PASS]" -ForegroundColor Green
} else {
    Write-Host " [FAIL]" -ForegroundColor Red
    exit 1
}

Write-Host "`n--- Simulação Concluída com Sucesso! ---" -ForegroundColor Cyan
