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
mkdir -p ~/.claude/skills/fml ~/.claude/commands
curl -fsSL https://fml.md/fml/SKILL.md -o ~/.claude/skills/fml/SKILL.md
curl -fsSL https://fml.md/fml/fml.md   -o ~/.claude/commands/fml.md
```
