# fml.md

A Claude Code skill, and the site that hands it out.

**fml** is the senior engineer who has been on call for nine days. Visibly
annoyed, relentlessly professional, brutally short. Asked a question, it points
at the line. Asked for a change, it ships the diff. No preamble, no summary, no
comments in the code.

## Layout

| Path | What |
| --- | --- |
| `.claude/skills/fml/SKILL.md` | The skill. Source of truth. |
| `.claude/commands/fml.md` | The `/fml` slash command. |
| `public/` | The site. Static, no framework. |
| `public/install` | POSIX `sh` installer served at `fml.md/install`. |
| `public/install.ps1` | The Windows equivalent. |
| `scripts/build.mjs` | Copies the two files above into `public/fml/` so they're downloadable. |
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

The installer asks whether you want it in `~/.claude` (every project) or
`./.claude` (this repo). Skip the question with `--global` / `--local`:

```sh
curl -fsSL https://fml.md/install | sh -s -- --local
```

PowerShell has no argument passing through `iex`, so it reads `$env:FML_SCOPE`
(`global` or `local`) instead. Both honour `FML_BASE` for testing against a local
`wrangler dev`:

```sh
curl -fsSL http://127.0.0.1:8787/install | FML_BASE=http://127.0.0.1:8787 sh -s -- --local
```

The prompt reads from `/dev/tty`, so it still works through a pipe. With no
terminal at all (CI), it says so and installs globally.
