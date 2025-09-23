#!/usr/bin/env bash
set -Eeuo pipefail

# Répertoire du script (gère les éventuels liens symboliques)
src="${BASH_SOURCE[0]}"
while [ -L "$src" ]; do
  dir="$(cd -P -- "$(dirname -- "$src")" && pwd)"
  src="$(readlink "$src")"
  [[ $src != /* ]] && src="$dir/$src"
done
script_dir="$(cd -P -- "$(dirname -- "$src")" && pwd)"

envfile="$script_dir/.env"
uid="$(id -u)"
gid="$(id -g)"
tmp="$(mktemp)"

if [[ -f "$envfile" ]]; then
  awk -v uid="$uid" -v gid="$gid" '
    BEGIN { seen_uid=0; seen_gid=0 }
    /^[[:space:]]*#/ { print; next }                                # on garde les commentaires
    /^[[:space:]]*(export[[:space:]]+)?UID[[:space:]]*=/ {
      if (!seen_uid) { print "UID=" uid; seen_uid=1 }                # remplace la 1re occurrence
      next                                                           # saute les doublons
    }
    /^[[:space:]]*(export[[:space:]]+)?GID[[:space:]]*=/ {
      if (!seen_gid) { print "GID=" gid; seen_gid=1 }
      next
    }
    { print }                                                        # ligne inchangée
    END {
      if (!seen_uid) print "UID=" uid                                # ajoute si absent
      if (!seen_gid) print "GID=" gid
    }
  ' "$envfile" > "$tmp"
  # Conserver les attributs si possible
  chmod --reference="$envfile" "$tmp" 2>/dev/null || true
  chown --reference="$envfile" "$tmp" 2>/dev/null || true
else
  umask 077
  printf 'UID=%s\nGID=%s\n' "$uid" "$gid" > "$tmp"
fi

mv -f "$tmp" "$envfile"
echo "Mise à jour de $envfile : UID=$uid, GID=$gid"
