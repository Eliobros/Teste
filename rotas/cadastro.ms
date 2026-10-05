# rota de cadastro em MambaScript
# rotas/cadastro.ms

variavel rotaCadastro = funcao(req, res, conn, cripto):
    se req.metodo == "POST":
        variavel dados = req.corpo

        se dados == nulo:
            dados = {}
        fim

        variavel nome = dados.nome
        variavel email = dados.email
        variavel senha = dados.senha

        se nome == nulo:
            nome = ""
        fim

        se email == nulo:
            email = ""
        fim

        se senha == nulo:
            senha = ""
        fim

        # Verifica se todos os campos foram preenchidos
        se nome == "" ou email == "" ou senha == "":
            res.json(400, {"Status": "Erro", "Mensagem": "Todos os campos são obrigatórios"})
            escreva erro("[CADASTRO] Campos obrigatórios não preenchidos")
        senao:
            variavel emailNormalizado = email.aparar().minuscula()

            # Verifica se o email já está cadastrado
            variavel verificarEmail = conn.consultar("SELECT * FROM usuarios WHERE email = ?", [emailNormalizado])

            se verificarEmail.length > 0:
                res.json(409, {"Status": "Erro", "Mensagem": "Email já cadastrado"})
                escreva erro("[CADASTRO] Email já cadastrado: " + emailNormalizado)
            senao:
                # Criptografa a senha antes de salvar no banco de dados
                variavel senhaCriptografada = cripto.hashSenha(senha, 10)

                # Insere o novo usuário no banco de dados
                variavel inserirUsuario = conn.executar("INSERT INTO usuarios (nome, email, senha) VALUES (?, ?, ?)", [nome, emailNormalizado, senhaCriptografada])

                se inserirUsuario.ok:
                    res.json(201, {"Status": "Sucesso", "Mensagem": "Usuário cadastrado com sucesso"})
                    escreva sucesso("[CADASTRO] Usuário cadastrado: " + emailNormalizado)
                senao:
                    res.json(500, {"Status": "Erro", "Mensagem": "Erro ao cadastrar usuário"})
                    escreva erro("[CADASTRO] Erro ao cadastrar usuário")
                fim
            fim
        fim
    senao:
        res.json(405, {"Status": "Erro", "Mensagem": "Método não permitido"})
        escreva erro("[CADASTRO] Método não permitido: " + req.metodo)
    fim
fim