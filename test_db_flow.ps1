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

# PASSO -1: Inicializando Esquema (Flyway V1 fallback)
$v1File = "src/main/resources/db/migration/V1__initial_schema.sql"
if (Test-Path $v1File) {
    Write-Host "[*] Inicializando tabelas (V1__initial_schema.sql)..." -NoNewline
    & $psqlPath -h $dbHost -p $dbPort -U $dbUser -d $dbName -f $v1File > $null 2>&1
    Write-Host " OK" -ForegroundColor Green
} else {
    Write-Warning "Arquivo de migration V1 não encontrado. Continuando..."
}

# PASSO 0: Limpeza
Write-Host "[0/4] Limpando ambiente de teste..." -NoNewline
Run-Sql "DELETE FROM socios WHERE cpf IN ('55544433322', '11122233344');" | Out-Null
Write-Host " OK" -ForegroundColor Green

# PASSO 1: Cadastro de Sócio Titular
Write-Host "[1/4] Cadastrando Sócio 'Carlos Eduardo'..." -NoNewline
Run-Sql "INSERT INTO socios (nome, cpf, email) VALUES ('Carlos Eduardo', '55544433322', 'carlos@clube.com');" | Out-Null

$exists = Run-Sql "SELECT COUNT(*) FROM socios WHERE cpf = '55544433322';"
if ($exists -eq "1") {
    Write-Host " [PASS]" -ForegroundColor Green
} else {
    Write-Host " [FAIL]" -ForegroundColor Red
    exit 1
}

# PASSO 2: Cadastro de Dependentes
Write-Host "[2/4] Cadastrando Dependentes para Carlos..." -NoNewline
$socioId = Run-Sql "SELECT id FROM socios WHERE cpf = '55544433322';"
Run-Sql "INSERT INTO dependentes (socio_id, nome, parentesco) VALUES ($socioId, 'Julia Eduardo', 'Filha'), ($socioId, 'Marcos Eduardo', 'Filho');" | Out-Null

$depCount = Run-Sql "SELECT COUNT(*) FROM dependentes WHERE socio_id = $socioId;"
if ($depCount -eq "2") {
    Write-Host " [PASS]" -ForegroundColor Green
} else {
    Write-Host " [FAIL]" -ForegroundColor Red
    exit 1
}

# PASSO 3: Atualização de Ativo/Inativo
Write-Host "[3/4] Atualizando status do sócio..." -NoNewline
Run-Sql "UPDATE socios SET ativo = FALSE WHERE id = $socioId;" | Out-Null

$status = Run-Sql "SELECT ativo FROM socios WHERE id = $socioId;"
if ($status -eq "f") { # No psql -t -A, Boolean FALSE é 'f'
    Write-Host " [PASS]" -ForegroundColor Green
} else {
    Write-Host " [FAIL] Status: $status" -ForegroundColor Red
    exit 1
}

# PASSO 4: Deleção e Cascade
Write-Host "[4/4] Testando exclusão em cascata (DELETE CASCADE)..." -NoNewline
Run-Sql "DELETE FROM socios WHERE id = $socioId;" | Out-Null

$socioQuery = Run-Sql "SELECT COUNT(*) FROM socios WHERE id = $socioId;"
$depQuery = Run-Sql "SELECT COUNT(*) FROM dependentes WHERE socio_id = $socioId;"

if ($socioQuery -eq "0" -and $depQuery -eq "0") {
    Write-Host " [PASS]" -ForegroundColor Green
} else {
    Write-Host " [FAIL] Sócio: $socioQuery, Deps: $depQuery" -ForegroundColor Red
    exit 1
}

Write-Host "`n--- Simulação Concluída com Sucesso! ---" -ForegroundColor Cyan
