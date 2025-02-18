#!/bin/bash
# Script de instalare MilDocDMS
# Acest script trebuie rulat ca root.
# Logurile se vor salva în /tmp/script_intretinere.log

LOG_FILE="/tmp/script_intretinere.log"

# Funcție pentru logare
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Verificare drepturi root
if [[ $EUID -ne 0 ]]; then
    echo "Acest script trebuie rulat ca root!"
    exit 1
fi

while true; do
    clear
    echo "======================================"
    echo "      Script de instalare MilDocDMS"
    echo "======================================"
    echo "00. Afișează log-uri"
    echo "01. Șterge log-uri"
    echo "1. Actualizează Linux"
    echo "2. Instalează Ollama"
    echo "3. Instalează Docker"
    echo "4. Instalează MilDocDMS"
    echo "5. Dezinstalează MilDocDMS (docker compose down)"
    echo "6. Mount container MilDocDMS (docker compose up -d)"
    echo "7. Creare super utilizator (createsuperuser)"
    echo "8. Accesează shell container webserver"
    echo "9. Deschide folderul MilDocDMS în File Explorer"
    echo "q. Ieșire"
    echo "--------------------------------------"
    read -p "Alege o opțiune: " opt

    case $opt in
        "00")
            echo "Afișare log-uri din $LOG_FILE:"
            echo "--------------------------------------"
            if [ -f "$LOG_FILE" ]; then
                cat "$LOG_FILE"
            else
                echo "Nu există log-uri de afișat."
            fi
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        "01")
            > "$LOG_FILE"
            echo "Log-uri șterse."
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        1)
            echo "Actualizare Linux..."
            log "Încep actualizarea Linux."
            apt-get update >> "$LOG_FILE" 2>&1 && apt-get upgrade -y >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                echo -e "\033[1;32mActualizare Linux completă.\033[0m"
                log "Actualizare Linux completată."
            else
                echo -e "\033[1;31mEroare la actualizarea Linux.\033[0m"
                log "Eroare la actualizarea Linux."
            fi
            echo -e "\n--- Log-ul operației ---"
            tail -n 10 "$LOG_FILE"
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        2)
            echo "Instalare Ollama..."
            log "Încep instalarea Ollama."
            curl -fsSL https://ollama.com/install.sh | sh >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                echo -e "\033[1;32mOllama instalat cu succes.\033[0m"
                log "Ollama instalat cu succes."
            else
                echo -e "\033[1;31mEroare la instalarea Ollama.\033[0m"
                log "Eroare la instalarea Ollama."
            fi
            echo -e "\n--- Log-ul operației ---"
            tail -n 10 "$LOG_FILE"
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        3)
            echo "Instalare Docker..."
            log "Încep instalarea Docker."
            apt-get update >> "$LOG_FILE" 2>&1
            apt-get install -y ca-certificates curl >> "$LOG_FILE" 2>&1
            install -m 0755 -d /etc/apt/keyrings >> "$LOG_FILE" 2>&1
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc >> "$LOG_FILE" 2>&1
            chmod a+r /etc/apt/keyrings/docker.asc
            . /etc/os-release
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" \
                | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update >> "$LOG_FILE" 2>&1
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                echo -e "\033[1;32mInstalare Docker completă.\033[0m"
                log "Instalare Docker completată."
            else
                echo -e "\033[1;31mEroare la instalarea Docker.\033[0m"
                log "Eroare la instalarea Docker."
            fi
            echo -e "\n--- Log-ul operației ---"
            tail -n 10 "$LOG_FILE"
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        4)
            echo "Instalare MilDocDMS..."
            if ! command -v docker &> /dev/null; then
                echo -e "\033[1;31mDocker nu este instalat. Instalează Docker mai întâi (opțiunea 3).\033[0m"
                read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
                continue
            fi
            log "Încep instalarea MilDocDMS."
            if [ -n "$SUDO_USER" ]; then
                user_home=$(eval echo "~$SUDO_USER")
            else
                user_home="$HOME"
            fi
            mildocdms_dir="$user_home/mildocdms"
            mkdir -p "$mildocdms_dir"
            cd "$mildocdms_dir" || { echo "Nu se poate accesa directorul $mildocdms_dir"; continue; }
            # Șterge fișierele existente pentru a forța descărcarea celor noi
            rm -f docker-compose.env docker-compose.yml
            echo "Se descarcă docker-compose.env..."
            wget -O docker-compose.env https://raw.githubusercontent.com/CiubotaruBogdan/dms/main/docker/docker-compose.env >> "$LOG_FILE" 2>&1
            if [ $? -ne 0 ]; then
                echo -e "\033[1;31mEroare la descărcarea docker-compose.env.\033[0m"
                continue
            fi
            echo "Se descarcă docker-compose.yml..."
            wget -O docker-compose.yml https://raw.githubusercontent.com/CiubotaruBogdan/dms/main/docker/docker-compose.yml >> "$LOG_FILE" 2>&1
            if [ $? -ne 0 ]; then
                echo -e "\033[1;31mEroare la descărcarea docker-compose.yml.\033[0m"
                continue
            fi
            echo "Pornește MilDocDMS cu docker compose up -d..."
            docker compose up -d >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                echo -e "\033[1;32mMilDocDMS a fost instalat și pornit cu succes.\033[0m"
                log "MilDocDMS instalat cu succes."
                echo -e "\nStatusul containerelor MilDocDMS:"
                docker compose ps
                echo -e "\n--- Urmărirea log-urilor în timp real ---"
                if command -v gnome-terminal &> /dev/null; then
                    gnome-terminal -- bash -c "docker compose logs --follow --tail=100; exec bash"
                elif command -v xterm &> /dev/null; then
                    xterm -e "docker compose logs --follow --tail=100"
                else
                    docker compose logs --follow --tail=100
                fi
            else
                echo -e "\033[1;31mEroare la instalarea MilDocDMS.\033[0m"
                log "Eroare la instalarea MilDocDMS."
            fi
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        5)
            echo "Dezinstalare MilDocDMS (docker compose down)..."
            if [ -n "$SUDO_USER" ]; then
                user_home=$(eval echo "~$SUDO_USER")
            else
                user_home="$HOME"
            fi
            mildocdms_dir="$user_home/mildocdms"
            if [ ! -d "$mildocdms_dir" ]; then
                echo "Directorul MilDocDMS nu există. Probabil nu a fost instalat."
                read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
                continue
            fi
            cd "$mildocdms_dir" || { echo "Nu se poate accesa directorul $mildocdms_dir"; continue; }
            docker compose down >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                echo -e "\033[1;32mMilDocDMS a fost dezinstalat cu succes.\033[0m"
                log "MilDocDMS dezinstalat cu succes."
            else
                echo -e "\033[1;31mEroare la dezinstalarea MilDocDMS.\033[0m"
                log "Eroare la dezinstalarea MilDocDMS."
            fi
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        6)
            echo "Mount container MilDocDMS (docker compose up -d)..."
            if [ -n "$SUDO_USER" ]; then
                user_home=$(eval echo "~$SUDO_USER")
            else
                user_home="$HOME"
            fi
            mildocdms_dir="$user_home/mildocdms"
            if [ ! -d "$mildocdms_dir" ]; then
                echo "Directorul MilDocDMS nu există. Instalează MilDocDMS mai întâi (opțiunea 4)."
                read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
                continue
            fi
            cd "$mildocdms_dir" || { echo "Nu se poate accesa directorul $mildocdms_dir"; continue; }
            docker compose up -d >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                echo -e "\033[1;32mContainerul MilDocDMS a fost montat cu succes.\033[0m"
                log "Container MilDocDMS montat cu succes."
                echo -e "\nStatusul containerelor MilDocDMS:"
                docker compose ps
                echo -e "\n--- Urmărirea log-urilor în timp real ---"
                if command -v gnome-terminal &> /dev/null; then
                    gnome-terminal -- bash -c "docker compose logs --follow --tail=100; exec bash"
                elif command -v xterm &> /dev/null; then
                    xterm -e "docker compose logs --follow --tail=100"
                else
                    docker compose logs --follow --tail=100
                fi
            else
                echo -e "\033[1;31mEroare la montarea containerului MilDocDMS.\033[0m"
                log "Eroare la montarea containerului MilDocDMS."
            fi
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        7)
            echo "Creare super utilizator (docker compose run --rm webserver createsuperuser)..."
            if [ -n "$SUDO_USER" ]; then
                user_home=$(eval echo "~$SUDO_USER")
            else
                user_home="$HOME"
            fi
            mildocdms_dir="$user_home/mildocdms"
            if [ ! -d "$mildocdms_dir" ]; then
                echo "Directorul MilDocDMS nu există. Instalează MilDocDMS mai întâi (opțiunea 4)."
                read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
                continue
            fi
            cd "$mildocdms_dir" || { echo "Nu se poate accesa directorul $mildocdms_dir"; continue; }
            docker compose run --rm webserver createsuperuser
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        8)
            echo "Acces container webserver..."
            container_name=$(docker ps --filter "name=webserver" --format "{{.Names}}" | head -n 1)
            if [ -z "$container_name" ]; then
                echo "Nu s-a găsit containerul webserver."
            else
                echo "Intrare în containerul $container_name..."
                docker exec -it "$container_name" bash
            fi
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        9)
            echo "Deschide folderul MilDocDMS în File Explorer..."
            if [ -n "$SUDO_USER" ]; then
                user_home=$(eval echo "~$SUDO_USER")
            else
                user_home="$HOME"
            fi
            mildocdms_dir="$user_home/mildocdms"
            if [ ! -d "$mildocdms_dir" ]; then
                echo "Directorul MilDocDMS nu există."
            else
                if [ -n "$DISPLAY" ]; then
                    sudo -u "$SUDO_USER" DISPLAY="$DISPLAY" XAUTHORITY="$user_home/.Xauthority" xdg-open "$mildocdms_dir"
                else
                    echo "Display-ul grafic nu este disponibil."
                fi
            fi
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        q|Q)
            echo "Ieșire..."
            exit 0
            ;;
        *)
            echo "Opțiune invalidă! Apasă orice tastă pentru a reveni la meniu..."
            read -n1 -rsp $'\n'
            ;;
    esac
done
