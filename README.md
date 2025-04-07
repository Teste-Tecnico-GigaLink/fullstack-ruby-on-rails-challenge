# Sistema de Gerenciamento de Dinâmicas de Equipe

Este projeto em Ruby on Rails com Docker e PostgreSQL gerencia dinâmicas de equipe, permitindo criar, editar, remover, visualizar e avaliar dinâmicas com estrelas. Inclui logs e monitoramento com Loki, Promtail, Prometheus e Grafana, e usa Redis como cache e armazenamento temporário. Abaixo está a lógica de desenvolvimento e instruções para rodar e configurar o projeto.

---

## Lógica de Desenvolvimento

### 1. Objetivo

Criei uma aplicação web para gerenciar dinâmicas de equipe, com CRUD básico, avaliações (notas de 1 a 5) e sorteio aleatório. Escolhi Rails por sua rapidez, Docker para consistência no Windows, Redis para caching e Loki/Prometheus/Grafana para monitoramento.

### 2. Configuração Inicial

- Usei Docker Compose para isolar Ruby, PostgreSQL, Redis, Loki, Promtail, Prometheus e Grafana, com volumes para desenvolvimento no host.
- Configurei o Rails com PostgreSQL e Redis, usando env_file: .env no docker-compose.yml para variáveis de ambiente.
- Adicionei develop.watch para rebuild automático em mudanças.

### 3. Estrutura do Banco e Cache

- **Dynamic**: Nome e descrição, com has_many :reviews.
- **Review**: Comentário e nota, com belongs_to :dynamic.
- Criei average_rating em Dynamic para média das notas (0 se vazio).
- Gereei modelos e migrações com rails g model e rodei rails db:migrate.
- **Redis**: Usado como cache para melhorar performance (ex.: armazenar médias de avaliações temporariamente) e para dados efêmeros.

### 4. Controladores e Rotas

- **DynamicsController**: CRUD (index, show, new, create, edit, update, destroy) e random.
- **ReviewsController**: create para avaliações aninhadas.
- Rotas com resources :dynamics, random como coleção e reviews aninhado (only: [:create]).

### 5. Views e Estilo

- **Index**: Lista dinâmicas com estrelas (média), nome, descrição e ações.
- **Show**: Detalhes, reviews e formulário de avaliação.
- Usei <span class="filled"> para estrelas douradas e <span> para cinza no CSS.
- Formulários em new e edit.

### 6. Sistema de Logs e Monitoramento

- **Loki**: Armazena e gerencia logs da aplicação.
- **Promtail**: Coleta logs dos containers Docker e os envia ao Loki.
- **Prometheus**: Monitora métricas do sistema (ex.: performance do Rails e Prometheus).
- **Grafana**: Interface para visualizar logs e métricas.
- Configurei o driver de log loki no serviço web para enviar logs diretamente ao Loki.

### 7. Integração com Redis

- **Propósito**: Redis é usado para caching de dados frequentemente acessados (ex.: lista de dinâmicas ou médias de avaliações) e para tarefas temporárias, como sessões ou filas (se aplicável).
- **Configuração**: Adicionado ao docker-compose.yml como serviço redis, com porta padrão 6379 e volume persistente.
- **Uso no Rails**: Configurado como cache store no Rails (ex.: config.cache_store = :redis_cache_store) ou para bibliotecas como Sidekiq (se expandido).

### 8. Resolução de Problemas

- Corrigi migrações com rails db:migrate.
- Ajustei links (ex.: destroy_dynamic_path → dynamic_path com method: :delete).
- Garanti estilização das estrelas com CSS.
- Validei a configuração de logs e Redis testando no Grafana e Rails console.

---

## Como Rodar

### Pré-requisitos

- Docker e Docker Compose.

### Passos

1. **Clone ou Crie o Projeto**:
    
    ```bash
   git clone <URL> # ou configure manualmente cd fullstack-ruby-on-rails-challenge
    ```
    
3. **Configure o .env**:

    ```# PostgreSQL Configuration POSTGRES_USER=postgres POSTGRES_PASSWORD=password POSTGRES_DB=team_dynamics_development # Rails Configuration RAILS_ENV=development DATABASE_URL=postgres://postgres:password@db/team_dynamics_development # Redis Configuration REDIS_URL=redis://redis:6379/0```
    
4. **Configure os Arquivos de Logs e Monitoramento**:
    
    - Crie promtail-config.yaml na raiz com o conteúdo fornecido anteriormente.
    - Crie prometheus.yml na raiz com o conteúdo fornecido anteriormente.
5. **Inicie os Serviços**:
    
    ```bash
   docker-compose build docker-compose up -d
    ```
    
7. **Configure o Banco**:  
    
    ```bash
    docker-compose exec web rails db:create
    docker-compose exec web rails db:migrate
    ```
    
9. **Acesse a Aplicação e Monitoramento**:
    
    - Aplicação: Abra http://localhost:3000.
    - Grafana (logs e métricas): Abra http://localhost:3001 (usuário padrão: admin, senha: admin).
    - Prometheus: Abra http://localhost:9090.
    - Loki: Logs são acessados via Grafana.
    - Redis: Teste via docker-compose exec redis redis-cli ou no Rails com Rails.cache.
10. **Pare os Serviços**:
   
    ```bash
    docker-compose down
    ```

---

## Configuração de Logs, Monitoramento e Redis

### Logs

1. **Promtail**:
    - O arquivo promtail-config.yaml define como os logs dos containers Docker são coletados e enviados ao Loki.
    - Usa docker_sd_configs para descobrir containers e relabel_configs para labels como container e job.
2. **Loki**:
    - Configurado no docker-compose.yml com -config.file=/etc/loki/local-config.yaml.
    - Recebe logs do Promtail e do driver loki no serviço web.
3. **Driver de Log no Rails**:
    - No serviço web:
        
        ```json
      logging: driver: loki options: loki-url: "http://loki:3100/loki/api/v1/push" loki-external-labels: "job=rails_app"
        ```
        
4. **Grafana**:

- **Acesso**: http://localhost:3001
- **Credenciais**: Usuário admin, senha admin (altere na primeira vez, se solicitado).

### Pesquisando Logs com a URL

- **URL**: http://localhost:3001/explore?...
    - Filtra logs do container fullstack-ruby-on-rails-challenge-web-1 (serviço web) das últimas 6 horas no Loki.
    - Mostra "Time" e "Line".
- **Uso**:
    1. Logue com admin:admin.
    2. Cole a URL no navegador.
    3. Veja os logs ou ajuste:
        - Ex.: {container="/fullstack-ruby-on-rails-challenge-web-1"} |= "error" (filtra erros).
        - Mude o intervalo no topo (ex.: "Last 1h").
    4. Clique em "Run Query".

### Configuração Manual (se necessário)

- No Grafana, vá em **Explore**.
- Selecione **Loki** (http://loki:3100).
- Digite {container="/fullstack-ruby-on-rails-challenge-web-1"} ou {job="rails_app"}.
- Ajuste o tempo e clique em "Run Query".
5. **Prometheus**:
    - Configurado em prometheus.yml para métricas do Prometheus (expansível para Rails).

### Redis

1. **Configuração no Docker**:
    - Definido no docker-compose.yml:
        
        ```ruby
      redis: image: redis:latest ports: - "6379:6379" volumes: - redis_data:/data networks: - app_network
        ```
        
    - Porta 6379 exposta e volume redis_data para persistência.
2. **Integração com Rails**:
    - Adicione ao config/environments/development.rb:
        
        `config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }`
        
    - Teste no console (rails c):
        
        ```ruby
         Rails.cache.write("test_key", "Hello Redis") Rails.cache.read("test_key") # => "Hello Redis"
        ```
        
3. **Uso Prático**:
    - Cache de consultas frequentes: Rails.cache.fetch("dynamics_list", expires_in: 5.minutes) { Dynamic.all.to_a }.
    - Expansível para Sidekiq (filas) ou ActionCable (websockets).

---

### Estrutura do Projeto


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
├── Dockerfile
├── promtail-config.yaml
└── prometheus.yml
```

---

## Conclusão

Desenvolvi o projeto configurando Docker,logs com Loki/Promtail/Grafana/Prometheus e caching com Redis. Testei com docker-compose up, corrigindo erros iterativamente, resultando em um sistema funcional, monitorado e otimizado.

---

### Notas sobre o docker-compose.yml

- **env_file: .env**: Carrega variáveis para web e db.
- **develop.watch**: Rebuild automático em mudanças.
- **Volumes**: .:/app mapeia o diretório local; redis_data, postgres_data, etc., persistem dados.
- **Redis**: Dependência do web para caching e escalabilidade.

---
