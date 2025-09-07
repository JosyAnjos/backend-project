# 🛒 Shopping Cart API

API em Ruby on Rails para gerenciamento de carrinhos de compras.
Suporta **adicionar/remover produtos**, cálculo automático de total, controle de abandono/expiração e integração com **Sidekiq** para processamento assíncrono.

---

## ⚙️ Tecnologias

- [Ruby 3.3](https://www.ruby-lang.org)
- [Rails 7](https://rubyonrails.org)
- [PostgreSQL](https://www.postgresql.org)
- [Sidekiq](https://sidekiq.org) (jobs assíncronos)
- [Redis](https://redis.io) (fila do Sidekiq)
- [RSpec](https://rspec.info) (testes)
- [FactoryBot](https://github.com/thoughtbot/factory_bot) (fixtures)
- [Docker](https://www.docker.com) e [docker-compose](https://docs.docker.com/compose/)

---

## 📦 Setup do Projeto

### 1. Clonar o repositório
```bash
git clone https://github.com/JosyAnjos/backend-project.git
cd backend-project
```

### 2. Configurar variáveis de ambiente
Crie um arquivo `.env` na raiz do projeto (ou ajuste `docker-compose.yml` diretamente):

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=shopping_cart_api
```

### 3. Subir os containers
```bash
docker compose build
docker compose up
```

Isso sobe:
- API Rails (`http://localhost:3000`)
- Banco PostgreSQL
- Redis
- Sidekiq Dashboard (`http://localhost:3000/sidekiq`)

### 4. Criar o banco e rodar migrations
```bash
docker compose run --rm api rails db:create db:migrate
```

---

## 🧪 Rodando os Testes

O projeto usa **RSpec** para testes unitários e de request.

```bash
docker compose run --rm api bundle exec rspec
```

Exemplo de saída esperada:

```
Finished in 1.23 seconds
52 examples, 0 failures
```

---

## 🛠️ Estrutura do Projeto

- `app/models/cart.rb` → regras de negócio (adicionar/remover produtos, abandono, expiração).
- `app/controllers/carts_controller.rb` → controle HTTP.
- `app/serializers` → serialização de resposta JSON.
- `app/jobs` → jobs Sidekiq.
- `spec/` → testes RSpec.

---
