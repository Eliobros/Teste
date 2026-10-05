# rota de login em MambaScript
# rotas/login.ms

variavel rotaLogin = funcao(req, res, conn, cripto):
    se req.metodo == "POST":
        variavel dados = req.corpo

        se dados == nulo:
            dados = {}
        fim

        variavel email = dados.email
        variavel senha = dados.senha

        se email == nulo:
            email = ""
        fim

        se senha == nulo:
            senha = ""
        fim

        se email == "" ou senha == "":
            res.json(400, {"Status": "Erro", "Mensagem": "Email e senha são obrigatórios"})
            escreva erro("[LOGIN] Campos obrigatórios não preenchidos")
            retorne
        fim

        variavel emailNormalizado = email.aparar().minuscula()
        variavel usuario = conn.consultar("SELECT * FROM usuarios WHERE email = ?", [emailNormalizado])

        se usuario == nulo ou usuario.length == 0:
            res.json(404, {"Status": "Erro", "Mensagem": "Usuário não encontrado"})
            escreva erro("[LOGIN] Usuário não encontrado: " + emailNormalizado)
            retorne
        fim

        variavel senhaValida = cripto.verificar(senha, usuario[0].senha)

        se senhaValida:
            res.json(200, {"Status": "Sucesso", "Mensagem": "Login bem-sucedido"})
            escreva sucesso("[LOGIN] Login realizado com sucesso: " + emailNormalizado)
        senao:
            res.json(401, {"Status": "Erro", "Mensagem": "Senha incorreta"})
            escreva erro("[LOGIN] Senha incorreta para: " + emailNormalizado)
        fim
    senao:
        res.json(405, {"Status": "Erro", "Mensagem": "Método não permitido"})
        escreva erro("[LOGIN] Método não permitido: " + req.metodo)
    fim
fim
