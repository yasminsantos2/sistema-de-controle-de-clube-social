# Guia de Teste e Validação: Clube Social API

Este documento descreve o processo de teste automatizado e validação manual do fluxo de dados no banco de dados do sistema.

---

## 1. Pré-requisitos
- **PostgreSQL**: O banco de dados deve estar rodando.
- **psql**: O utilitário de linha de comando do PostgreSQL deve estar acessível (o script tenta localizá-lo automaticamente se não estiver no PATH).
- **Configuração**: O arquivo `src/main/resources/application.properties` deve conter as credenciais corretas do banco.

---

## 2. Teste Automatizado (PowerShell)

Para rodar todos os testes de uma vez e validar as regras de negócio (Insert, Update, Delete Cascade), execute o script:

```powershell
.\test_db_flow.ps1
```

### O que o script faz:
1.  **Sincronização**: Lê o arquivo `V1__initial_schema.sql` e garante que as tabelas existam.
2.  **Limpeza**: Remove rastros de testes anteriores.
3.  **Fluxo de Dados**: Insere sócios e dependentes, atualiza status e exclui registros.
4.  **Validação**: Compara os resultados retornados pelo banco com os valores esperados.

---

## 3. Validação Passo a Passo (Manual)

Se preferir validar cada etapa manualmente via SQL, siga este roteiro:

### Passo 1: Criação de um Sócio
**Ação:** Inserir um novo sócio titular.
```sql
INSERT INTO socios (nome, cpf, email) VALUES ('Carlos Eduardo', '55544433322', 'carlos@clube.com');
```
**Validação:** O contador de sócios deve aumentar.
```sql
SELECT * FROM socios WHERE cpf = '55544433322';
```

### Passo 2: Adição de Dependentes
**Ação:** Vincular familiares ao sócio criado. (Substitua `ID_DO_SOCIO` pelo ID gerado).
```sql
INSERT INTO dependentes (socio_id, nome, parentesco) VALUES (ID_DO_SOCIO, 'Julia', 'Filha');
```
**Validação:** Verificar se o dependente aparece no relatório do sócio.
```sql
SELECT s.nome AS Titular, d.nome AS Dependente 
FROM socios s 
JOIN dependentes d ON s.id = d.socio_id;
```

### Passo 3: Desativação (Update)
**Ação:** Mudar o status de `ativo` para `false`.
```sql
UPDATE socios SET ativo = FALSE WHERE cpf = '55544433322';
```
**Validação:** O campo `ativo` deve ser `f` (ou `false`).
```sql
SELECT nome, ativo FROM socios WHERE cpf = '55544433322';
```

### Passo 4: Exclusão em Cascata (Delete Cascade)
**Ação:** Excluir o sócio titular.
```sql
DELETE FROM socios WHERE cpf = '55544433322';
```
**Validação Crítica:** Verifique se os dependentes **também sumiram**. Se eles ainda existirem, o `ON DELETE CASCADE` falhou.
```sql
SELECT COUNT(*) FROM dependentes WHERE socio_id = ID_DO_SOCIO; -- Resultado deve ser 0
```

---

## 4. Troubleshooting (Resolução de Problemas)

| Problema | Causa Provável | Solução |
| :--- | :--- | :--- |
| **psql não reconhecido** | PostgreSQL não está no PATH | O script `test_db_flow.ps1` já possui correção para localizar o binário automaticamente. |
| **Relação não existe** | Tabelas não foram criadas | Certifique-se de que o arquivo `V1__initial_schema.sql` foi executado (o script faz isso no Passo -1). |
| **Erro de Senha** | Senha incorreta no .properties | Verifique a chave `spring.datasource.password` no arquivo `application.properties`. |
