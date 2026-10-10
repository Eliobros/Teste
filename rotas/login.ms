# rota de login em MambaScript


# rotas/login.ms
funcao rotaLogin(req, res, conn, cripto, config, jwt, mysql):
    tente:
        variavel jwt_secret = config["JWT_SECRET"]
        se req.metodo == "POST":
            variavel dados = req.corpo
            se dados == nulo:
                dados = {}
            fim
            variavel email = dados.email
            variavel senha = dados.senha
            se email == nulo: email = "" fim
            se senha == nulo: senha = "" fim

            se email == "" ou senha == "":
                res.json(400, {"Status": "Erro", "Mensagem": "Email e senha sao obrigatorios"})
                retorne
            fim

            variavel emailNormalizado = email.aparar().minuscula()
            escreva "[LOGIN] Tentando: " + emailNormalizado

            variavel usuario = aguardar mysql.consultar("SELECT * FROM usuarios WHERE email =?", [emailNormalizado])

            se usuario == nulo ou usuario.tamanho() == 0:
                res.json(404, {"Status": "Erro", "Mensagem": "Usuario nao encontrado"})
                retorne
            fim

            variavel senhaValida = cripto.verificar(senha, usuario[0].senha)

            se senhaValida == verdadeiro:
                variavel payload = { "id": usuario[0].id, "email": emailNormalizado, "nome": usuario[0].nome }
                variavel token = aguardar jwt.assinar(payload, jwt_secret, {"expiraEm": 86400})
                res.json(200, { "Status": "Sucesso", "Mensagem": "Login bem-sucedido", "token": token })
                escreva sucesso("[LOGIN] Login ok: " + emailNormalizado)
            senao:
                res.json(401, {"Status": "Erro", "Mensagem": "Senha incorreta"})
            fim
        senao:
            res.json(405, {"Status": "Erro", "Mensagem": "Metodo nao permitido"})
        fim
    capturar (erro):
        escreva erro("[LOGIN] ERRO INTERNO: " + erro.mensagem)
        res.json(500, {"Status": "Erro", "Mensagem": "Erro interno: " + erro})
    fim
fim

exportar { rotaLogin }
