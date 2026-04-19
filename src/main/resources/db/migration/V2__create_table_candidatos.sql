-- Criação da tabela de candidatos
CREATE TABLE candidatos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    email VARCHAR(100),
    data_nascimento DATE,
    data_inscricao DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'PENDENTE'
);

-- Inserção de dados para teste inicial
INSERT INTO candidatos (nome, cpf, email, data_nascimento, status) VALUES 
('Roberto Carlos', '11122233344', 'roberto@email.com', '1960-04-19', 'PENDENTE'),
('Zico Galinho', '55566677788', 'zico@flamengo.com', '1953-03-03', 'APROVADO');
