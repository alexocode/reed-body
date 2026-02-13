# Reed Body - Ghost Sync Justfile
# Run `just` to see all available commands

# List all commands
default:
    @just --list

# Run tests
test:
    mix test

# Check test coverage
coverage:
    mix coveralls

# Generate HTML coverage report
coverage-html:
    mix coveralls.html
    open cover/excoveralls.html

# Run linter
lint:
    mix credo --strict

# Format code
format:
    mix format

# Sync a specific piece to Ghost (with secrets)
sync FILE:
    sops exec-env secrets.sops.yaml 'mix sync {{FILE}}'

# Sync a piece (dry run)
sync-dry FILE:
    sops exec-env secrets.sops.yaml 'mix sync --dry-run {{FILE}}'

# Sync all pieces in Pieces/ directory
sync-all:
    sops exec-env secrets.sops.yaml 'mix sync'

# Sync all pieces (dry run)
sync-all-dry:
    sops exec-env secrets.sops.yaml 'mix sync --dry-run'

# Fetch a piece from Ghost by slug
fetch-piece SLUG:
    #!/usr/bin/env bash
    sops exec-env secrets.sops.yaml bash -c ' \
      curl -s \
        -H "Authorization: Ghost $(mix run -e \"IO.puts Reed.Ghost.Auth.token()\")" \
        "${GHOST_API_BASE_URL}/ghost/api/admin/posts/slug/{{SLUG}}/?formats=lexical" \
      | jq ".posts[0]"'

# Fetch piece Lexical JSON
fetch-lexical SLUG:
    #!/usr/bin/env bash
    sops exec-env secrets.sops.yaml bash -c ' \
      curl -s \
        -H "Authorization: Ghost $(mix run -e \"IO.puts Reed.Ghost.Auth.token()\")" \
        "${GHOST_API_BASE_URL}/ghost/api/admin/posts/slug/{{SLUG}}/?formats=lexical" \
      | jq -r ".posts[0].lexical"'

# Fetch piece rendered HTML
fetch-html SLUG:
    #!/usr/bin/env bash
    sops exec-env secrets.sops.yaml bash -c ' \
      curl -s \
        -H "Authorization: Ghost $(mix run -e \"IO.puts Reed.Ghost.Auth.token()\")" \
        "${GHOST_API_BASE_URL}/ghost/api/admin/posts/slug/{{SLUG}}/?formats=html" \
      | jq -r ".posts[0].html"'

# Start IEx with secrets loaded
iex:
    sops exec-env secrets.sops.yaml 'iex -S mix'

# Run CI checks locally
ci:
    mix format --check-formatted
    mix credo --strict
    mix compile --warnings-as-errors
    mix test
    mix coveralls
