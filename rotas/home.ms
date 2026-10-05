variavel rotaHome = funcao(req, res, conn):
    variavel data = hoje("Africa/Maputo")
    variavel horas = data.horaFormatada()
    variavel dia = data.formatado()

    variavel api_status = "Offline"
    se conn.ok == verdadeiro:
        api_status = "Online"
    fim

    variavel welcome = {
        "Status": "OK",
        "Mensagem": "Bem-vindo a API",
        "Data": dia,
        "Hora": horas,
        "API_Status": api_status
    }

    res.json(200, welcome)
fim
