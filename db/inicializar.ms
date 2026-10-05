importar sistema de "sistema"

funcao inicializarBanco(conn):
    variavel sqls = [
        "CREATE TABLE IF NOT EXISTS usuarios (id INT AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(255) NOT NULL, email VARCHAR(255) NOT NULL UNIQUE, senha TEXT NOT NULL, criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
        "CREATE TABLE IF NOT EXISTS pagamentos (id INT AUTO_INCREMENT PRIMARY KEY, usuario_id INT, valor DECIMAL(10,2) NOT NULL, metodo VARCHAR(100), status VARCHAR(50) DEFAULT 'pendente', criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (usuario_id) REFERENCES usuarios(id))"
    ]

    para i de 0 ate sqls.tamanho() - 1:
        variavel resultado = conn.executar(sqls[i])

        se resultado.ok:
            escreva sucesso("[DB] Tabela pronta/verificada: " + (i + 1))
        senao:
            escreva erro("[DB] Falha ao criar/verificar tabela: " + (i + 1))
        fim
    fim

    escreva sucesso("[DB] Tabelas criadas/verificadas com sucesso.")

    variavel exec = sistema.executar("echo [DB] Banco inicializado e servidor pronto")
    escreva exec
fim