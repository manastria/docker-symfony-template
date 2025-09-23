# Environnement de Développement Docker pour Symfony

Ce projet est un **modèle de démarrage (template)** conçu pour lancer un projet Symfony en quelques minutes, sans se soucier de la configuration de sa machine.

Pensez-y comme à un **kit de développement « prêt-à-coder »** : il contient tout ce qu’il faut (PHP, Apache, Composer, une base de données…) dans une boîte virtuelle (Docker), vous permettant de vous concentrer sur l’essentiel : le code.

Il est idéal pour les développeurs de tous niveaux, et particulièrement adapté aux étudiants qui découvrent l’écosystème Symfony et Docker.

## Pour quoi faire ?

Ce template configure un environnement complet et optimisé pour Symfony. Voici ce qu’il y a dans la boîte :

- **Un serveur web complet** avec **PHP 8.2** et Apache.
- **Composer 2** et le **CLI Symfony** pour gérer votre projet et ses dépendances.
- **MySQL 8** prêt à l’emploi avec l’interface **PhpMyAdmin** pour gérer vos données facilement.
- **Xdebug 3** pré-configuré pour déboguer votre code pas-à-pas comme un pro.
- **Gestion automatique des permissions** : Fini les `sudo chmod -R 777` ! Les fichiers créés dans le conteneur vous appartiendront sur votre machine, et vice-versa.

-----

## Pré-requis et Bonnes Pratiques

Avant de commencer, assurez-vous d'avoir les éléments suivants.

### Logiciels requis

- Une installation fonctionnelle de **Docker** et **Docker Compose** (v2 ou supérieure).

### Configuration de Git (Important !)

Si c'est l'une de vos premières fois avec Git, il est crucial de configurer votre nom d'utilisateur et votre email. Chaque "commit" (sauvegarde) que vous ferez sera signé avec ces informations.

Exécutez ces commandes dans votre terminal en remplaçant les exemples par vos propres informations. L'option `--global` applique cette configuration à tous vos projets Git sur votre machine.

```bash
# Remplacez "Votre Nom" par votre vrai nom ou pseudo
git config --global user.name "Votre Nom"

# Remplacez par votre adresse email (celle de GitHub est un bon choix)
git config --global user.email "vous@exemple.com"
```

## Démarrage rapide

### 1. Créer votre projet depuis ce modèle

La meilleure façon de commencer est d’utiliser ce dépôt comme modèle pour votre propre projet.

- Cliquez sur le bouton vert **« Use this template »** en haut de la page GitHub, puis sur **« Create a new repository »**.
- Choisissez un nom pour votre nouveau dépôt (ex : `mon-super-projet-symfony`) et rendez-le public ou privé.

### 2. Cloner votre nouveau dépôt

Une fois votre dépôt personnel créé, clonez-le sur votre machine locale et naviguez à l’intérieur :

```bash
# Remplacez <votre-nom-d-utilisateur> et <nom-du-depot>
git clone https://github.com/<votre-nom-d-utilisateur>/<nom-du-depot>.git
cd <nom-du-depot>
```

### 3. Initialiser l’environnement (Étape cruciale !)

Ce projet a besoin de connaître l’identifiant de votre utilisateur local (UID) et de son groupe (GID) pour éviter tout problème de permissions de fichiers avec Docker.

Un script est fourni pour automatiser cette configuration. Vous ne devez le lancer qu’une seule fois.

```bash
# Exécutez le script
./init.sh
```

**Que fait ce script ?** Il crée un fichier .env à la racine du projet et y inscrit votre UID et GID. Ce fichier sera ensuite lu par Docker Compose pour configurer les conteneurs avec les bonnes permissions. C’est la magie qui vous évitera les maux de tête de permissions !

> 💡 **En cas d’erreur « Permission denied » ?** Si le terminal refuse d’exécuter le script, lancez la commande `chmod +x init.sh` et réessayez.

### 4. Lancer l’environnement

Lancez l’ensemble des services (PHP, MySQL…) avec une seule commande. L’option `-d` (_detached_) permet de laisser les conteneurs tourner en arrière-plan.

```bash
docker compose up -d --build
```

La première fois, Docker va télécharger les images nécessaires, ce qui peut prendre quelques minutes. Les lancements suivants seront quasi instantanés.

### 5. Installer Symfony

Vos conteneurs sont démarrés, mais le projet Symfony n’est pas encore là. Le répertoire `app/` est vide. Nous allons maintenant utiliser les outils _à l’intérieur_ de notre conteneur PHP pour y installer un nouveau projet Symfony.

```bash
docker compose exec --user www-data php symfony new . --webapp
```

#### Décortiquons cette commande

- `docker compose exec` : Permet d’exécuter une commande dans un conteneur déjà en marche.
- `--user www-data` : Garantis que la commande sera exécutée en tant qu’utilisateur `www-data` (celui du serveur web), afin que tous les fichiers créés aient les bonnes permissions.
- `php` : C’est le nom du service (conteneur) dans lequel on veut exécuter la commande, tel que défini dans `docker-compose.yml`.
- `symfony new . --webapp` : C’est la commande pour créer un nouveau projet Symfony. Le `.` signifie qu’on l’installe dans le répertoire courant (`/var/www/html` à l’intérieur du conteneur, qui correspond à votre dossier `app/` local).

### 6. Et voilà !

Votre environnement est prêt ! Vous pouvez vérifier que tout fonctionne en visitant l’URL de votre projet.

-----

## Travailler sur plusieurs projets

Ce modèle est conçu pour que vous puissiez avoir plusieurs projets fonctionnant en même temps sur votre machine.

Chaque projet est isolé. Docker créera des conteneurs avec des noms uniques basés sur le nom du dossier de votre projet.

Les ports de communication (par exemple, `8000` pour le site web) sont définis dans le fichier `.env`. Si vous lancez un projet et que le terminal vous indique une erreur de type **"port is already allocated"**, cela signifie qu'un autre service (d'un autre projet ou non) utilise déjà ce port.

Pour corriger cela :

1. Ouvrez le fichier `.env` du projet que vous essayez de lancer.
2. Modifiez les numéros de port (par exemple, `PHP_PORT=8001`, `PMA_PORT=8081`, etc.).
3. Relancez `docker compose up -d`.

-----

## Accès et commandes utiles

### Accès aux services

- **Site web** : [http://localhost:8000](https://www.google.com/search?q=http://localhost:8000)
- **Base de données (PhpMyAdmin)** : [http://localhost:8080](https://www.google.com/search?q=http://localhost:8080)

### Commandes courantes

Pour interagir avec votre projet (lancer des migrations, vider le cache, etc.), vous devrez toujours passer par `docker compose exec`.

**Exemples :**

```bash
# Lancer une commande de la console Symfony (ex: créer un contrôleur)
docker compose exec --user www-data php bin/console make:controller TestController

# Exécuter les migrations de base de données
docker compose exec --user www-data php bin/console doctrine:migrations:migrate

# Installer une dépendance avec Composer
docker compose exec --user www-data php composer require some-package
```

### Astuce : créer un alias

Pour éviter de taper la longue commande `docker compose exec...` à chaque fois, vous pouvez créer un alias dans le fichier de configuration de votre terminal (`~/.bashrc`, `~/.zshrc`, etc.).

```shell
# Ajoute un raccourci "sf" pour exécuter la console Symfony
alias sf='docker compose exec --user www-data php bin/console'
```

Après avoir rechargé votre terminal, vous pourrez simplement faire :

```bash
sf make:controller TestController
sf doctrine:migrations:migrate
```

-----

## Pour les curieux : l’image Docker

Cet environnement s’appuie sur une image Docker personnalisée, construite pour les besoins spécifiques des projets Symfony.

- **Image** : `manastria/symfony`
- **Version utilisée par ce template** : `8.2-apache-v0.0.1’
- **Dépôt Docker Hub** : [hub.docker.com/r/manastria/symfony](https://hub.docker.com/r/manastria/symfony)

La version de l’image est intentionnellement figée dans le fichier `docker-compose.yml` pour garantir que l’environnement soit stable et 100 % reproductible pour tous les développeurs du projet.

## Licence

Ce projet est sous licence [MIT](LICENSE). N’hésitez pas à l’utiliser, le modifier et le partager !
