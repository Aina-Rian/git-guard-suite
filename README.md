# Git Guard Suite

Une suite de scripts d'automatisation intelligente pour Linux (GNOME / Zsh) qui intercepte vos habitudes de travail pour s'assurer que votre code est **systématiquement sauvegardé et poussé sur GitHub** avant de couper votre ordinateur ou de finir votre journée.

## 🌟 Fonctionnalités

La suite déploie 4 couches de sécurité indépendantes :
1. **VS Code Watcher** : Déclenche votre script Git dès que vous fermez la fenêtre de votre projet sur VS Code.
2. **Déclencheur Horaire** : Une tâche Cron qui ouvre le prompt à 17h00 pile, alliée à un check d'ouverture de session tardive.
3. **Zsh Shell Hooks** : Ouvre le script si vous tapez `exit` dans votre dossier de projet, ou si vous ouvrez un terminal après 17h.
4. **Battery Guard** : Alerte de sauvegarde automatique dès que votre batterie descend sous les 20%.

## 📦 Installation

Clonez ce dépôt et lancez simplement le script d'installation :

```bash
git clone [https://github.com/VOTRE_PSEUDO/git-guard-suite.git](https://github.com/VOTRE_PSEUDO/git-guard-suite.git)
cd git-guard-suite
chmod +x install.sh
./install.sh
