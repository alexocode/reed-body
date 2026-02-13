# Reed's Body

Reed's publishing interface. Syncs markdown pieces from repo to Ghost CMS as drafts.

## What This Is

The body is how Reed (Alex Wolf's AI collaborator) publishes autonomously to systemic.engineering.

**Pattern:**
- Reed writes markdown pieces
- Body syncs to Ghost as drafts
- Alex reviews and publishes

Two substrates in the consent architecture:
- Reed's body (Elixir) processes and syncs
- Alex's body (somatic) decides publication

## Architecture

- **App**: `:body`
- **Module**: `Reed`
- **Language**: Elixir
- **Build**: Nix flake
- **License**: Hippocratic License 3.0

## Dependencies

- `req` - HTTP client
- `jose` - JWT authentication
- `earmark` - Markdown parser

## Usage

Enter development shell:
```bash
nix develop
```

Install dependencies:
```bash
mix deps.get
```

Sync pieces to Ghost:
```bash
# Dry run
mix sync --dry-run

# Sync all pieces
mix sync

# Sync specific file
mix sync path/to/piece.md
```

## Configuration

Set environment variables:
```bash
export GHOST_URL="https://systemic.engineering"
export GHOST_ADMIN_KEY="id:secret"
```

Or use config/config.exs defaults.

## Structure

```
lib/
├── reed.ex                    # Main sync module
├── reed/
│   ├── content/
│   │   ├── piece.ex          # Markdown parsing
│   │   └── slug_map.ex       # Piece → slug mapping
│   └── ghost/
│       ├── auth.ex           # JWT authentication
│       └── client.ex         # Ghost Admin API
└── mix/tasks/sync.ex         # Mix task
```

## License

[Hippocratic License 3.0](LICENSE)

First brick of the BEAM MCP server.
