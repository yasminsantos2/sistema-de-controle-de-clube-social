CREATE TABLE categoria (
                           id_categoria SERIAL PRIMARY KEY,
                           descricao_categoria VARCHAR(100) NOT NULL
);

CREATE TABLE candidato (
                           id_candidato SERIAL PRIMARY KEY,
                           nome VARCHAR(255) NOT NULL,
                           endereco TEXT,
                           telefone VARCHAR(20),
                           email VARCHAR(150)
);

CREATE TABLE socio (
                       id_socio INTEGER PRIMARY KEY,
                       numero_cartao_socio BIGINT NOT NULL UNIQUE,
                       id_categoria INTEGER NOT NULL,
                       CONSTRAINT fk_socio_candidato
                           FOREIGN KEY (id_socio)
                               REFERENCES candidato(id_candidato)
                               ON DELETE CASCADE,
                       CONSTRAINT fk_socio_categoria
                           FOREIGN KEY (id_categoria)
                               REFERENCES categoria(id_categoria)
);

CREATE TABLE dependente (
                            id_dependente SERIAL PRIMARY KEY,
                            nome VARCHAR(255) NOT NULL,
                            parentesco VARCHAR(50),
                            email VARCHAR(150),
                            id_socio INTEGER NOT NULL,
                            CONSTRAINT fk_dependente_socio
                                FOREIGN KEY (id_socio)
                                    REFERENCES socio(id_socio)
                                    ON DELETE CASCADE
);

CREATE TABLE mensalidade (
                             id_mensalidade SERIAL PRIMARY KEY,
                             data_mensalidade DATE NOT NULL,
                             valor_mensalidade NUMERIC(10,2) NOT NULL,
                             data_pagamento DATE,
                             juros_mensalidade NUMERIC(10,2) NOT NULL DEFAULT 0,
                             valor_pago NUMERIC(10,2),
                             mensalidade_quitada BOOLEAN NOT NULL DEFAULT FALSE,
                             id_socio INTEGER NOT NULL,
                             CONSTRAINT fk_mensalidade_socio
                                 FOREIGN KEY (id_socio)
                                     REFERENCES socio(id_socio)
                                     ON DELETE CASCADE
);