funcao pagamentoMpesa(req, res, conn, config, jwt):
    se req.metodo == "POST":

        variavel jwt_secret = config["JWT_SECRET"]
        variavel api_url = config["API_URL"]
        variavel api_key = config["MPESA_API_KEY"]
        variavel order_id = "ORD-ELIOBROSTECH_" + hoje().timestamp() + "_" + matematica.aleatorio(10000, 99999)
        
        variavel auth = req.cabecalhos.authorization
        se auth == nulo:
            res.json(401, {
                "success": falso,
                "Status": "Erro",
                "erro": "Token nao fornecido!"
            })
            retorne
        fim

        variavel token = auth.substituir("Bearer ", "")

        variavel dadosUsuario = aguardar jwt.verificar(token, jwt_secret)

        se dadosUsuario == nulo:
            res.json(401, {
                "Status": "Erro",
                "message": "Token invalido ou expirado!"
            })
        fim

        variavel response = aguardar http.post(api_url + "/developer/payment/request", {
            "headers": {
                "X-SK-ID": sk_id,
                "X-API-KEY": api_key,
                "Content-Type": "application/json"
            },
            "body": {
                "msisdn": numero,
                "amount": valor,
                "currency": "MZN",
                "description": "Teste de pagamento em MambaScript",
                "order_id": order_id
            }
        })

        
    
        se response.ok:
            res.json(200, {
                "success": verdadeiro,
                "message": "Ordem de pagamento iniciado com sucesso",
                "resposta_api": response
            })
        senao:
            res.json(400, {
                "Status": "Erro",
                "message": "Falha ao iniciar o pagamento",
                "erro": response.messsge
            })
        fim
    fim


fim