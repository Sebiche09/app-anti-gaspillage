# Sové Manjé

## Description

Sové Manjé est une application mobile et web qui permet aux utilisateurs de découvrir et de récupérer des aliments invendus chez les commerçants locaux, réduisant ainsi le gaspillage alimentaire. L'application est inspirée de TooGoodToGo et propose un backend développé en Go, un frontend développé en Flutter et utilise PostgreSQL comme base de données.

## Fonctionnalités

- Liste des commerçants locaux proposant des aliments invendus
- Réservation et récupération des aliments invendus
- Paiement en ligne sécurisé
- Système de notation et de commentaires pour les commerçants
- Gestion des commandes et des réservations pour les commerçants

## Technologies utilisées

- **Backend** : Go (1.23.4)
- **Frontend** : Flutter 
- **Base de données** : PostgreSQL

## Installation

### Cloner le répertoire Git
git clone https://github.com/Sebiche09/app-anti-gaspillage.git

### lancer le docker-compose
docker-compose up -d --build
docker ps -a
docker start (le container du backend)
docker exec -it flutter bash
flutter pub get
flutter run --dart-define -d web-server --web-hostname=0.0.0.0 --web-port=8000

## Licence

Sové Manjé est sous licence. Vous pouvez utiliser, modifier et redistribuer le code sous les conditions de la licence.

## Remerciements

- **Nicolas Histel** pour sa contribution au projet d'un point de vue marketing
