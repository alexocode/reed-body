# Test Coverage

This project enforces **100% test coverage** with explicit opt-out.

## Ignoring Lines from Coverage

### Single Line
```elixir
# coveralls-ignore-next-line
def debug_helper(data), do: IO.inspect(data, label: "DEBUG")
```

### Block
```elixir
# coveralls-ignore-start
def experimental_feature do
  # Not yet stable enough to test
  :ok
end
# coveralls-ignore-stop
```

## Running Coverage

```bash
# HTML report
mix coveralls.html
open cover/excoveralls.html

# Terminal output
mix coveralls

# Detailed line-by-line
mix coveralls.detail
```

## When to Use Ignore Comments

Valid reasons:
- Debug/development helpers
- Code unreachable in test environment
- Trivial delegations already covered by other tests

Invalid reasons:
- "Too hard to test" → refactor instead
- "Just a getter" → still needs a test
- "Legacy code" → write tests or delete code
