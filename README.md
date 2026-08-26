# fml.md

An agent skill, and the site that hands it out. Works in Claude Code, opencode,
Codex CLI and Hermes — it's a `SKILL.md`, so anything that reads those can run it.

**fml** is the senior engineer who has been on call for nine days. Visibly
annoyed, relentlessly professional, brutally short. Asked a question, it points
at the line. Asked for a change, it ships the diff. No preamble, no summary, no
comments in the code.

## Layout

| Path | What |
| --- | --- |
| `.claude/skills/fml/SKILL.md` | The skill. Source of truth. |
| `.claude/commands/fml.md` | The `/fml` slash command, Claude Code flavour. |
| `assets/commands/fml.opencode.md` | The same command, opencode flavour. |
| `public/` | The site. Static, no framework. |
| `public/install` | POSIX `sh` installer served at `fml.md/install`. |
| `public/install.ps1` | The Windows equivalent. |
| `scripts/build.mjs` | Copies the three files above into `public/fml/` so they're downloadable. |
| `wrangler.jsonc` | Cloudflare Workers static-assets config. |

`public/fml/` is generated and gitignored — edit the originals in `.claude/`.

## Local

```sh
npm install
npm run dev        # build + wrangler dev on http://localhost:8787
```

## Deploy

```sh
npm run deploy     # build + wrangler deploy
```

First deploy lands on `fml-md.<subdomain>.workers.dev`. To put it on the real
domain:

1. Cloudflare dashboard → **Add a site** → `fml.md`, then point the registrar's
   nameservers at Cloudflare and wait for the zone to go **Active**.
2. Uncomment the `routes` block in `wrangler.jsonc`.
3. `npm run deploy`.

Alternatively, wire the repo to Cloudflare Pages with build command
`npm run build` and output directory `public`.

## Using the skill

Inside this repo it's already live — `/fml <question>`. Elsewhere:

```sh
curl -fsSL https://fml.md/install | sh
```

```powershell
irm https://fml.md/install.ps1 | iex
```

With no argument it installs for Claude Code. Name another harness to install it
there instead:

```sh
curl -fsSL https://fml.md/install | sh -s -- opencode
curl -fsSL https://fml.md/install | sh -s -- codex
curl -fsSL https://fml.md/install | sh -s -- hermes
```

Each one has its own layout, so the installer picks the paths:

| Harness | Global | In a repo | Invoke |
| --- | --- | --- | --- |
| Claude Code | `~/.claude` | `./.claude` | `/fml` |
| opencode | `~/.config/opencode` | `./.opencode` | `/fml` |
| Codex CLI | `~/.agents` | `./.agents` | `$fml` |
| Hermes | `~/.hermes` | `./.hermes` | `/fml` |

The skill lands in `<root>/skills/fml/SKILL.md` everywhere. Claude Code and
opencode also get a `<root>/commands/fml.md`; Codex and Hermes surface the skill
directly, so there's nothing to add.

The installer asks whether you want it globally (every project) or in this repo
only. Skip the question with `--global` / `--local`:

```sh
curl -fsSL https://fml.md/install | sh -s -- opencode --local
```

PowerShell has no argument passing through `iex`, so it reads `$env:FML_SCOPE`
(`global` or `local`) and `$env:FML_AGENT` (`claude`, `opencode`, `codex`,
`hermes`) instead:

```powershell
$env:FML_AGENT='codex'; irm https://fml.md/install.ps1 | iex
```

Both honour `FML_BASE` for testing against a local `wrangler dev`:

```sh
curl -fsSL http://127.0.0.1:8787/install | FML_BASE=http://127.0.0.1:8787 sh -s -- --local
```

The prompt reads from `/dev/tty`, so it still works through a pipe. With no
terminal at all (CI), it says so and installs globally.
