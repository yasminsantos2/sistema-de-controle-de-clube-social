-- Criação das Tabelas (DDL)
CREATE TABLE socios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    email VARCHAR(100),
    data_adesao DATE DEFAULT CURRENT_DATE,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE dependentes (
    id SERIAL PRIMARY KEY,
    socio_id INTEGER REFERENCES socios(id) ON DELETE CASCADE,
    nome VARCHAR(100) NOT NULL,
    parentesco VARCHAR(50) NOT NULL,
    data_nascimento DATE
);

-- Inserção de Dados para Teste (DML)
INSERT INTO socios (nome, cpf, email) VALUES 
('João Silva', '12345678901', 'joao@email.com'),
('Maria Oliveira', '98765432100', 'maria@email.com');

INSERT INTO dependentes (socio_id, nome, parentesco, data_nascimento) VALUES 
(1, 'Pedro Silva', 'Filho', '2015-05-20'),
(1, 'Ana Silva', 'Esposa', '1985-10-10'),
(2, 'Lucas Oliveira', 'Filho', '2018-03-15');