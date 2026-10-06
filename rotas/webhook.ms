# rotas/webhook.ms
variavel rotaWebhook = funcao(req, res, conn, config):
    se req.metodo != "POST":
        retorna res.json(405, {"Status": "Erro", "Mensagem": "Metodo nao permitido"})
    fim

    variavel chave = req.cabecalhos["authorization"]

    se chave != config["WEBHOOK_KEY"]:
        escreva erro("[WEBHOOK] Chave invalida")
        retorna res.json(401, {"Status": "Erro", "Mensagem": "Nao autorizado"})
    fim

    variavel evento = req.corpo
    escreva sucesso("[WEBHOOK] " + evento.type)

    res.json(200, {"Status": "Sucesso"})
fim

exportar { rotaWebhook }