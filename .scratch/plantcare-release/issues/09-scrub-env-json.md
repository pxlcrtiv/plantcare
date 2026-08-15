Type: task
Status: open
Blocked by:

## Question

Scrub `env.json` — legacy keys are committed in git history. What does cleanup look like?

`env.json` (committed in d4de6c1; keys: SUPABASE_URL, SUPABASE_ANON_KEY, OPENAI_API_KEY, GEMINI_API_KEY, ANTHROPIC_API_KEY, PERPLEXITY_API_KEY) is dead weight — the app never reads it — but its values sit in public history. In scope per the human.

Plan:

1. Confirm the app truly never reads env.json (evidence: grep for reads in lib/)
2. Remove env.json from the tree, add to `.gitignore`
3. Scrub it from history — decide the tool: `git filter-repo` preferred (check it's installed; else BFG) — this **rewrites history and force-pushes to `origin/main`**: count as a destructive action, get explicit human go-ahead before push (the human confirms each of: go-ahead, no other collaborators/clones affected, remote backup exists)
4. Also check: do any *real* current secrets appear in git history (google-services.json, keys in lib/) — report, don't invent

HITL — the go/no-go on the rewrite is the human's. Resolved when: env.json gone from tree, gitignored, history scrubbed (evidence: `git log --all -- env.json` empty), no traces of key names in `git rev-list --objects --all`.

Record in the Answer: what the keys actually were/are (names only — never values), the scrub command used, and that the rewrite succeeded.