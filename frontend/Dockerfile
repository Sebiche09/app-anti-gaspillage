FROM ubuntu:22.04

# Éviter les prompts interactifs pendant l'installation
ENV DEBIAN_FRONTEND=noninteractive

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk \
    wget \
    xauth \
    libpulse0 \
    libxcomposite1 \
    libxcursor1 \
    libxi6 \
    libxtst6 \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libx11-6 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    ca-certificates \
    && apt-get clean

# Créer un utilisateur non-root
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Télécharger et installer la dernière version stable de Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /home/developer/flutter

# Ajouter Flutter au PATH
ENV PATH="/home/developer/flutter/bin:${PATH}"

# Configurer Flutter et mettre à jour vers la dernière version
RUN flutter config --no-analytics && \
    flutter upgrade && \
    flutter channel stable && \
    flutter upgrade && \
    flutter precache && \
    flutter doctor -v

# Activer spécifiquement le support web
RUN flutter config --enable-web

# Précharger les packages communs pour accélérer le développement
RUN mkdir -p /home/developer/temp_project && \
    cd /home/developer/temp_project && \
    flutter create . && \
    flutter pub get && \
    flutter pub cache repair && \
    cd .. && \
    rm -rf temp_project

# Vérifier les versions installées (pour référence)
RUN echo "Flutter and Dart versions:" && \
    flutter --version && dart --version

# Créer le répertoire de travail et changer ses permissions
USER root
RUN mkdir -p /workspace && chown -R developer:developer /workspace

# Revenir à l'utilisateur developer
USER developer
WORKDIR /workspace

# Exposer le port pour Flutter web
EXPOSE 8000

CMD ["bash"]
