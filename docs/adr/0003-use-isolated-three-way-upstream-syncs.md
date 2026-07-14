# Use isolated three-way upstream syncs

Upstream Syncs use Provenance to drive a three-way merge whose base is the previously pinned source revision, whose local side is the curated Imported Skill, and whose incoming side is the selected upstream revision. Syncs run in isolation, preserve results without committing them, and require explicit user decisions for conflicts, membership, and lasting Divergence; this adds process in exchange for protecting local Rewirings and preventing reviewed installations from changing before the user accepts a sync.
