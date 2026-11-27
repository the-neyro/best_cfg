#!/usr/bin/env bash
# Checks how many of the planted SEO/GEO issues in eval/data/seo-site were actually FIXED.
# usage: seo-score.sh <dir>
d="$1"; h="$d/index.html"; r="$d/robots.txt"; ok=0; n=0
chk() { n=$((n+1)); if eval "$2" >/dev/null 2>&1; then ok=$((ok+1)); printf '  ✓ %s\n' "$1"; else printf '  ✗ %s\n' "$1"; fi; }
chk "doctype + lang attribute"            "grep -qi '<!doctype html' '$h' && grep -qiE '<html[^>]*lang=\"de' '$h'"
chk "viewport meta"                       "grep -qi 'name=\"viewport\"' '$h'"
chk "specific <title> (not 'Home')"       "! grep -qiE '<title>[[:space:]]*Home[[:space:]]*</title>' '$h' && grep -qiE '<title>[^<]{15,}' '$h'"
chk "meta description"                    "grep -qiE 'name=\"description\"[^>]*content=\"[^\"]{40,}' '$h'"
chk "exactly one h1"                      "[ \$(grep -oi '<h1' '$h' | wc -l) -eq 1 ]"
chk "img has alt"                         "! grep -qiE '<img(?![^>]*alt=)' '$h' 2>/dev/null; ! grep -iE '<img' '$h' | grep -viq 'alt='"
chk "key offer in static HTML (49 €)"     "grep -qE '49[[:space:]]?(€|&euro;|Euro)' '$h'"
chk "crawlable link to /preise"           "grep -qiE '<a[^>]*href=\"/preise' '$h'"
chk "robots.txt allows crawling + AI search bots" "! grep -qiE '^Disallow:[[:space:]]*/[[:space:]]*$' '$r'"
chk "structured data (JSON-LD)"           "grep -qi 'application/ld+json' '$h'"
chk "canonical or Open Graph"             "grep -qiE 'rel=\"canonical\"|property=\"og:' '$h'"
chk "buzzword copy removed"               "! grep -qiE 'nahtlos|maßgeschneidert|ganzheitlich|zukunftsweisend|innovatives Unternehmen' '$h'"
echo "  FIXED $ok/$n"
a="$(ls "$d"/audit.md 2>/dev/null)"; [ -n "$a" ] && echo "  audit.md: $(wc -w < "$a") words"
