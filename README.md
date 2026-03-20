# agent-arch

A production-ready Docker infrastructure template for building AI agent systems. Spin up a fully working local AI stack — with local and cloud LLM support, vector memory, caching, and a visual workflow engine — in a single command.

---

## Overview

**agent-arch** provides the infrastructure layer every AI agent project needs but rarely gets right. Instead of wiring databases, LLM providers, and orchestration tools from scratch on every project, this template gives you a clean, pre-configured, extensible base to build on top of.

The stack is designed around one principle: **agents should be stateless, everything else handles state for them.**

---

## Architecture

```
EXTERNAL WORLD
      │
      ▼
  n8n :5678              ← entry point + agent workflow orchestration
      │
      ▼
  LiteLLM :4000          ← unified LLM proxy (provider agnostic)
      │
   ┌──┴──────────────┐
Ollama :11434     OpenAI / Anthropic / Groq
(local models)    (cloud providers)

  Redis :6379            ← short-term memory + session cache
  Postgres :5432         ← long-term vector memory + task logs + LLM usage
```

---

## Services

| Service | Image | Port | Role |
|---|---|---|---|
| `pgvector` | `pgvector/pgvector:0.8.0-pg17` | `5432` | Long-term memory, vector store, task tracking |
| `redis` | `redis:7.2-alpine` | `6379` | Short-term memory, session cache |
| `ollama` | `ubuntu:24.04` | `11434` | Local LLM runtime |
| `litellm` | `ghcr.io/berriai/litellm` | `4000` | Unified LLM proxy |
| `n8n` | `n8nio/n8n:latest` | `5678` | Agent workflow orchestration |

---

## Database Schema

Four tables are pre-initialized in Postgres at first boot:

- **`agent_memory`** — long-term vector memory with pgvector embeddings (1536 dimensions)
- **`agent_tasks`** — full task lifecycle tracking (pending → running → done/failed)
- **`agent_logs`** — structured event log for every agent action
- **`llm_usage`** — token usage and cost tracking per agent and model

n8n uses its own isolated `n8n` schema in the same Postgres instance, keeping agent data clean and separate.

---

## LLM Providers

All LLM calls go through LiteLLM. Agents never call providers directly.

| Provider | Models |
|---|---|
| Ollama (local) | `llama3.2:1b`, `llama3.2:3b`, `phi3:mini`, `gemma2:2b`, `qwen2.5:3b` |
| OpenAI | `gpt-4o`, `gpt-4o-mini` |
| Anthropic | `claude-3-5-sonnet`, `claude-3-5-haiku` |
| Groq | `llama3.3-70b`, `llama3.1-8b` |

Swap or add providers by editing `dockerfile/litellm/config.yaml` — no agent code changes needed.

Fallback routing is configured out of the box: if `gpt-4o-mini` or `groq/llama3.1-8b` fail, requests automatically fall back to `ollama/llama3.2:3b`.

---

## Quickstart

**1. Clone and configure**
```bash
git clone https://github.com/Rhaytou/agent-arch.git
cd agent-arch
cp .env.example .env
# Edit .env and fill in your values
```

**2. Start the stack**
```bash
make up
```

**3. Access n8n**
```
http://localhost:5678
```

**4. Test LiteLLM**
```bash
curl -s http://localhost:4000/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-master-key" \
  -d '{
    "model": "ollama/llama3.2:1b",
    "messages": [{"role": "user", "content": "Hello"}]
  }' | python3 -m json.tool
```

> **Note:** On first boot, Ollama pulls all configured models and LiteLLM runs database migrations. This can take several minutes depending on your connection and machine. The stack is ready when `make n8n_logs` shows the server is running.

---

## Environment Variables

Copy `.env.example` to `.env` and fill in your values.

```bash
# PostgreSQL
POSTGRES_USER=agent_user
POSTGRES_PASSWORD=your-password
POSTGRES_DB=agent_db

# Redis
REDIS_PASSWORD=your-password

# Ollama — comma-separated list of models to pull on boot
OLLAMA_MODELS=llama3.2:1b,llama3.2:3b
OLLAMA_KEEP_ALIVE=5m

# LiteLLM
LITELLM_MASTER_KEY=sk-your-key

# Cloud providers — leave empty if not using
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
GROQ_API_KEY=

# n8n
N8N_ENCRYPTION_KEY=your-32-char-secret
N8N_HOST=localhost
N8N_PROTOCOL=http
N8N_WEBHOOK_URL=http://localhost:5678
TIMEZONE=UTC
```

---

## Makefile Commands

```bash
# Stack
make up                  # build and start all services
make down                # stop and remove all containers and volumes

# Per-service
make pgv_logs            # postgres logs
make rds_logs            # redis logs
make olm_logs            # ollama logs
make llm_logs            # litellm logs
make n8n_logs            # n8n logs

make pgv_psql            # open psql shell
make rds_cli             # open redis-cli
make olm_bash            # shell into ollama container
make llm_bash            # shell into litellm container
make n8n_bash            # shell into n8n container

make olm_pull MODEL=mistral:7b   # pull a model manually
make llm_models                  # list all models available via LiteLLM
```

---

## GPU Support

NVIDIA GPU passthrough for Ollama is pre-configured but commented out. To enable it, uncomment the `deploy` block in `docker-compose.yaml` under `ollama_service`:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

---

## Project Structure

```
.
├── dockerfile/
│   ├── databases/
│   │   ├── pgvector/         # Postgres + pgvector config and init SQL
│   │   └── redis/            # Redis config
│   ├── litellm/              # LiteLLM proxy config
│   ├── n8n/                  # n8n Dockerfile
│   └── ollama/               # Ollama Dockerfile and model entrypoint
├── docker-compose.yaml
├── .env.example
└── Makefile
```

---

## Design Principles

- **Stateless agents** — all state lives in Redis or Postgres, agents are replaceable
- **Provider agnosticism** — swap LLM providers in config, never in code
- **Single responsibility** — each service does one thing
- **Local-first** — the full stack runs with zero API keys using Ollama
- **Cost visibility** — every LLM call is tracked with token count and USD cost

---

## License

MIT





















