# Hémycicle App

Hémycicle App est une application Android développée en Flutter qui permet de scanner les QR codes Vcard des députés de l'Assemblée Nationale (2025) ou de consulter la liste complète des députés détaillés.

Présentation vidéo du projet :

https://youtube.com/shorts/yX_IB6MhsSk?feature=share

## Fonctionnalités

- Scanner le QR code d'un député pour obtenir ses informations.
- Consulter la liste complète des députés.
- Filtrer la liste par nom
- Afficher les détails d'un député sélectionné.
- Voir l'historique d'entrée d'un député.

## Installation

1. Clonez le dépôt :

   git clone https://github.com/theondank/flutter_hackathon_janvier.git

2. Accédez au répertoire du projet :

   cd flutter_hackathon_janvier

3. Installez les dépendances :
   flutter pub get

## Utilisation

1. Lancez l'application :

flutter run

2. Scannez le QR code d'un député ou consultez la liste complète des députés

## Structure des fichiers

- main.dart : Point d'entrée principal de l'application.
- deputes_page.dart : Page affichant la liste des députés ainsi que les détails .
- mobile_scanner_overlay.dart : Page pour scanner les QR codes des députés.
- app_bar.dart : Barre d'application personnalisée.
