importar ambiente de "ambiente"
importar mysql de "mysql"
importar http de "http"
importar caminho de "caminho"
importar bcrypt de "bcrypt"
importar sistema de "sistema"

variavel cripto = bcrypt    # Inicializa o bcrypt com um fator de custo de 10

# Importando as funções criadas nos arquivos externos
importar { rotaHome } de "./rotas/home"
importar { rotaUsuarios } de "./rotas/usuarios"
importar { rotaPayment } de "./rotas/payment"
importar { rotaCadastro } de "./rotas/cadastro"  # <--- Mova para cá
importar { rotaLogin } de "./rotas/login"        # <--- Mova para cá


funcao inicializarBanco(conn):
    variavel sqls = [
        "CREATE TABLE IF NOT EXISTS usuarios (id INT AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(255) NOT NULL, email VARCHAR(255) NOT NULL UNIQUE, senha TEXT NOT NULL, criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
        "CREATE TABLE IF NOT EXISTS pagamentos (id INT AUTO_INCREMENT PRIMARY KEY, usuario_id INT, valor DECIMAL(10,2) NOT NULL, metodo VARCHAR(100), status VARCHAR(50) DEFAULT 'pendente', criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (usuario_id) REFERENCES usuarios(id))"
    ]

    para i de 0 ate sqls.tamanho() - 1:
        conn.executar(sqls[i])
    fim

    variavel tabelas = conn.consultar("SHOW TABLES")
    escreva sucesso("[DB] Tabelas criadas/verificadas no banco: " + tabelas)
    escreva sucesso("[DB] Banco inicializado e servidor pronto.")

    variavel exec = sistema.executar("echo [DB] Banco inicializado e servidor pronto")
    escreva exec
fim

variavel config = ambiente.carregar(caminho.arquivo(".env"))

variavel host = config["DB_HOST"]
variavel user = config["DB_USER"]
variavel password = config["DB_PASSWORD"]
variavel database = config["DB_NAME"]
variavel porta = config["PORTA"]

variavel data = hoje("Africa/Maputo")

variavel conn = mysql.conectar(host, user, password, database)

se conn.ok == verdadeiro:
    escreva sucesso(conn.mensagem)
    inicializarBanco(mysql)
senao:
    escreva erro(conn.mensagem)

fim

variavel app = http.criarServidor()

variavel servidor = funcao(requisicao, resposta):
    variavel rota = requisicao.url
    variavel req = requisicao
    variavel res = resposta

    # Despacha as rotas sem chamar funções armazenadas em variáveis
    se rota == "/":
        rotaHome(req, res, mysql)
    senao:
        se rota == "/users":
            rotaUsuarios(req, res, mysql)
        senao:
            se rota == "/payment":
                rotaPayment(req, res, config, mysql, data)
            senao:
                se rota == "/api/cadastro":
                   # importar { rotaCadastro } de "./rotas/cadastro"
                    rotaCadastro(req, res, mysql, cripto)
                senao:
                    se rota == "/api/login":
                       # importar { rotaLogin } de "./rotas/login"
                        rotaLogin(req, res, mysql, cripto)
                    senao:
                        # Tratamento de erro 404 (Rota não encontrada)
                        variavel erro404 = {
                            "Status": "Erro",
                            "Mensagem": "Rota nao encontrada",
                            "Rota": rota,
                            "Metodo": requisicao.metodo
                        }
                        res.json(404, erro404)
                        escreva erro("[ROTA NÃO ENCONTRADA] " + requisicao.metodo + " " + rota)
                    fim
                fim
            fim
        fim
    fim

    escreva "[ROTA] " + requisicao.metodo + " " + rota
fim

# Código para iniciar o servidor
app.aoReceber(servidor)
app.escutar(porta)
escreva sucesso("Servidor rodando na porta: " + porta + " acesse clicando aqui http://localhost:" + porta)