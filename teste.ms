# arquivo de teste para isolar o conn.executar
# teste.ms

importar { mysql } de "./index" # ou como você importa seu módulo de conexão

# 1. Simula os dados de teste
variavel nome = "Usuario Teste"
variavel emailNormalizado = "eliotech@example.com"
variavel senhaCriptografada = "senha_hash_mock"

escreva "[TESTE] Iniciando teste de execução no banco..."

# 2. Roda o bloco isolado com a sintaxe oficial do MambaScript
tente:
    escreva "[TESTE] Tentando rodar o conn.executar..."
    variavel inserirUsuario = aguardar mysql.executar("INSERT INTO usuarios (nome, email, senha) VALUES (?,?,?)", [nome, emailNormalizado, senhaCriptografada])
    escreva "[TESTE] Sucesso! Resultado do banco"
    variavel verUsers = aguardar mysql.consultar("SELECT * FROM  usuarios")
    escreva verUsers
capturar  (erroCapturado):
    
    escreva "[TESTE] Erro capturado na execução:"
    escreva erroCapturado
fim

escreva "[TESTE] Script finalizado."
