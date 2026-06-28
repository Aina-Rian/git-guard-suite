#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

USER_BIN_DIR="$HOME/.local/bin"
AUTOSTART_DIR="$HOME/.config/autostart"

mkdir -p "$USER_BIN_DIR"
mkdir -p "$AUTOSTART_DIR"

echo -e "${BLUE}=================================================="
echo -e "      INSTALLATEUR AUTOMATIQUE - GIT GUARD        "
echo -e "==================================================${NC}"

read -p "Entrez le chemin absolu de votre projet à surveiller : " PROJECT_DIR

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Erreur : Le dossier $PROJECT_DIR n'existe pas.${NC}"
    exit 1
fi

export PROJECT_DIR

# --- 0. INSTALLATION DU SCRIPT PRINCIPAL GIT-GUARD ---
echo -e "${YELLOW}Installation du script principal dans /usr/local/bin/...${NC}"
if [ -f "git-guard.sh" ]; then
    sed -i "s|PROJECT_DIR=.*|PROJECT_DIR=\"$PROJECT_DIR\"|g" git-guard.sh
    sudo cp git-guard.sh /usr/local/bin/git-guard.sh
    sudo chmod +x /usr/local/bin/git-guard.sh
    echo -e "${GREEN}✔ git-guard.sh installé avec succès.${NC}"
else
    echo -e "${RED}Erreur : Le fichier git-guard.sh est introuvable à la racine.${NC}"
    exit 1
fi

# --- 1. VS CODE WATCHER ---
echo -e "${YELLOW}Configuration du Watcher VS Code...${NC}"
sed "s|{{PROJECT_DIR}}|$PROJECT_DIR|g" scripts/watch-vscode.sh > "$USER_BIN_DIR/watch-vscode.sh"
chmod +x "$USER_BIN_DIR/watch-vscode.sh"
sed "s|{{USER_BIN_DIR}}|$USER_BIN_DIR|g" templates/git-guard-vscode.desktop > "$AUTOSTART_DIR/git-guard-vscode.desktop"

# --- 2. TIME TRIGGER ---
echo -e "${YELLOW}Configuration du Déclencheur Horaire (17h)...${NC}"
cp scripts/git-cron-check.sh "$USER_BIN_DIR/git-cron-check.sh"
chmod +x "$USER_BIN_DIR/git-cron-check.sh"
(crontab -l 2>/dev/null | grep -v "git-cron-check.sh" ; echo "0 17 * * * $USER_BIN_DIR/git-cron-check.sh") | crontab -
sed "s|{{USER_BIN_DIR}}|$USER_BIN_DIR|g" templates/git-guard-time.desktop > "$AUTOSTART_DIR/git-guard-time.desktop"

# --- 3. ZSH HOOKS ---
echo -e "${YELLOW}Configuration des Hooks Zsh...${NC}"
sed -i '/# === GIT GUARD HOOKS ===/,/# === END GIT GUARD ===/d' "$HOME/.zshrc"
cat << EOF >> "$HOME/.zshrc"

# === GIT GUARD HOOKS ===
zsh_git_guard_exit() {
    if [ "\$PWD" = "$PROJECT_DIR" ]; then
        /usr/local/bin/git-guard.sh
    fi
}
autoload -Uz add-zsh-hook
add-zsh-hook zshexit zsh_git_guard_exit

CURRENT_HOUR=\$(date +%H)
if [ "\$CURRENT_HOUR" -ge 17 ] && [ "\$PWD" = "$PROJECT_DIR" ]; then
    /usr/local/bin/git-guard.sh
fi
# === END GIT GUARD ===
EOF

# --- 4. BATTERY GUARD ---
echo -e "${YELLOW}Configuration de la Surveillance Batterie...${NC}"
cp scripts/git-battery-guard.sh "$USER_BIN_DIR/git-battery-guard.sh"
chmod +x "$USER_BIN_DIR/git-battery-guard.sh"
sed "s|{{USER_BIN_DIR}}|$USER_BIN_DIR|g" templates/git-guard-battery.desktop > "$AUTOSTART_DIR/git-guard-battery.desktop"

echo -e "${BLUE}=================================================="
echo -e "      INSTALLATION TERMINÉE AVEC SUCCÈS !        "
echo -e "==================================================${NC}"