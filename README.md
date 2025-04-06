# Sistema de Gerenciamento de Dinâmicas de Equipe

Este projeto em Ruby on Rails com Docker e PostgreSQL gerencia dinâmicas de equipe, permitindo criar, editar, remover, visualizar e avaliar dinâmicas com estrelas. Abaixo está a lógica de como desenvolvi o projeto do zero e como rodá-lo.

* * *

## Lógica de Desenvolvimento

### 1\. Objetivo

Criei uma aplicação web para gerenciar dinâmicas de equipe, com CRUD básico, avaliações (notas de 1 a 5) e sorteio aleatório. Escolhi Rails por sua rapidez e Docker para consistência no Windows.

### 2\. Configuração Inicial

*   Usei Docker Compose para isolar Ruby e PostgreSQL, com volumes para desenvolvimento no host.

*   Configurei o Rails com PostgreSQL, usando env\_file: .env no docker-compose.yml para variáveis de ambiente.

*   Adicionei develop.watch para rebuild automático em mudanças.

### 3\. Estrutura do Banco

*   **Dynamic**: Nome e descrição, com has\_many :reviews.

*   **Review**: Comentário e nota, com belongs\_to :dynamic.

*   Criei average\_rating em Dynamic para média das notas (0 se vazio).

*   Gereei modelos e migrações com rails g model e rodei rails db:migrate.

### 4\. Controladores e Rotas

*   **DynamicsController**: CRUD (index, show, new, create, edit, update, destroy) e random.

*   **ReviewsController**: create para avaliações aninhadas.

*   Rotas com resources :dynamics, random como coleção e reviews aninhado (only: \[:create\]).

### 5\. Views e Estilo

*   **Index**: Lista dinâmicas com estrelas (média), nome, descrição e ações.

*   **Show**: Detalhes, reviews e formulário de avaliação.

*   Usei <span class="filled"> para estrelas douradas e <span> para cinza no CSS.

*   Formulários em new e edit 

### 6\. Resolução de Problemas

*   Corrigi migrações com rails db:migrate.

*   Ajustei links (ex.: destroy\_dynamic\_path → dynamic\_path com method: :delete).

*   Garanti estilização das estrelas com CSS.

* * *

## Como Rodar

### Pré-requisitos

*   Docker e Docker Compose.
  
### Passos

1. **Clone ou Crie o Projeto**:

```bash 
 git clone <URL> # ou configure manualmente cd fullstack-ruby-on-rails-challenge
```

 2.  **Configure o .env**: Crie um arquivo .env na raiz com:

```.env
 # PostgreSQL Configuration
 POSTGRES_USER=postgres 
 POSTGRES_PASSWORD=password
 POSTGRES_DB=team_dynamics_development
 # Rails Configuration 
 RAILS_ENV=development
 DATABASE_URL=postgres://postgres:password@db/team_dynamics_development
```
	
 3.  **Inicie os Serviços**:
```bash
 docker-compose build
 docker-compose up -d
```
 
 4.  **Configure o Banco**:

```bash
 docker-compose exec web rails db:create
 docker-compose exec web rails db:migrate
```
 5.  **Acesse**:   Abra http://localhost:3000.

 6.  **Pare**: 
```bash
 docker-compose down
```

* * *

### Estrutura do base projeto



```ruby
team_dynamics/
├── app/
│   ├── controllers/
│   │   ├── dynamics_controller.rb
│   │   └── reviews_controller.rb
│   ├── models/
│   │   ├── dynamic.rb
│   │   └── review.rb
│   ├── views/
│   │   ├── dynamics/
│   │   │   ├── index.html.erb
│   │   │   ├── show.html.erb
│   │   │   ├── new.html.erb
│   │   │   ├── edit.html.erb
│   └── assets/
│       └── stylesheets/
│           └── application.css
├── config/
│   ├── routes.rb
│   └── database.yml
├── db/
│   └── migrate/
├── .env
├── docker-compose.yml
└── Dockerfile
```


* * *

## Conclusão

Desenvolvi o projeto configurando Docker e .env, definindo modelos e relações, criando controladores e rotas, e estilizando views. Testei com docker-compose up, corrigindo erros iterativamente, resultando em um sistema funcional para dinâmicas com avaliações visuais.

---

### Notas sobre o docker-compose.yml

- **env_file: .env**: Carrega variáveis do .env para web e db.
- **develop.watch**: Rebuild automático em mudanças no código.
- **Volumes**: .:/app mapeia o diretório local, e postgres_data persiste o banco.
