variavel rotaPayment = funcao(req, res, config, conn, data):
    # Configurações do ZumboPay  
    variavel mpesa_url = "https://zumbopay.com/api/public/v1"  
    variavel api_token = config["ZUMBOPAY_API_KEY"]  
    variavel wallet_id = config["ZUMBOPAY_WALLET_MPESA"]  
    variavel webook_token = config["ZUMBOPAY_WEBHOOK_SECRET"]  
    variavel merchant_id = config["ZUMBOPAY_MERCHANT_ID"]  

    # Extração direta dos dados enviados pelo curl
    variavel valor = req.corpo.valor  
    variavel telefone = req.corpo.telefone  

    se valor == nulo ou telefone == nulo:  
        res.json(400, {  
            "Status": "Erro",  
            "Mensagem": "Parametros obrigatorios nao fornecidos",  
            "Parametros_Obrigatorios": ["valor", "telefone"]  
        })  
    senao:  
        se valor < 10:  
            res.json(400, {  
                "Status": "Erro",  
                "Mensagem": "Valor minimo para pagamento é 10 MZN"  
            })  
        senao:  
            se telefone == "" ou telefone == nulo:  
                res.json(400, {  
                    "Status": "Erro",  
                    "Mensagem": "Telefone é obrigatorio"  
                })  
            senao:  
                variavel source_id = "mpesa_" + data.timestamp()  
                  
                # Dispara a chamada HTTP para o ZumboPay  
                variavel response = http.post(mpesa_url + "/charges", {  
                    "headers": {  
                        "Authorization": "Bearer " + api_token,  
                        "X-Merchant-Id": merchant_id,  
                        "Content-Type": "application/json",  
                        "Idempotency-Key": source_id  
                    },  
                    "body": {  
                        "wallet_id": wallet_id,  
                        "amount": valor,  
                        "currency": "MZN",  
                        "msisdn": telefone,  
                        "callback_url": "https://seusite.com" + webook_token,  
                        "source_id": source_id  
                    }  
                })  

                variavel response_data = response.corpo  

                se response.codigoStatus == 200 ou response_data.status == 200:  
                    res.json(200, {  
                        "Status": "OK",  
                        "Mensagem": "Pagamento iniciado com sucesso...",  
                        "Dados_Pagamento": response_data  
                    })  
                senao:  
                    res.json(400, {  
                        "Status": "Erro",  
                        "Mensagem": "Falha ao iniciar pagamento junto ao provedor",  
                        "Dados_Pagamento": response_data  
                    })  
                fim  
            fim  
        fim  
    fim  
fim
