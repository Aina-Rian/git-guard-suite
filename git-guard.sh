#!/bin/bash

for cmd in git zenity notify-send; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "[Git Guard] Dépendance manquante : $cmd" >&2
        exit 1
    fi
done

USER_ID=$(whoami)
export DISPLAY=:0
export XAUTHORITY=/home/$USER_ID/.Xauthority
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
export WAYLAND_DISPLAY=wayland-0

PROJECT_DIR=PROJECT_DIR 
if ! cd "$PROJECT_DIR" 2>/dev/null; then
    notify-send "🔒 Git Guard" "Projet introuvable : $PROJECT_DIR" \
        --icon=dialog-error --expire-time=5000
    exit 1
fi

GIT_STATUS=$(git status --short 2>/dev/null)
GIT_LOG=$(git log @{u}.. --oneline 2>/dev/null)
CURRENT_BRANCH=$(git branch --show-current)

if [ -z "$GIT_STATUS" ] && [ -z "$GIT_LOG" ]; then
    exit 0
fi

FORMATTED_STATUS=$(echo "$GIT_STATUS" | sed \
    -e 's/^ M /  ✏️  Modifié   : /g' \
    -e 's/^M  /  ✏️  Modifié   : /g' \
    -e 's/^MM /  ✏️  Modifié   : /g' \
    -e 's/^?? /  ➕ Nouveau   : /g' \
    -e 's/^ D /  🗑️  Supprimé : /g' \
    -e 's/^D  /  🗑️  Supprimé : /g' \
    -e 's/^A  /  ✅ Ajouté    : /g' \
    -e 's/^R  /  🔄 Renommé   : /g')

INFO_CONTENT="Voici l'état de votre projet Git aujourd'hui :\n\n"
INFO_CONTENT+="  📁 Projet  : $(basename "$PROJECT_DIR")\n"
INFO_CONTENT+="  🌿 Branche : $CURRENT_BRANCH\n\n"

if [ -n "$GIT_STATUS" ]; then
    INFO_CONTENT+="── Fichiers modifiés non commités ──\n"
    INFO_CONTENT+="$FORMATTED_STATUS\n\n"
fi
if [ -n "$GIT_LOG" ]; then
    INFO_CONTENT+="── Commits locaux prêts à être pushés ──\n"
    INFO_CONTENT+="$GIT_LOG\n\n"
fi

echo -e "$INFO_CONTENT" | zenity --text-info \
    --title="🔒 Git Guard – Statut du projet" \
    --ok-label="Pusher" \
    --cancel-label="Ignorer" \
    --width=580 \
    --height=420 \
    --checkbox="Je confirme vouloir traiter ces modifications"

[ $? -ne 0 ] && exit 0

TARGET_BRANCH="$CURRENT_BRANCH"
NEW_BRANCH_MODE=false

if zenity --question \
    --title="🌿 Git Guard – Choix de la branche" \
    --text="Voulez-vous pousser sur une <b>nouvelle branche</b> ?\n\nBranche actuelle : $CURRENT_BRANCH" \
    --ok-label="Nouvelle branche" \
    --cancel-label="Garder '$CURRENT_BRANCH'" \
    --width=460; then

    USER_BRANCH=$(zenity --entry \
        --title="🌿 Git Guard – Nom de la branche" \
        --text="Nom de la nouvelle branche :" \
        --entry-text="feature/wip-$(date +%Y%m%d)" \
        --width=420)

    if [ -z "$USER_BRANCH" ]; then
        zenity --warning \
            --title="Git Guard" \
            --text="Aucun nom saisi. Utilisation de la branche actuelle : $CURRENT_BRANCH" \
            --width=380
    else
        TARGET_BRANCH="$USER_BRANCH"
        NEW_BRANCH_MODE=true
    fi
fi

COMMIT_MSG="Sauvegarde automatique de git guard"

if [ -n "$GIT_STATUS" ]; then
    LABEL_WIDTH=$(( ${#TARGET_BRANCH} * 8 + 340 ))
    LABEL_WIDTH=$(( LABEL_WIDTH > 620 ? 620 : LABEL_WIDTH ))

    USER_INPUT=$(zenity --entry \
        --title="✏️  Git Guard – Message de commit" \
        --text="Message pour le commit sur la branche $TARGET_BRANCH :" \
        --entry-text="work in progress" \
        --width="$LABEL_WIDTH")

    if [ -n "$USER_INPUT" ]; then
        COMMIT_MSG="$USER_INPUT"
    fi
fi

GIT_ERROR_FILE=$(mktemp)

(
    if [ "$NEW_BRANCH_MODE" = true ]; then
        echo "8"  ; echo "# 🌿 Création de la branche $TARGET_BRANCH..."
        if ! git checkout -b "$TARGET_BRANCH" 2>"$GIT_ERROR_FILE"; then
            echo "ERREUR_BRANCH" > "$GIT_ERROR_FILE"
            exit 1
        fi
        sleep 0.3
    fi

    echo "25" ; echo "# 📦 Staging — git add ."
    git add . 2>"$GIT_ERROR_FILE"
    sleep 0.3

    echo "50" ; echo "# 💾 Commit : $COMMIT_MSG"
    if [ -n "$GIT_STATUS" ]; then
        if ! git commit -m "$COMMIT_MSG" 2>"$GIT_ERROR_FILE"; then
            echo "ERREUR_COMMIT" >> "$GIT_ERROR_FILE"
        fi
    fi
    sleep 0.3

    echo "75" ; echo "# 🚀 Push → origin/$TARGET_BRANCH"

    if git rev-parse --abbrev-ref "@{u}" &>/dev/null 2>&1 && [ "$NEW_BRANCH_MODE" = false ]; then
        PUSH_CMD="git push origin $TARGET_BRANCH"
    else
        PUSH_CMD="git push --set-upstream origin $TARGET_BRANCH"
    fi

    PUSH_OUTPUT=$($PUSH_CMD 2>&1)
    PUSH_EXIT=$?

    if [ $PUSH_EXIT -ne 0 ]; then
        echo "$PUSH_OUTPUT" > "$GIT_ERROR_FILE"
    fi

    echo "100" ; echo "# ✅ Synchronisation terminée !"
    sleep 0.3

) | zenity --progress \
    --title="🔒 Git Guard – Synchronisation" \
    --text="Préparation..." \
    --percentage=0 \
    --auto-close \
    --no-cancel \
    --width=500

GIT_ERROR_CONTENT=$(cat "$GIT_ERROR_FILE" 2>/dev/null)
rm -f "$GIT_ERROR_FILE"

if [ -n "$GIT_ERROR_CONTENT" ]; then
    zenity --error \
        --title="❌ Git Guard – Erreur" \
        --text="Une erreur s'est produite lors de la synchronisation :\n\n<tt>$GIT_ERROR_CONTENT</tt>\n\nVérifiez votre connexion ou vos credentials Git." \
        --width=520

    notify-send "❌ Git Guard" "Push échoué sur '$TARGET_BRANCH'" \
        --icon=dialog-error --expire-time=6000
else
    notify-send "🔒 Git Guard" "✓  Code sauvegardé sur '$TARGET_BRANCH'" \
        --icon=emblem-default --expire-time=4000
fi