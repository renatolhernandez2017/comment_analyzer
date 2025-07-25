# Análise de Comentários com Palavras-Chave

Este projeto processa comentários dos usuários, aplicando filtros por palavras-chave e gerando estatísticas por usuário.

---

## 🧱 Arquitetura

- **Ruby on Rails 5.2** – Framework principal.
- **Sidekiq** – Processamento assíncrono de comentários via Jobs.
- **ActionCable (futuramente)** para envio em tempo real do progresso
- **PostgreSQL** – Banco de dados relacional.
- **ActiveJob** – Abstração para fila com Sidekiq.
- **AASM** – Gerenciamento de estados do modelo `Comment`.

**Fluxo principal:**

1. Página principal.
2. Ao salvar ou editar uma palavra-chave, todos os usuários são reprocessados:
   - Cada `Comment` do usuário é analisado.
   - Marca os comentários como `approved` ou `rejected` com base nas keywords.
3. A interface exibe os resultados por usuário.

---

## 📌 Decisões Técnicas

- Utilização da gem `AASM` para controle de estado dos comentários (`new`, `processing`, `approved`, `rejected`)
- Processamento assíncrono com `ProcessUserCommentsJob` para não bloquear a thread principal
- Organização por `User`, permitindo múltiplos usuários simultaneamente
- `Keyword.pluck(:word)` cacheado em memória para performance

---

## 🧠 Decisões de Design

- **Jobs Assíncronos**: Comentários são processados em background para evitar travar a interface.
- **Machine State (AASM)**: `Comment` possui estados `new`, `processing`, `approved`, `rejected`, podendo retornar para `processing`.

---

## 📊 Fórmulas Estatísticas

Durante o processamento, as seguintes estatísticas podem ser calculadas:

- **Frequência de palavras-chave** em cada comentário.
- **Score de conteúdo**:
  ```ruby
  score = (keywords_detectadas.to_f / palavras_totais) * 100

  if score > 0
    aprova
  elsif score < 0
    rejeita
  else
    neutro
  end

  Comentários "neutros" permanecem em processing, podendo ser analisados manualmente ou posteriormente com mais dados

## Como rodar localmente

Necessário ter o VsCode instalado para a execução

- git@github.com:renatolhernandez2017/comment_analyzer.git
- cd comment_analyzer
- code .
- Conectar-se ao Container de Desenvolvimento
- bin/dev
- localhost:3000/

## 📬 Testes de Endpoints

### Listagem de Usuários (Requisição GET)
- https://jsonplaceholder.typicode.com/users

### Criar Usuário (Requisição POST)
- http://localhost:3000/api/users

- **Conteudo do Body**:
  ```ruby
    {
      "username": "Elwyn.Skiles"
    }

### Resultados do Progresso da execução (Requisição GET)
- http://localhost:3000/progress/id-usuario

### Resultados de métricas Individual com Grupo (Requisição GET)
- http://localhost:3000/results/username-usuario

### Resultados de métricas de Grupo (Requisição GET)
- http://localhost:3000/results_groups

### Lista todas as Palavras Chaves (Requisição GET)
- http://localhost:3000/api/keywords

### Criar Palavra Chave (Requisição POST)
- http://localhost:3000/api/keywords

- **Conteudo do Body**:
  ```ruby
    {
      "word": "laudantium"
    }

### Atualizar palavra Chave (Requisição PATCH)
- http://localhost:3000/api/keywords/id-keyword

### Apagar uma Palavra Chave
- http://localhost:3000/api/keywords/id-keyword

- **Conteudo do Body**:
  ```ruby
    {
      "word": "omnis"
    }
