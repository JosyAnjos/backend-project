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
- [Devise](https://github.com/heartcombo/devise) (autenticação)
- [Active Model Serializers](https://github.com/rails-api/active_model_serializers) (serialização JSON)

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
docker compose run --rm web rails db:create db:migrate
```

---

## 🧪 Rodando os Testes

O projeto usa **RSpec** para testes unitários e de request.

```bash
docker compose run --rm test
```

Exemplo de saída esperada:

```
Finished in X.XX seconds
Y examples, 0 failures
```

---

## 🔐 Autenticação (Devise + Token-based)

A API utiliza autenticação baseada em token via Devise. Cada `User` possui um `authentication_token` que deve ser enviado no cabeçalho `Authorization` para acessar os endpoints protegidos.

**Como obter um token:**
Atualmente, não há um endpoint de registro/login implementado. Para testar, você pode criar um usuário manualmente no console Rails e usar o `authentication_token` gerado:

```bash
docker compose run --rm web rails c
```
Dentro do console:
```ruby
user = User.create!(email: 'test@example.com', password: 'password', password_confirmation: 'password')
puts user.authentication_token
```

Use o token retornado nos seus requests.

---

## 📄 Documentação dos Endpoints de Produtos (Products Controller)

Para testar e interagir com os endpoints de produtos via `curl`, assumindo que sua aplicação Rails está rodando em `http://localhost:3000` e você tem um token de autenticação.

**Cabeçalho de Autenticação:**
Todos os endpoints de produtos exigem o cabeçalho `Authorization` no formato `Token token=<SEU_TOKEN>`.

#### **1. `GET /products` - Listar todos os produtos**

Este endpoint retorna uma lista de todos os produtos cadastrados.

```bash
curl -X GET http://localhost:3000/products \
     -H "Authorization: Token token=<SEU_TOKEN>"
```

**Exemplo de Resposta:**
```json
[
  {
    "id": 1,
    "name": "Nome do Produto A",
    "price": "10.0"
  },
  {
    "id": 2,
    "name": "Nome do Produto B",
    "price": "5.90"
  }
]
```

#### **2. `GET /products/:id` - Exibir um produto**

Este endpoint retorna os detalhes de um produto específico.

```bash
curl -X GET http://localhost:3000/products/1 \
     -H "Authorization: Token token=<SEU_TOKEN>"
```

**Exemplo de Resposta:**
```json
{
  "id": 1,
  "name": "Nome do Produto A",
  "price": "10.0"
}
```

#### **3. `POST /products` - Criar um novo produto**

Este endpoint permite criar um novo produto.

**Payload de Exemplo:**
```json
{
  "name": "Novo Produto",
  "price": 25.0
}
```

**Exemplo de Uso:**
```bash
curl -X POST -H "Content-Type: application/json" \
     -H "Authorization: Token token=<SEU_TOKEN>" \
     -d '{"name": "Novo Produto", "price": 25.0}' http://localhost:3000/products
```

**Exemplo de Resposta:**
```json
{
  "id": 3,
  "name": "Novo Produto",
  "price": "25.0"
}
```

#### **4. `PATCH /products/:id` - Atualizar um produto**

Este endpoint permite atualizar os dados de um produto existente.

**Payload de Exemplo:**
```json
{
  "name": "Produto Atualizado",
  "price": 22.5
}
```

**Exemplo de Uso:**
```bash
curl -X PATCH -H "Content-Type: application/json" \
     -H "Authorization: Token token=<SEU_TOKEN>" \
     -d '{"name": "Produto Atualizado", "price": 22.5}' http://localhost:3000/products/1
```

**Exemplo de Resposta:**
```json
{
  "id": 1,
  "name": "Produto Atualizado",
  "price": "22.5"
}
```

#### **5. `DELETE /products/:id` - Deletar um produto**

Este endpoint remove um produto específico.

**Exemplo de Uso:**
```bash
curl -X DELETE http://localhost:3000/products/1 \
     -H "Authorization: Token token=<SEU_TOKEN>"
```

**Exemplo de Resposta:**
(Não há conteúdo na resposta, apenas o status 204 No Content)

---

## 📄 Documentação dos Endpoints do Carrinho (Carts Controller)

Para testar e interagir com os endpoints do carrinho via `curl`, assumindo que sua aplicação Rails está rodando em `http://localhost:3000` e você tem um token de autenticação.

**Cabeçalho de Autenticação:**
Todos os endpoints do carrinho exigem o cabeçalho `Authorization` no formato `Token token=<SEU_TOKEN>`.

#### **1. `GET /cart` - Listar itens do carrinho atual**

Este endpoint retorna o estado atual do carrinho do usuário autenticado. Se não houver um carrinho associado ao usuário, um novo será criado e retornado.

```bash
curl -X GET http://localhost:3000/cart \
     -H "Authorization: Token token=<SEU_TOKEN>"
```

**Exemplo de Resposta:**
```json
{
  "id": 123,
  "total_price": "25.90",
  "cart_items": [
    {
      "id": 456,
      "name": "Nome do Produto A",
      "quantity": 2,
      "unit_price": "10.00",
      "total_price": "20.00"
    },
    {
      "id": 789,
      "name": "Nome do Produto B",
      "quantity": 1,
      "unit_price": "5.90",
      "total_price": "5.90"
    }
  ]
}
```

#### **2. `POST /cart` - Registrar/Alterar quantidade de produtos no carrinho**

Este endpoint permite adicionar um produto ao carrinho do usuário autenticado ou atualizar a quantidade de um produto existente.

**Payload de Exemplo:**
```json
{
  "product_id": 1,   // ID do produto a ser adicionado/atualizado
  "quantity": 1      // Quantidade a ser adicionada (será somada à quantidade existente)
}
```

**Exemplo de Uso (Adicionar um novo produto):**
```bash
# Primeiro, obtenha um ID de produto válido (ex: curl http://localhost:3000/products)
curl -X POST -H "Content-Type: application/json" \
     -H "Authorization: Token token=<SEU_TOKEN>" \
     -d '{"product_id": 1, "quantity": 1}' http://localhost:3000/cart
```

**Exemplo de Uso (Atualizar quantidade de produto existente):**

```bash
# Se o produto com product_id=1 já estiver no carrinho, a quantidade será incrementada
curl -X POST -H "Content-Type: application/json" \
     -H "Authorization: Token token=<SEU_TOKEN>" \
     -d '{"product_id": 1, "quantity": 2}' http://localhost:3000/cart
```

**Exemplo de Resposta:**
(A resposta será o objeto completo do carrinho, similar ao `GET /cart`, com o produto atualizado e o `total_price` recalculado.)
```json
{
  "id": 123,
  "total_price": "45.90",
  "cart_items": [
    {
      "id": 456,
      "name": "Nome do Produto A",
      "quantity": 3,  // Quantidade atualizada
      "unit_price": "10.00",
      "total_price": "30.00"
    },
    {
      "id": 789,
      "name": "Nome do Produto B",
      "quantity": 1,
      "unit_price": "5.90",
      "total_price": "5.90"
    }
  ]
}
```

#### **3. `DELETE /cart/:product_id` - Remover um produto do carrinho**

Este endpoint remove um produto específico do carrinho do usuário autenticado com base no seu `product_id`.

**Exemplo de Uso:**
```bash
# Substitua '1' pelo ID do produto que você deseja remover do carrinho
curl -X DELETE http://localhost:3000/cart/1 \
     -H "Authorization: Token token=<SEU_TOKEN>"
```

**Exemplo de Resposta:**
(A resposta será o objeto completo do carrinho, com o produto removido e o `total_price` recalculado.)
```json
{
  "id": 123,
  "total_price": "5.90",
  "cart_items": [
    {
      "id": 789,
      "name": "Nome do Produto B",
      "quantity": 1,
      "unit_price": "5.90",
      "total_price": "5.90"
    }
  ]
}
```

---

## ⚙️ Configurações Personalizadas

Os limiares de tempo para abandono e remoção de carrinhos são configuráveis em `config/application.rb`:

```ruby
# config/application.rb
config.cart_abandonment_threshold_hours = 3 # Horas de inatividade para marcar como abandonado
config.cart_removal_threshold_days = 7    # Dias de abandono para remover o carrinho
```

---

## 🛠️ Estrutura do Projeto

- `app/models/cart.rb` → regras de negócio (adicionar/remover produtos, abandono, expiração).
- `app/models/user.rb` → modelo de usuário para autenticação (Devise).
- `app/controllers/application_controller.rb` → lógica de autenticação por token.
- `app/controllers/carts_controller.rb` → controle HTTP.
- `app/serializers` → serialização de resposta JSON.
- `app/jobs` → jobs Sidekiq.
- `spec/` → testes RSpec.

---
