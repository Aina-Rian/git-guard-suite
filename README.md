# 🔒 Git Guard Suite

Une suite d'automatisation intelligente et proactive pour Linux qui intercepte vos habitudes de travail pour s'assurer que vos projets de développement sont **systématiquement sauvegardés et poussés sur GitHub/GitLab** avant de couper votre ordinateur, de fermer votre éditeur ou de quitter votre terminal.

Plutôt que de se battre contre les gestionnaires de sessions graphiques rigides, **Git Guard** déploie plusieurs couches de détection (logicielle, horaire, shell et matérielle) pour s'adapter à votre flux de travail de développeur.

---

## 🌟 Fonctionnalités & Couches de Sécurité

La suite configure et gère 4 modules de surveillance indépendants et ultra-légers :

1. **💻 VS Code Watcher (`watch-vscode.sh`)** : Surveille l'activité de votre éditeur. Dès que vous fermez la fenêtre de votre projet spécifique, le prompt de sauvegarde surgit instantanément.
2. **⏰ Déclencheur Horaire (`git-cron-check.sh`)** : Une tâche Cron planifiée à 17h00 pile pour vous inviter à sécuriser votre code en fin de journée. Ce module vérifie également si vous ouvrez une session de travail après 17h pour un rappel immédiat.
3. **🐚 Zsh Shell Hooks (Intégré au `.zshrc`)** : Intercepte la commande `exit` ou la fermeture de votre terminal lorsque vous vous trouvez dans le répertoire du projet. De plus, ouvrir un terminal dans ce dossier après 17h déclenche passivement le script.
4. **🔋 Battery Guard (`git-battery-guard.sh`)** : Une sécurité matérielle essentielle. Si vous travaillez sur batterie et qu'elle passe **sous la barre des 20%**, le script se lance pour éviter toute perte de code due à une coupure de courant soudaine.

---

## 🐧 Distributions Linux Supportées

**Git Guard Suite** est optimisé pour les environnements de bureau modernes utilisant des serveurs d'affichage **X11** ou **Wayland**.

### 🔹 Entièrement Supportées (Clé en main)
* **Ubuntu** (20.04, 22.04, 24.04+)
* **Debian** (11, 12+)
* **Pop!_OS**, **Linux Mint**, **Zorin OS**
* **Fedora** (Workstation avec GNOME)

### 🔸 Compatibilité des Environnements de Bureau (DE)
* **GNOME Shell** : Support natif complet (gère l'autostart via fichiers `.desktop`).
* **XFCE / KDE Plasma / Cinnamon** : Entièrement compatible. *Note : L'affichage des fenêtres Zenity fonctionne parfaitement, mais la gestion de l'autostart des démons peut nécessiter une intégration manuelle selon votre gestionnaire d'applications au démarrage.*

---

## 🛠️ Prérequis Système

Le script principal utilise des outils natifs Linux pour l'affichage graphique et les notifications. Assurez-vous d'avoir les paquets suivants (le script validera leur présence) :

* **`git`** : Pour la gestion du dépôt.
* **`zenity`** : Pour l'affichage des boîtes de dialogue graphiques (choix des branches, saisie du commit, barre de progression).
* **`notify-send`** (`libnotify-bin`) : Pour les notifications système de succès ou d'erreur.
* **`upower`** : Requis pour le module *Battery Guard*.

```bash
sudo apt update && sudo apt install git zenity libnotify-bin upower
```

---

## 📦 Installation

```bash
git clone https://github.com/aina-rian/git-guard-suite.git
cd git-guard-suite
chmod +x install.sh
./install.sh
```

---

## 📦 Desinstallation

```bash
sudo rm -f /usr/local/bin/git-guard.sh
rm -f ~/.local/bin/watch-vscode.sh
rm -f ~/.local/bin/git-cron-check.sh
rm -f ~/.local/bin/git-battery-guard.sh
rm -f ~/.config/autostart/git-guard-*.desktop
crontab -l 2>/dev/null | grep -v "git-cron-check.sh" | crontab -
```

# Ouvrez votre fichier ~/.zshrc et supprimez manuellement le bloc situé entre :
# # === GIT GUARD HOOKS ===
# ...
# # === END GIT GUARD ===
