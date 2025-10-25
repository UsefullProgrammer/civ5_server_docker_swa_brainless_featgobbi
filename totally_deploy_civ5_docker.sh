#!/bin/bash
#!/bin/bash

set -e

# 🌍 Selezione lingua
echo "Select language / Seleziona lingua:"
echo "1) English"
echo "2) Italiano"
read -p "Choice / Scelta [1-2]: " lang

if [[ "$lang" == "2" ]]; then
    # 🇮🇹 Italiano
    PRE = "Preparazioni preliminari"
    USERAWS ="Inserisci il tuo username AWS (es. ec2-user): "
    CLONE_MSG="Clonazione del repository Civ V Docker..."
    LOGIN_PROMPT="Vuoi usare Steam login per scaricare Civ V?"
    LOGIN_CHOICE="Digita 'sì' per usare Steam oppure 'no' per caricare manualmente i file: "
    MANUAL_PATH_MSG="Carica manualmente i file di Civ V nella cartella:"
    FILE_CHECK_MSG="Controllo file..."
    FILE_FOUND_MSG="File trovati correttamente!"
    FILE_MISSING_MSG="Mancano uno o entrambi i file:"
    FILE_WAIT_MSG="Attendi o copia i file nella cartella, poi premi INVIO per riprovare (o digita 'exit' per uscire): "
    BUILD_MSG="Compilazione del container..."
    RUN_MSG="Avvio del container..."
    DONE_MSG="Container avviato. Puoi connetterti via VNC su porta 5900."
    TUNNEL_MSG="ssh -NL 5900:127.0.0.1:5900 ec2-user@<tuo-ip>"
else
    # 🇬🇧 English
    PRE = "Preliminary preparations"
    USERAWS ="Please provide your AWS login username (e.g., ec2-user):"
    CLONE_MSG="Cloning Civ V Docker repository..."
    LOGIN_PROMPT="Do you want to use Steam login to download Civ V?"
    LOGIN_CHOICE="Type 'yes' to use Steam or 'no' to manually upload the game files: "
    MANUAL_PATH_MSG="Manually upload Civ V files to the folder:"
    FILE_CHECK_MSG="Checking for required files..."
    FILE_FOUND_MSG="Civ V files found!"
    FILE_MISSING_MSG="One or both required files are missing:"
    FILE_WAIT_MSG="Upload the files and press ENTER to retry (or type 'exit' to quit): "
    BUILD_MSG="Building the container..."
    RUN_MSG="Starting the container..."
    DONE_MSG="Container started. You can connect via VNC on port 5900."
    TUNNEL_MSG="ssh -NL 5900:127.0.0.1:5900 <useraws>@<your-ip>"
fi


echo "$PRE"
sudo dnf install git -y

sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
read -p "$USERAWS" useraws
sudo usermod -aG docker $useraws
newgrp docker
echo "$CLONE_MSG"
git clone https://gitlab.com/CraftedCart/civ5_server_docker.git`
cd civ5_server_docker

echo "$LOGIN_PROMPT"
read -p "$LOGIN_CHOICE" scelta

if [[ "$scelta" == "sì" || "$scelta" == "yes" ]]; then
    read -p "Steam username: " steam_user
    read -s -p "Steam password: " steam_pass
    echo ""
    echo "🎮 Downloading Civ V via Steam..."
    ./install_civ.sh "$steam_user" "$steam_pass"
else
    echo "$MANUAL_PATH_MSG"
    echo "$(pwd)/civ5game"
    mkdir -p civ5game

    while true; do
        read -p "Premi INVIO quando hai copiato i file..." var
        if [[ "$var" == "exit" ]]; then
            echo "Interrupt script"
            exit 0
        fi
        echo "$FILE_CHECK_MSG"
        if [[ -f "civ5game/CivilizationV_Server.exe" && -f "civ5game/CivilizationV.exe" ]]; then
            echo "$FILE_FOUND_MSG"
            break
        else
            echo "$FILE_MISSING_MSG"
            [[ ! -f "civ5game/CivilizationV_Server.exe" ]] && echo "- CivilizationV_Server.exe"
            [[ ! -f "civ5game/CivilizationV.exe" ]] && echo "- CivilizationV.exe"
            read -p "$FILE_WAIT_MSG" var
            [[ "$var" == "exit" ]] && exit 0
        fi
    done
fi
echo "$BUILD_MSG"
./build.sh

echo "$RUN_MSG"
./run.sh

echo "$DONE_MSG"
echo "$TUNNEL_MSG"
echo 

