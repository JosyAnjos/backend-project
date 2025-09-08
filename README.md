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

Documentação dos Endpoints do Carrinho (Carts Controller)

  Para testar e interagir com os endpoints do carrinho via curl, assumindo que sua aplicação Rails está rodando em http://localhost:3000.

  1. `GET /cart` - Listar itens do carrinho atual

  Este endpoint retorna o estado atual do carrinho. Se não houver um carrinho associado à sessão, um novo será criado e retornado.

   1 curl -X GET http://localhost:3000/cart

  Exemplo de Resposta:
  
  ```

    1 {
    2   "id": 123,
    3   "total_price": "25.90",
    4   "cart_items": [
    5     {
    6       "id": 456,
    7       "name": "Nome do Produto A",
    8       "quantity": 2,
    9       "unit_price": "10.00",
   10       "total_price": "20.00"
   11     },
   12     {
   13       "id": 789,
   14       "name": "Nome do Produto B",
   15       "quantity": 1,
   16       "unit_price": "5.90",
   17       "total_price": "5.90"
   18     }
   19   ]
   20 }
   
```


  2. `POST /cart` - Registrar/Alterar quantidade de produtos no carrinho

  **Este endpoint** permite adicionar um produto ao carrinho ou atualizar a quantidade de um produto existente.

  Payload de Exemplo:
  
  ```

   1 {
   2   "product_id": 1,   // ID do produto a ser adicionado/atualizado
   3   "quantity": 1      // Quantidade a ser adicionada (será somada à quantidade existente)
   4 }

```

  Exemplo de Uso (Adicionar um novo produto):

   1 # Primeiro, obtenha um ID de produto válido (ex: curl http://localhost:3000/products)
   
   2 curl -X POST -H "Content-Type: application/json" -d '{"product_id": 1, "quantity": 1}' http://localhost:3000/cart

  Exemplo de Uso (Atualizar quantidade de produto existente):

   1 # Se o produto com product_id=1 já estiver no carrinho, a quantidade será incrementada
   
   2 curl -X POST -H "Content-Type: application/json" -d '{"product_id": 1, "quantity": 2}' http://localhost:3000/cart

  Exemplo de Resposta:
  (A resposta será o objeto completo do carrinho, similar ao GET /cart, com o produto atualizado e o total_price recalculado.)

```
    1 {
    2   "id": 123,
    3   "total_price": "45.90",
    4   "cart_items": [
    5     {
    6       "id": 456,
    7       "name": "Nome do Produto A",
    8       "quantity": 3,  // Quantidade atualizada
    9       "unit_price": "10.00",
   10       "total_price": "30.00"
   11     },
   12     {
   13       "id": 789,
   14       "name": "Nome do Produto B",
   15       "quantity": 1,
   16       "unit_price": "5.90",
   17       "total_price": "5.90"
   18     }
   19   ]
   20 }
```

  3. `DELETE /cart/:product_id` - Remover um produto do carrinho

  **Este endpoint** remove um produto específico do carrinho com base no seu product_id.

  Exemplo de Uso:

   1 # Substitua '1' pelo ID do produto que você deseja remover do carrinho
   
   2 curl -X DELETE http://localhost:3000/cart/1

  Exemplo de Resposta:
  (A resposta será o objeto completo do carrinho, com o produto removido e o total_price recalculado.)
  
```
    1 {
    2   "id": 123,
    3   "total_price": "5.90",
    4   "cart_items": [
    5     {
    6       "id": 789,
    7       "name": "Nome do Produto B",
    8       "quantity": 1,
    9       "unit_price": "5.90",
   10       "total_price": "5.90"
   11     }
   12   ]
   13 }

```

---


## 🛠️ Estrutura do Projeto

- `app/models/cart.rb` → regras de negócio (adicionar/remover produtos, abandono, expiração).
- `app/controllers/carts_controller.rb` → controle HTTP.
- `app/serializers` → serialização de resposta JSON.
- `app/jobs` → jobs Sidekiq.
- `spec/` → testes RSpec.

---
