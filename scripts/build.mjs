import { copyFile, mkdir, rm } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const out = resolve(root, "public/fml");

const files = [
  [".claude/skills/fml/SKILL.md", "SKILL.md"],
  [".claude/commands/fml.md", "fml.md"],
  ["assets/commands/fml.opencode.md", "fml.opencode.md"],
];

await rm(out, { recursive: true, force: true });
await mkdir(out, { recursive: true });

for (const [from, to] of files) {
  await copyFile(resolve(root, from), resolve(out, to));
  console.log(`${from} -> public/fml/${to}`);
}
