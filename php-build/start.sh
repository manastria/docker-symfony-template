#!/bin/bash
set -e

# On récupère les UID/GID depuis les variables d'environnement, avec 1000 comme valeur par défaut.
HOST_UID=${LOCAL_UID:-1000}
HOST_GID=${LOCAL_GID:-1000}

echo "Synchronisation de l'utilisateur www-data avec l'UID: $HOST_UID et le GID: $HOST_GID"

# On modifie le GID du groupe www-data pour correspondre à celui de l'hôte.
# L'option -o permet d'utiliser un GID non unique si un autre groupe l'avait déjà.
groupmod -o -g "$HOST_GID" www-data

# On modifie l'UID de l'utilisateur www-data pour correspondre à celui de l'hôte.
# L'option -o est également utilisée ici pour permettre un UID non unique.
usermod -o -u "$HOST_UID" www-data

# On s'assure que www-data est propriétaire de son répertoire personnel.
echo "Ajustement des permissions pour le répertoire /var/www..."
chown -R www-data:www-data /var/www

echo "Permissions configurées. Démarrage de la commande..."

# On exécute la commande passée en argument au script (ici, "apache2-foreground")
exec "$@"
