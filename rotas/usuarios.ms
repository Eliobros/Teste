variavel rotaUsuarios = funcao(req, res, conn):
    # Exemplo de resposta simulada por enquanto
    variavel respostaUsuarios = {
        "Status": "Sucesso",
        "Rota": "/users",
        "Dados": [
            {"id": 1, "nome": "Mamba Dev"}
        ]
    }
    res.json(200, respostaUsuarios)
fim
