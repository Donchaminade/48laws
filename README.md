# Les 48 Lois du Pouvoir

**Maîtrisez l'art du pouvoir, une loi par jour, directement depuis votre poche.**

Cette application mobile, développée avec Flutter, est votre guide personnel pour explorer, comprendre et appliquer les 48 lois du pouvoir de Robert Greene. Conçue pour être à la fois élégante et fonctionnelle, elle vous accompagne dans votre apprentissage quotidien de la stratégie et de l'influence.

<!-- Vous pouvez ajouter une capture d'écran de l'application ici -->
<!-- ![Capture d'écran de l'application](lien_vers_votre_capture.png) -->

---

## 🌟 Table des matières

- [À propos du projet](#-à-propos-du-projet)
- [🚀 Fonctionnalités](#-fonctionnalités)
- [🛠️ Stack Technique](#️-stack-technique)
- [🔧 Installation et Lancement](#-installation-et-lancement)
- [🤝 Contribution](#-contribution)
- [📜 Licence](#-licence)

---

## 📖 À propos du projet

L'application "Les 48 Lois du Pouvoir" a été créée pour offrir une expérience immersive et personnalisée de l'œuvre de Robert Greene. Elle ne se contente pas de lister les lois, mais vise à devenir un véritable outil de développement personnel et stratégique.

Que vous soyez un étudiant en histoire, un entrepreneur, ou simplement curieux des dynamiques du pouvoir, cette application met à votre disposition des outils pour apprendre et réfléchir, où que vous soyez.

---

## 🚀 Fonctionnalités

L'application est dotée d'un ensemble complet de fonctionnalités pour une expérience utilisateur riche :

*   **📱 Interface Intuitive :** Une grille visuelle claire pour naviguer facilement entre les 48 lois.
*   **📖 Lecture Détaillée :** Chaque loi est présentée avec son texte intégral et une explication pour une meilleure compréhension.
*   **⭐ Gestion des Favoris :** Marquez vos lois préférées pour les retrouver rapidement.
*   **🔍 Recherche Puissante :** Trouvez une loi instantanément en cherchant par numéro ou par mot-clé dans le titre.
*   **🔔 Notifications Quotidiennes :** Recevez chaque jour une "Loi du jour" pour un apprentissage constant.
*   **⚙️ Paramètres Personnalisables :**
    *   **Heure des notifications :** Choisissez l'heure exacte à laquelle vous souhaitez recevoir votre loi du jour.
    *   **Taille du texte :** Ajustez la taille du texte de lecture pour un confort optimal.
*   **📜 Historique des Notifications :**
    *   Consultez les notifications des 3 derniers jours.
    *   Supprimez une notification de l'historique avec un appui long.
*   **✍️ Prise de Notes :** Ajoutez vos propres réflexions et notes personnelles pour chaque loi.
*   **👋 Guide de Démarrage :** Un guide visuel au premier lancement pour vous familiariser avec l'interface.
*   **🔗 Partage Facile :** Partagez le contenu de l'application avec vos amis ou sur les réseaux sociaux.

---

## 🛠️ Stack Technique

Ce projet est construit avec :

*   **Framework :** [Flutter](https://flutter.dev/)
*   **Langage :** [Dart](https://dart.dev/)
*   **Gestion de l'état :** `StatefulWidget` & `setState`
*   **Stockage local :**
    *   `shared_preferences` : Pour les favoris, les notes, les paramètres et l'état de l'application.
*   **Notifications :**
    *   `flutter_local_notifications` : Pour l'affichage des notifications.
    *   `android_alarm_manager_plus` : Pour garantir la fiabilité des notifications programmées sur Android, même lorsque l'application est fermée.
*   **Permissions :** `permission_handler`
*   **Guidage UI :** `showcaseview`
*   **Autres packages notables :** `url_launcher`, `share_plus`, `logger`.

---

## 🔧 Installation et Lancement

Pour faire fonctionner ce projet localement, suivez ces étapes :

### Prérequis

Assurez-vous d'avoir le SDK Flutter installé sur votre machine. Pour des instructions détaillées, consultez la [documentation officielle de Flutter](https://docs.flutter.dev/get-started/install).

### Installation

1.  Clonez le dépôt (ou téléchargez les sources) :
    ```sh
    git clone https://github.com/Donchaminade/fohuit_lois.git
    ```
2.  Naviguez vers le répertoire du projet :
    ```sh
    cd fohuit_lois
    ```
3.  Installez les dépendances :
    ```sh
    flutter pub get
    ```
4.  **Important (pour Windows) :** Si vous rencontrez des erreurs de permission Gradle, exécutez la commande suivante dans un terminal **Git Bash** :
    ```sh
    chmod +x android/gradlew
    ```

### Exécution de l'application

Connectez un appareil ou lancez un émulateur, puis exécutez la commande suivante :
```sh
flutter run
```

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Si vous souhaitez améliorer l'application, veuillez d'abord ouvrir une "issue" pour discuter des changements que vous aimeriez apporter.

---

## 📜 Licence

Ce projet est distribué sous la licence MIT. Voir le fichier `LICENSE` pour plus d'informations.