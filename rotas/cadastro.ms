# rota de cadastro em MambaScript
# rotas/cadastro.ms

#importar { mysql  } de "../index"

funcao rotaCadastro(req, res, conn, cripto, mysql):
#	importar { mysql } de "../index"
    # Envolve toda a lógica da rota para capturar qualquer exceção oculta
    tente:
        escreva "[CADASTRO] entrou na funcao"
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

                escreva "[CADASTRO] 1 - antes de consultar email"
                variavel verificarEmail = aguardar  conn.consultar("SELECT * FROM usuarios WHERE email = ?", [emailNormalizado])
                escreva "[CADASTRO] 2 - depois de consultar"

                se verificarEmail.length > 0:
                    res.json(409, {"Status": "Erro", "Mensagem": "Email já cadastrado"})
                    escreva erro("[CADASTRO] Email já cadastrado: " + emailNormalizado)
                senao:
                    escreva "[CADASTRO] 3 - antes do hash"
                    variavel senhaCriptografada = cripto.hashSenha(senha, 10)
                    escreva "[CADASTRO] 4 - depois do hash"

                    escreva "[CADASTRO] 5 - antes do insert"
                    
                    # Correção: Usando mysql.executar direto do escopo global
		    escreva "[DEBUG BIND] Nome: " + nome
                    escreva "[DEBUG BIND] Email: " + emailNormalizado
                    escreva "[DEBUG BIND] Senha Hash: " + senhaCriptografada
#		    mysql.executar("USE api_db", [])

                    variavel inserirUsuario = aguardar  conn.executar("INSERT INTO usuarios (nome, email, senha) VALUES (?,?,?)", [nome, emailNormalizado, senhaCriptografada])
                    escreva "[CADASTRO] 5 - insert executado"
                    escreva inserirUsuario

                    res.json(201, {
                        "Status": "Sucesso", 
                        "Mensagem": "Usuário cadastrado com sucesso! faça login para continuar"
                    })
                    escreva sucesso("[CADASTRO] Usuário cadastrado: " + emailNormalizado)
                fim
            fim
        senao:
            res.json(405, {"Status": "Erro", "Mensagem": "Método não permitido"})
            escreva erro("[CADASTRO] Método não permitido: " + req.metodo)
        fim
    capturar (erroFatal):
        # Se qualquer coisa falhar (escopo, nulo, banco), a API responde sem cair
        escreva erro("[CADASTRO CRITICAL ERROR]: " + erroFatal)
        res.json(500, {"Status": "Erro", "Mensagem": "Erro interno no servidor", "Detalhe": erroFatal})
    fim
fim

exportar { rotaCadastro }
