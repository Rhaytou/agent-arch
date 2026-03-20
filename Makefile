.PHONY: up down docker_clean_all \
        pgv_start pgv_down pgv_restart pgv_logs pgv_bash pgv_psql \
        rds_start rds_down rds_restart rds_logs rds_bash rds_cli \
        olm_start olm_down olm_restart olm_logs olm_bash olm_ps olm_pull \
        llm_start llm_down llm_restart llm_logs llm_bash llm_models \
        n8n_start n8n_down n8n_restart n8n_logs n8n_bash


# ============================================================
# GENERAL WORKFLOW
# ============================================================

up:
	docker compose up -d --build

down:
	docker compose down -v

docker_clean_all:
	docker stop $$(docker ps -aq) 2>/dev/null || true && \
	docker rm -f $$(docker ps -aq) 2>/dev/null || true && \
	docker rmi -f $$(docker images -q) 2>/dev/null || true && \
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true && \
	docker network rm $$(docker network ls -q | grep -v "bridge\|host\|none") 2>/dev/null || true && \
	docker system prune -a --volumes -f


# ============================================================
# PGVECTOR SERVICE
# ============================================================

pgv_start:
	docker compose up -d --build pgvector_service

pgv_down:
	docker compose stop pgvector_service

pgv_restart:
	docker compose restart pgvector_service

pgv_logs:
	docker compose logs -f pgvector_service

pgv_bash:
	docker exec -it pgvector_container bash

pgv_psql:
	docker exec -it pgvector_container psql -U $${POSTGRES_USER} -d $${POSTGRES_DB}


# ============================================================
# REDIS SERVICE
# ============================================================

rds_start:
	docker compose up -d --build redis_service

rds_down:
	docker compose stop redis_service

rds_restart:
	docker compose restart redis_service

rds_logs:
	docker compose logs -f redis_service

rds_bash:
	docker exec -it redis_container sh

rds_cli:
	docker exec -it redis_container redis-cli -a $${REDIS_PASSWORD}


# ============================================================
# OLLAMA SERVICE
# ============================================================

olm_start:
	docker compose up -d --build ollama_service

olm_down:
	docker compose stop ollama_service

olm_restart:
	docker compose restart ollama_service

olm_logs:
	docker compose logs -f ollama_service

olm_bash:
	docker exec -it ollama_container sh

olm_ps:
	docker exec -it ollama_container ollama ps

## Pull a specific model manually — usage: make olm_pull MODEL=llama3.2:3b
olm_pull:
	docker exec -it ollama_container ollama pull $(MODEL)


# ============================================================
# LITELLM SERVICE
# ============================================================

llm_start:
	docker compose up -d --build litellm_service

llm_down:
	docker compose stop litellm_service

llm_restart:
	docker compose restart litellm_service

llm_logs:
	docker compose logs -f litellm_service

llm_bash:
	docker exec -it litellm_container bash

## List all models available via LiteLLM proxy
llm_models:
	curl -s http://localhost:4000/models -H "Authorization: Bearer $${LITELLM_MASTER_KEY}" | python3 -m json.tool


# ============================================================
# N8N SERVICE
# ============================================================

n8n_start:
	docker compose up -d --build n8n_service

n8n_down:
	docker compose stop n8n_service

n8n_restart:
	docker compose restart n8n_service

n8n_logs:
	docker compose logs -f n8n_service

n8n_bash:
	docker exec -it n8n_container sh










