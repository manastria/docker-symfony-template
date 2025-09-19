# Procédure de Maintenance de l'Image Docker

Ce document décrit la procédure pour mettre à jour et publier une nouvelle version de l'image Docker `manastria/symfony`.

## Contexte

La publication d'une nouvelle version de l'image est une action manuelle et intentionnelle. Elle n'est pas déclenchée par un simple `push` sur la branche `main`, mais via une intervention sur l'interface de GitHub.

Cela permet de décorréler complètement les modifications de l'environnement de base de la publication d'une version stable pour les utilisateurs.

## Configuration Initiale du Dépôt

Avant de pouvoir publier la première image, une configuration unique est requise dans les paramètres du dépôt GitHub.

1. **Naviguer vers les paramètres** du dépôt GitHub, puis dans `Settings > Secrets and variables > Actions`.
2. **Créer deux secrets de dépôt** (`New repository secret`) :
   - `DOCKERHUB_USERNAME` : L'identifiant Docker Hub.
   - `DOCKERHUB_TOKEN` : Un jeton d'accès généré depuis les paramètres du compte Docker Hub (`Account Settings > Security > New Access Token`).

## Procédure de publication d'une nouvelle version

1. **Mise à jour du code**
   - Apporter les modifications nécessaires aux fichiers de l'environnement (`php-build/Dockerfile.base`, `php-build/start.sh`, configurations, etc.).
   - Valider (`commit`) et pousser (`push`) ces modifications sur la branche `main` du dépôt GitHub.
2. **Déclenchement manuel du workflow**
   - Naviguer vers l'onglet **"Actions"** du dépôt GitHub.
   - Dans le menu de gauche, sélectionner le workflow nommé **"Build and Publish Docker Image"**.
3. **Lancement de la publication**
   - Un bandeau apparaît avec un bouton **"Run workflow"**. Cliquer sur ce bouton.
   - Un champ de saisie intitulé **"Version de l'image à publier"** s'affiche.
   - Saisir la version complète de l'image souhaitée. Il est fortement recommandé de suivre le format `<version-php>-apache-v<version-interne>` :
     - **`8.2-apache-v0.0.1`** : Version initiale pour PHP 8.2 avec Apache.
     - **`8.2-apache-v0.0.2`** : Mise à jour mineure pour la version PHP 8.2.
     - **`8.3-apache-v1.0.0`** : Nouvelle version majeure, basée sur PHP 8.3.
   - Cliquer sur le bouton vert **"Run workflow"** pour lancer le processus.
4. **Vérification**
   - Le workflow va s'exécuter. Il est possible de suivre sa progression en temps réel dans l'onglet "Actions".
   - Une fois le job terminé avec succès, la nouvelle image sera disponible sur Docker Hub avec le tag spécifié (ex: `manastria/symfony:8.2-apache-v0.0.1`).

## Annexe : Commandes locales et manuelles

### Tester la construction de l'image en local

Pour tester des modifications sur le `Dockerfile.base` sans lancer le workflow complet, il est possible de construire l'image localement.

1. **Se placer à la racine du dépôt.**

2. **Lancer la commande de construction** :

   ```bash
   # La commande utilise le contexte '.' et pointe vers le Dockerfile spécifique.
   docker build -f ./php-build/Dockerfile.base -t manastria/symfony:test-local .
   ```

   Cette commande crée une image locale avec le tag `test-local` qui peut ensuite être utilisée dans un `docker-compose.yaml` pour des tests avant la publication officielle.

### Publier une image manuellement

En cas de besoin, ou si le workflow GitHub Actions n'est pas disponible, il est possible de publier une image construite localement.

1. **Se connecter à Docker Hub** :

   ```bash
   docker login
   ```

2. **Taguer l'image locale** avec le nom complet attendu sur Docker Hub :

   ```bash
   # Remplace l'image construite localement (test-local) par le tag officiel
   docker tag manastria/symfony:test-local manastria/symfony:8.2-apache-v0.0.1
   ```

3. **Publier l'image** :

   ```bash
   docker push manastria/symfony:8.2-apache-v0.0.1
   ```
