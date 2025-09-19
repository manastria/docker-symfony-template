# Environnement de Développement Docker pour Symfony

Ce projet est un **modèle de démarrage (template)** fournissant une image Docker et la configuration nécessaire pour développer des applications Symfony. Il est conçu pour offrir un environnement de développement cohérent, rapide et simple à initialiser.

## Fonctionnalités

- **PHP 8.2** avec Apache
- **Composer 2** pour la gestion des dépendances PHP
- **Symfony CLI** pour une intégration parfaite avec le framework
- **Xdebug 3** pré-configuré pour le débogage pas-à-pas
- **Extensions PHP communes** incluses (`pdo_mysql`, `opcache`, `xml`, etc.)
- Gestion automatique des permissions de fichiers entre l'hôte et le conteneur

## Image Docker de base

Cet environnement s'appuie sur une image Docker personnalisée, construite pour les besoins spécifiques des projets Symfony.

- **Image** : `manastria/symfony`
- **Version utilisée par ce template** : `8.2-apache-v0.0.1`
- **Dépôt** : [Consulter sur Docker Hub](https://hub.docker.com/r/manastria/symfony)

La version de l'image est figée dans le fichier `docker-compose.yaml` pour garantir la stabilité et la reproductibilité de l'environnement pour tous les utilisateurs.

## Démarrage d'un nouveau projet

Le seul prérequis est d'avoir une installation fonctionnelle de **Docker** et **Docker Compose** (v2 ou supérieure).

### 1. Créer le projet à partir de ce modèle

La meilleure façon de commencer est d'utiliser ce dépôt comme modèle.

- Cliquez sur le bouton vert **"Use this template"** en haut de la page GitHub, puis sur **"Create a new repository"**.
- Choisissez un nom pour le dépôt de votre projet (par exemple, `mon-super-projet-symfony`).

### 2. Cloner votre nouveau dépôt

Une fois votre dépôt personnel créé, clonez-le sur votre machine locale :

```bash
# Remplacez <votre-nom-d-utilisateur> et <nom-du-depot>
git clone https://github.com/<votre-nom-d-utilisateur>/<nom-du-depot>.git
cd <nom-du-depot>
```

### 3. Lancer les conteneurs

Le dépôt contient déjà les fichiers `docker-compose.yaml` et `start.sh`. Lancez l'environnement avec une seule commande :

```bash
docker compose up -d
```

*Note : Sur Linux/macOS, assurez-vous que le script est exécutable : `chmod +x php-build/start.sh`*

### 4. Installer Symfony

Les conteneurs sont en cours d'exécution, mais le répertoire `./app` est encore vide. Nous allons maintenant utiliser Composer *à l'intérieur* du conteneur PHP pour y installer Symfony.

Exécutez la commande suivante depuis la racine de votre projet :

```bash
# Cette commande exécute "composer create-project" dans le conteneur 'php'
docker compose exec php composer create-project symfony/skeleton:"^7.0" .
```

*Le `.` à la fin est important : il indique à Composer d'installer le projet dans le répertoire courant du conteneur (`/var/www/html`), qui correspond à votre dossier `./app`.*

### 5. C'est prêt !

Votre environnement de développement est maintenant entièrement configuré avec un projet Symfony fonctionnel.

## Accès

- **Site web** : [http://localhost:8000](https://www.google.com/search?q=http://localhost:8000)
- **Base de données (via PhpMyAdmin)** : [http://localhost:8080](https://www.google.com/search?q=http://localhost:8080)
- **Pour se connecter à la base de données depuis Symfony**, utilisez `db` comme nom d'hôte dans votre fichier `.env.local` : `DATABASE_URL="mysql://symfony_user:user_password@db:3306/symfony_db?serverVersion=8.0&charset=utf8mb4"`

## Licence

Ce projet est sous licence [MIT](LICENSE).
