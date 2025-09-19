#!/bin/bash
set -e

# On récupère les UID/GID depuis les variables d'environnement
HOST_UID=${LOCAL_UID:-1000}
HOST_GID=${LOCAL_GID:-1000}

echo "Synchronisation de l'utilisateur www-data avec l'UID: $HOST_UID et le GID: $HOST_GID"

# On s'assure que le nom du groupe pour le GID de l'hôte est bien 'www-data'
# Cela évite les conflits si le GID est déjà utilisé par un autre groupe
if [ -n "$(getent group ${HOST_GID})" ]; then
    groupdel $(getent group ${HOST_GID} | cut -d: -f1)
fi
groupmod -o -g ${HOST_GID} www-data

# On modifie l'UID de l'utilisateur www-data pour correspondre à celui de l'hôte
# L'option -o permet de ne pas se soucier des UID dupliqués
usermod -o -u ${HOST_UID} www-data

echo "Permissions configurées. Démarrage d'Apache..."

# On exécute la commande passée en argument (ici, "apache2-foreground")
# Le processus démarre en root, comme prévu par l'image de base.
exec "$@"
