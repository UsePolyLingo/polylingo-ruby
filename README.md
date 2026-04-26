# polylingo (Ruby)

Ruby client for the [PolyLingo](https://usepolylingo.com) translation API.

Requires Ruby 2.7+.

## Install

```bash
gem install polylingo
```

Or in your `Gemfile`:

```ruby
gem "polylingo"
```

## Quick start

```ruby
require "polylingo"

client = PolyLingo.new(api_key: ENV.fetch("POLYLINGO_API_KEY"))
# Optional:
# client = PolyLingo.new(
#   api_key: ENV.fetch("POLYLINGO_API_KEY"),
#   base_url: "https://api.usepolylingo.com/v1",
#   timeout: 120, # seconds (open + read)
# )

result = client.translate(content: "# Hello", targets: %w[es fr], format: "markdown")
puts result["translations"]["es"]
```

## API

| Method | Notes |
|--------|--------|
| `client.health` | `GET /health` |
| `client.languages` | `GET /languages` |
| `client.translate(...)` | `POST /translate` |
| `client.batch(...)` | `POST /translate/batch` |
| `client.usage` | `GET /usage` |
| `client.jobs.create(...)` | `POST /jobs` (202) |
| `client.jobs.get(job_id)` | `GET /jobs/:id` |
| `client.jobs.translate(...)` | Submit job, poll until done |

### `client.jobs.translate` options

All time values are in **seconds** (Ruby convention):

- `poll_interval` — delay between polls (default: `5`)
- `timeout` — wall-clock limit for polling (default: `1200`, 20 minutes)
- `on_progress` — optional callable, e.g. `->(queue_position) { ... }` (called while status is `pending` or `processing`)

## Errors

- `PolyLingo::PolyLingoError` — base class (`#status`, `#error`, `#message`)
- `PolyLingo::AuthError` — HTTP 401
- `PolyLingo::RateLimitError` — HTTP 429; optional `#retry_after` (integer seconds) from JSON `retry_after` or `Retry-After` header
- `PolyLingo::JobFailedError` — failed job or polling timeout; `#job_id` set when known

## Documentation

[Ruby SDK on usepolylingo.com](https://usepolylingo.com/en/docs/sdk/ruby)

## Repository

[github.com/UsePolyLingo/polylingo-ruby](https://github.com/UsePolyLingo/polylingo-ruby)

## License

MIT
