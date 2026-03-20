-- ============================================================
-- EXTENSIONS
-- ============================================================

CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ============================================================
-- AGENT MEMORY — long-term vector memory for agents
-- ============================================================

CREATE TABLE IF NOT EXISTS agent_memory (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id      VARCHAR(100)  NOT NULL,
    session_id    VARCHAR(100),
    content       TEXT          NOT NULL,
    embedding     vector(1536),
    metadata      JSONB         DEFAULT '{}',
    created_at    TIMESTAMPTZ   DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_agent_memory_agent_id   ON agent_memory (agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_memory_session_id ON agent_memory (session_id);
CREATE INDEX IF NOT EXISTS idx_agent_memory_embedding  ON agent_memory USING ivfflat (embedding vector_cosine_ops);


-- ============================================================
-- AGENT TASKS — full task lifecycle tracking
-- ============================================================

CREATE TABLE IF NOT EXISTS agent_tasks (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id       VARCHAR(100)  NOT NULL UNIQUE,
    agent_id      VARCHAR(100),
    session_id    VARCHAR(100),
    status        VARCHAR(50)   NOT NULL DEFAULT 'pending',
    input         JSONB         DEFAULT '{}',
    output        JSONB         DEFAULT '{}',
    error         TEXT,
    started_at    TIMESTAMPTZ,
    finished_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ   DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_agent_tasks_task_id    ON agent_tasks (task_id);
CREATE INDEX IF NOT EXISTS idx_agent_tasks_agent_id   ON agent_tasks (agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_tasks_status     ON agent_tasks (status);
CREATE INDEX IF NOT EXISTS idx_agent_tasks_session_id ON agent_tasks (session_id);


-- ============================================================
-- AGENT LOGS — structured event log for every agent action
-- ============================================================

CREATE TABLE IF NOT EXISTS agent_logs (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id       VARCHAR(100),
    agent_id      VARCHAR(100),
    session_id    VARCHAR(100),
    level         VARCHAR(20)   NOT NULL DEFAULT 'info',
    event         VARCHAR(100)  NOT NULL,
    message       TEXT,
    metadata      JSONB         DEFAULT '{}',
    created_at    TIMESTAMPTZ   DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_agent_logs_task_id    ON agent_logs (task_id);
CREATE INDEX IF NOT EXISTS idx_agent_logs_agent_id   ON agent_logs (agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_logs_level      ON agent_logs (level);
CREATE INDEX IF NOT EXISTS idx_agent_logs_created_at ON agent_logs (created_at DESC);


-- ============================================================
-- LLM SPEND TRACKING — token usage per agent / model
-- ============================================================

CREATE TABLE IF NOT EXISTS llm_usage (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id             VARCHAR(100),
    agent_id            VARCHAR(100),
    model               VARCHAR(100)   NOT NULL,
    provider            VARCHAR(100),
    prompt_tokens       INTEGER        DEFAULT 0,
    completion_tokens   INTEGER        DEFAULT 0,
    total_tokens        INTEGER        DEFAULT 0,
    cost_usd            NUMERIC(12, 8) DEFAULT 0,
    created_at          TIMESTAMPTZ    DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_llm_usage_agent_id   ON llm_usage (agent_id);
CREATE INDEX IF NOT EXISTS idx_llm_usage_model      ON llm_usage (model);
CREATE INDEX IF NOT EXISTS idx_llm_usage_created_at ON llm_usage (created_at DESC);


