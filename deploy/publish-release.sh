#!/usr/bin/env bash
# Publie un installeur deja uploade dans /var/www/memedrop/download/ (lance par GitHub Actions).
# Usage : bash publish-release.sh <version> <fichier.exe>
set -euo pipefail

VERSION="$1"
FILE="$2"
DOMAIN="memedrop.57-131-40-94.sslip.io"
WEBROOT="/var/www/memedrop"
EXE="$WEBROOT/download/$FILE"

test -f "$EXE"
SIZE=$(stat -c %s "$EXE")
SHA=$(sha256sum "$EXE" | cut -d' ' -f1)
DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Lien stable vers la derniere version
ln -sfn "$FILE" "$WEBROOT/download/MemeDrop-Setup-latest.exe"

cat > "$WEBROOT/latest.json.tmp" <<JSON
{
  "version": "$VERSION",
  "name": "MemeDrop v$VERSION",
  "file": "$FILE",
  "url": "https://$DOMAIN/download/$FILE",
  "size": $SIZE,
  "sha256": "$SHA",
  "date": "$DATE"
}
JSON
mv "$WEBROOT/latest.json.tmp" "$WEBROOT/latest.json"

# Garde les 5 dernieres versions
ls -1t "$WEBROOT"/download/MemeDrop-Setup-[0-9]*.exe | tail -n +6 | xargs -r rm -f

cat "$WEBROOT/latest.json"
