# Étape 1 : Build Flutter Web
FROM debian:latest AS build-env

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    curl git wget unzip \
    libxi6 libgtk-3-0 libxrender1 libxtst6 \
    libxslt1.1 libgconf-2-4 gdb libstdc++6 \
    libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 && \
    apt-get clean

# Cloner Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Ajouter Flutter au PATH
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Vérifier l'installation et mettre à jour Flutter
RUN flutter doctor -v
RUN flutter channel stable
RUN flutter upgrade

# Activer le support Web
RUN flutter config --enable-web

# Copier le projet Flutter dans le conteneur
WORKDIR /app
COPY . .

# Récupérer les dépendances et build l'application Web
RUN flutter pub get
RUN flutter build web --release

# Étape 2 : Utiliser Nginx pour servir l'app Flutter Web
FROM nginx:1.21.1-alpine

# Copier les fichiers buildés dans le dossier nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Exposer le port 3000
EXPOSE 3000

# Lancer Nginx
CMD ["nginx", "-g", "daemon off;"]
