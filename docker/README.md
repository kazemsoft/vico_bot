# Docker Deployment

Run Vicobot as a Docker container.

## Quick Start

```bash
cd docker

# 1. Create .env with your API key
cp .env.example .env
nano .env

# 2. Build and run
docker-compose build --no-cache
docker-compose up -d

# 3. Check logs
docker-compose logs -f
```

## Commands

```bash
# Rebuild image
docker-compose build --no-cache

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down

# Open shell
docker-compose exec vicobot sh

# Clean up (removes volumes)
docker-compose down -v
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENAI_API_KEY` | Yes | OpenAI-compatible API key |
| `OPENAI_API_BASE` | No | API base URL (default: OpenRouter) |
| `VICOBOT_MODEL` | Yes | Model to use (e.g., `google/gemini-2.5-flash`) |
| `TELEGRAM_BOT_TOKEN` | No | Telegram bot token from @BotFather |
| `TELEGRAM_ALLOW_FROM` | No | Comma-separated Telegram user IDs |

## Data Persistence

Data is persisted in `./vicobot-data`:
- `config.json` - Configuration
- `workspace/` - Workspace files
- `memory/` - Memory storage
- `skills/` - Skill packages
