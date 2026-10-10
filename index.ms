importar ambiente de "ambiente"
importar mysql de "mysql"
importar http de "http"
importar caminho de "caminho"
importar bcrypt de "bcrypt"
importar sistema de "sistema"
importar jwt de "mambas-jwt"

variavel cripto = bcrypt

importar { rotaHome } de "./rotas/home"
importar { rotaUsuarios } de "./rotas/usuarios"
importar { rotaPayment } de "./rotas/payment"
importar { rotaCadastro } de "./rotas/cadastro"
importar { rotaLogin } de "./rotas/login"
importar { apiClient } de "./lib/api"
importar { rotaWebhook } de "./rotas/webhook"

funcao inicializarBanco(conn):
    variavel sqls = [
        "CREATE TABLE IF NOT EXISTS usuarios (id INT AUTO_INCREMENT PRIMARY KEY, nome VARCHAR(255) NOT NULL, email VARCHAR(255) NOT NULL UNIQUE, senha TEXT NOT NULL, criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP)",
        "CREATE TABLE IF NOT EXISTS pagamentos (id INT AUTO_INCREMENT PRIMARY KEY, usuario_id INT, valor DECIMAL(10,2) NOT NULL, metodo VARCHAR(100), status VARCHAR(50) DEFAULT 'pendente', criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (usuario_id) REFERENCES usuarios(id))"
    ]

    para i de 0 ate sqls.tamanho() - 1:
        conn.executar(sqls[i])
    fim

    variavel tabelas = conn.consultar("SHOW TABLES")
    escreva sucesso("[DB] Tabelas: " + tabelas.tamanho() + " encontradas")
    escreva sucesso("[DB] Banco inicializado e servidor pronto.")
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

    res.cabecalho("X-Powered-By", "MambaScript")
    res.cabecalho("Access-Control-Allow-Origin", "*")
    res.cabecalho("Access-Control-Allow-Headers", "Content-Type, Authorization")
    res.cabecalho("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")

    se requisicao.metodo == "OPTIONS":
        res.json(204, {})
        escreva "[PREFLIGHT] " + rota
    senao:
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
                        rotaCadastro(req, res, mysql, cripto, conn)
                    senao:
                        se rota == "/api/login":
                            rotaLogin(req, res, conn, cripto, config, jwt, mysql)
                        senao:
                            se rota == "/api/checkout":
                                apiClient(req, res, config)
                            senao:
                                se rota == "/api/webhook":
                                    rotaWebhook(req, res, conn, config)
                                senao:
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
            fim
        fim

        escreva "[ROTA] " + requisicao.metodo + " " + rota
    fim
fim

app.aoReceber(servidor)
app.escutar(porta)
escreva sucesso("Servidor rodando na porta: " + porta + " acesse clicando aqui http://localhost:" + porta)
exportar { mysql }
