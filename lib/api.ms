importar http de "http"

variavel apiClient = funcao(req, res, config):
    variavel secret_key = config["API_SECRET_KEY"]
    variavel api_url = config["API_URL"]
    variavel channel_id = config["API_CHANNEL_ID"]
    variavel dados = req.corpo

    se req.metodo != "POST":
        res.json(405, {
            "success": falso,
            "message": "Método não permitido"
        })
    senao:
        se dados == nulo:
            dados = {}
        fim

        variavel valor = dados.amount
        variavel cotacao = dados.currency
        variavel customerEmail = dados.customerEmail
        variavel customerName = dados.customerName

        se valor == nulo:
            valor = 100
        fim

        se cotacao == nulo:
            cotacao = "USD"
        fim

        se customerEmail == nulo ou customerName == nulo:
            res.json(400, {
                "success": falso,
                "message": "Informe customerName e customerEmail"
            })
        senao:
            tente:
                variavel response = aguardar http.post(api_url + "/hosted-payments", {
                "amount": valor,
                "currency": cotacao,
                "processing_channel_id": channel_id,
                "reference": "ORD-ELIOBROSTECH_" + hoje().timestamp(),
                "billing": {
                    "address": {
                        "country": "MZ"
                    }
                },
                "customer": {
                    "name": customerName,
                    "email": customerEmail
                },
                "success_url": "https://example.com/success",
                "failure_url": "https://example.com/failure",
                "cancel_url":  "https://example.com/cancel"
                }, {
                "Authorization": "Bearer " + secret_key,
                "Content-Type": "application/json",
                })

                se response.ok:
                res.json(200, {
                    "success": verdadeiro,
                    "message": "Pagamento iniciado com sucesso",
                    "id": response.corpo.id,
                    "link de pagamento": response.corpo._links.redirect.href
                })
                senao:
                res.json(response.status, {
                    "success": falso,
                    "message": "Falha ao iniciar o pagamento",
                    "detalhes": response.corpo
                })
                fim
            capturar(falha):
                escreva erro("Erro ao iniciar checkout: " + falha)
                res.json(500, {
                "success": falso,
                "message": "Erro interno ao processar o checkout"
                })
            fim
        fim
    fim
fim

exportar { apiClient }
