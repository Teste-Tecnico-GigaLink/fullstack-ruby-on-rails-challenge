## Configuração de Ambientes

#### Compose para cada ambiebte `docker/compose/`

Vamos usar os aquivos `.ylm` em `docker/compose/` para orquestrar múltiplos containers e configurar serviços Docker especificos de cada ambiebte

- Production (Produção). `production.yml`

- Development (Desenvolvimento). `development.yml`

- Homolog (Homologação). `homolog.yml`

```
root

├─> docker/

│   └─>  compose/

│   │    └─>  development.yml

│   │    └─>  homolog.yml

│   │    └─>  production.yml
```

#### Variáveis de ambiente para cada ambiente `.env`

Os aquivos de variáveis de ambiente são definidos separadamente nessa estrutura:

- Production (Produção). `.development.env`

- Development (Desenvolvimento). `.homolog.env`

- Homolog (Homologação). `.production.env`

```
|─>  root

|    └─> docker/

|    │   └─>  env/

|    │   │    └─> .development.env

|    │   │    └─> .homolog.env

|    │   │    └─> .production.env
```

#### Variáveis de ambiente de examplo examplo para cada ambiente `.env.example`

Os aquivos de variáveis de `.env.example` para cada ambiente que podem ser commitados no repositório:

- Production example (`env` de examplo para Produção). `.development.env.example`

- Development example (`env` de examplo para Desenvolvimento). `.homolog.env.example`

- Homolog example (`env` de exampl0 para Homologação). `.production.env.example`

```
|─>  root

|    └─> docker/

|    │   └─>  env/

|    │   │    └─> .development.env.example

|    │   │    └─> .homolog.env.example

|    │   │    └─> .production.env.example
```

#### Aquivos comuns a todos os ambiente `Dockerfile` `docker-compose.yml ` `entrypoint.sh`

Na raiz do projeto vão ficar os aquivos comuns a todos os ambientes:

- Dockerfile (arquivo de configuração usado para construir uma imagem Docker). `Dockerfile`

- Compose (orquestrar múltiplos containers e configurar serviços Docker). `docker-compose.yml`

- Entrypoint (script de inicialização para configurar e executar o container antes de rodar o comando principal.). `entrypoint.sh`

```
├─> root

├── Dockerfile

├── docker-compose.yml

├── entrypoint.sh

└── .dockerignore
```

### Como Utilizar:

#### 1. Script de Setup:

- #### Script de setup antes de subir os ambientes `bin/setup-env.sh`

No diretorio `/bin` na raiz do ficar o script `setup-env.sh` para para configuração das `envs`:

```bash
#!/bin/bash

echo "Configurando arquivos de ambiente..."

# Cria os arquivos se não existirem

for env in development homolog production; do

if [ ! -f "docker/env/.$env.env" ]; then

cp "docker/env/.$env.env.example" "docker/env/.$env.env"

echo "Arquivo docker/env/.$env.env criado"

else

echo "Arquivo docker/env/.$env.env já existe - mantido"

fi

done

echo "✅ Configuração completa!"

echo "⚠️  Edite os arquivos .env com suas credenciais antes de continuar"
```

#### 2. Copie os arquivos de exemplo (opcional):

```bash
cp docker/env/.development.env.example docker/env/.development.env

cp docker/env/.homolog.env.example docker/env/.homolog.env

cp docker/env/.production.env.example docker/env/.production.env
```

#### 3. Rodar ambinete docker:

Rode os comandos abixo no ditorio `root` (riz do projeto) no teminal para o ambinete que desja utilizar:

- ##### Desenvolvimento:

```bash
docker-compose -f docker-compose.yml -f docker/compose/development.yml up --build
```

- ##### Homologação:

```bash
docker-compose -f docker-compose.yml -f docker/compose/homolog.yml up -d --build
```

- ##### Produção:

```bash
docker-compose -f docker-compose.yml -f docker/compose/production.yml up -d --build
```
