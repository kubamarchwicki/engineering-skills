#!/usr/bin/env bash
# Regenerate the README provenance table from provenance.tsv (single source of truth).
# Rewrites the block between <!-- provenance:begin --> and <!-- provenance:end -->.
# Idempotent: safe to re-run any time provenance.tsv changes.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TSV="$REPO/provenance.tsv"
README="$REPO/README.md"

table="$(mktemp)"
{
  echo "| Skill | Inv. | Role | Source | Changes |"
  echo "|---|---|---|---|---|"
  awk -F'\t' 'NR>1 && $4!="dropped" {
    if ($4 == "original") src = "original"
    else { lbl = $2; sub(/-skills$/, "", lbl); src = lbl " `" $3 "`" }
    printf "| %s | %s | %s | %s | %s |\n", $1, $5, $6, src, $7
  }' "$TSV"
} > "$table"

out="$(mktemp)"
awk -v tf="$table" '
  /<!-- provenance:begin -->/ { print; while ((getline line < tf) > 0) print line; inblock=1; next }
  /<!-- provenance:end -->/   { inblock=0 }
  !inblock { print }
' "$README" > "$out"
mv "$out" "$README"
rm -f "$table"
echo "README provenance table regenerated from provenance.tsv"
