# Autonomous Grid

OpenAI-compatible proxy that pools multiple inference engines (Ollama, vLLM, llama.cpp, MLX, etc.) behind a single endpoint with load-aware routing.

## Endpoint

- **Internal URL:** `https://grid.rafaribe.com/v1`
- **API Key:** `local-grid` (auth is off in local mode, any value works)

## Connecting machines

Install the grid CLI on each machine you want to connect:

```bash
curl -fsSL https://grid.autonomous.ai/install.sh | bash
```

Then register the machine's inference engine:

```bash
grid join https://grid.rafaribe.com --at http://<MACHINE_LAN_IP>:<PORT>/v1 \
  -m <model1> -m <model2> \
  --name <engine-name>
```

Example (Mac with Ollama):

```bash
grid join https://grid.rafaribe.com --at http://10.0.0.108:11434/v1 \
  -m deepseek-r1:14b -m qwen2.5-coder:7b -m gemma3:4b \
  --name macbook
```

The `--at` address must be reachable from the cluster nodes.

## Checking status

```bash
# List registered engines
curl -sk https://grid.rafaribe.com/nodes/discover | jq

# List available models
curl -sk https://grid.rafaribe.com/v1/models | jq

# Quick chat test
curl -sk https://grid.rafaribe.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "llama3.2:3b", "messages": [{"role": "user", "content": "hello"}]}'
```

## Using with apps

Any OpenAI-compatible client works. Set:

```
OPENAI_BASE_URL=https://grid.rafaribe.com/v1
OPENAI_API_KEY=local-grid
```

Examples:
- **Open WebUI** — add as an OpenAI-compatible connection
- **aider** — `aider --openai-api-base https://grid.rafaribe.com/v1 --model deepseek-r1:14b`
- **Python** — `OpenAI(base_url="https://grid.rafaribe.com/v1", api_key="local-grid")`

## Load balancing

When multiple engines serve the same model, Grid routes to the one with fewest active tasks. Add more machines anytime with `grid join` — no restart needed.

## Disconnecting

```bash
grid leave --name macbook --grid https://grid.rafaribe.com
```

Or just stop the `grid join` process (Ctrl+C / kill). The engine is dropped after 60s of missed heartbeats.
