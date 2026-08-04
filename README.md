# Friday Night Funkin' - Multiverse Collection

Moteur à l'origine utilisé sur le [Mind Games Mod](https://gamebanana.com/mods/301107), pensé pour corriger les nombreux problèmes de la version vanilla tout en gardant son côté casual.
Se veut aussi une alternative plus simple pour les développeurs débutants.

---

## FNF - 0.6.3 - Patched

Ce code source provient bien de **Psych Engine** par **Shadow Mario**.
Le build a été modifié et réorganisé pour le développement du moteur.

### Modifications principales

- Rangement des fichiers sources `.hx` dans des dossiers *(comme sur la 0.7)*.

<img width="1360" height="814" alt="image" src="https://github.com/user-attachments/assets/47042fc5-82a9-472a-930f-1a4b2e3962b3" />


- Correction d'un gros bug de **shader** survenant lors de l'utilisation de scripts **Lua** pour changer les couleurs du stage, du background, de la barre de vie, etc.
- Suppression de plusieurs défauts de FNF que l'équipe n'aimait pas.

Voilà tout ! :>

---

## Installation du jeu

**— Mec, comment j'installe ?**

C'est très simple :

1. Télécharge le fichier `.bin`.
2. Extrais-le avec **7-Zip** ou **WinRAR**.
3. Lance ton jeu !

---

## Installation et compilation du code

**— Mais... comment je fais mon propre mod, moi ?**

Il te faudra plusieurs outils installés sur ta machine pour modifier et compiler correctement ton jeu.

**— Compi-quoi ?**

Compiler, en gros, ça veut dire transformer le code que tu as écrit en une version lisible par ton PC.
Le code est traduit en langage binaire pour pouvoir être exécuté sur ta machine.

Un exemple visuel pour mieux comprendre:

<img width="1589" height="669" alt="Compiler-2" src="https://github.com/user-attachments/assets/947c6ad0-4afa-4b07-be16-f8623f79f24d" />

### Outils requis (version 0.6.3)

#### Visual Studio 2026/19 "Minimum"

Pendant l'installation, ajoute ces composants individuels :

- **Desktop development with C++**
- **Windows SDK 10 ou 11** (si t'es casse-couilles sur la version)

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/640b628c-7775-48c6-b1f9-501b88d9c5af" />

#### Autres outils nécessaires

- **Haxe** — version **4.2.5** exactement *(ne prends pas une version plus récente, j'insiste là-dessus)*
- **Git**
- **Visual Studio Code** ou un autre IDE de ton choix
- Utilise **Install-FNF-Tools.bat** pour l'installation automatique des dépendances (haxelibs, etc.)

### Étapes rapides

```bash
git clone <url-du-repo>
cd nom-du-dossier/setup
Install-FNF-Tools.bat
```

Une fois les dépendances installées via le `.bat`, tu peux ouvrir le projet dans ton IDE et compiler directement.

### En cas de blocage

Si tu galères sur les outils ou la compilation du moteur, tout le nécessaire est dispo sur le **Google Drive** original :
👉 [Lien de la doc](https://drive.google.com/file/d/1_HoXLj_nORyT8AjnVa4I26qOAw0HTwbL/view)

---

## Crédits

- **Nazu (moi)** — Programmeur / Compositeur
- **Dorix** — Artiste / Directeur
- **Thatou** — Artiste / Chromatic of Starlight
- **Crashy** — Charting
- **Vastor** — Programmeur Lua

---

Merci de reporter les bugs du moteur ! Amusez-vous bien avec le mod. ✨
