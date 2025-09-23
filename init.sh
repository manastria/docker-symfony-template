#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# Localisation du script (gère les liens symboliques)
src="${BASH_SOURCE[0]}"
while [ -L "$src" ]; do
  dir="$(cd -P -- "$(dirname -- "$src")" && pwd)"
  src="$(readlink "$src")"
  [[ $src != /* ]] && src="$dir/$src"
done
script_dir="$(cd -P -- "$(dirname -- "$src")" && pwd)"

envfile="$script_dir/.env"

# Valeurs par défaut si clés manquantes
PHP_PORT_DEFAULT=8000
PMA_PORT_DEFAULT=8080
MYSQL_PORT_DEFAULT=3307

uid="$(id -u)"
gid="$(id -g)"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Verrouillage sans troncature
if command -v flock >/dev/null 2>&1; then
  # Créer s’il n’existe pas, mais ne PAS vider s’il existe
  [[ -e "$envfile" ]] || { umask 077; : > "$envfile"; }
  exec {lockfd}<>"$envfile"
  flock -w 5 "$lockfd" || { echo "Verrou indisponible sur $envfile"; exit 1; }
fi

# Construire la nouvelle version dans $tmp
awk -v uid="$uid" -v gid="$gid" \
    -v php="$PHP_PORT_DEFAULT" -v pma="$PMA_PORT_DEFAULT" -v mysql="$MYSQL_PORT_DEFAULT" '
  BEGIN { seen_uid=seen_gid=seen_php=seen_pma=seen_mysql=0 }

  function head_ws(s,   r){ r=match(s,/^[[:space:]]*/); return substr(s,1,RLENGTH) }
  function has_export(s){ return (s ~ /^[[:space:]]*export[[:space:]]+/) }

  # Conserver commentaires et lignes vides
  /^[[:space:]]*#/  { print; next }
  /^[[:space:]]*$/  { print; next }

  # Mettre à jour toutes les occurrences UID/GID (ne supprime rien d’autre)
  /^[[:space:]]*(export[[:space:]]+)?UID[[:space:]]*=/ {
    ind=head_ws($0); e=has_export($0);
    print ind (e ? "export " : "") "UID=" uid; seen_uid=1; next
  }
  /^[[:space:]]*(export[[:space:]]+)?GID[[:space:]]*=/ {
    ind=head_ws($0); e=has_export($0);
    print ind (e ? "export " : "") "GID=" gid; seen_gid=1; next
  }

  # Ports : s’ils existent, on les laisse tels quels
  /^[[:space:]]*(export[[:space:]]+)?PHP_PORT[[:space:]]*=/   { seen_php=1;   print; next }
  /^[[:space:]]*(export[[:space:]]+)?PMA_PORT[[:space:]]*=/   { seen_pma=1;   print; next }
  /^[[:space:]]*(export[[:space:]]+)?MYSQL_PORT[[:space:]]*=/ { seen_mysql=1; print; next }

  # Toute autre ligne : inchangée
  { print }

  END {
    if (!seen_uid)   print "UID=" uid
    if (!seen_gid)   print "GID=" gid
    if (!seen_php)   print "PHP_PORT=" php
    if (!seen_pma)   print "PMA_PORT=" pma
    if (!seen_mysql) print "MYSQL_PORT=" mysql
  }
' "$envfile" > "$tmp"

# Conserver proprio/permissions si possible
chmod --reference="$envfile" "$tmp" 2>/dev/null || true
chown --reference="$envfile" "$tmp" 2>/dev/null || true

# Remplacement atomique + durcissement basique
mv -f "$tmp" "$envfile"
chmod go-rwx "$envfile" 2>/dev/null || true

echo "OK : UID/GID mis à jour ; autres variables préservées ; ports ajoutés seulement si absents."
