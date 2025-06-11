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
    # Verifică dacă containerul "mildocdms-webserver-1" este running
    web_container=$(docker ps --filter "name=mildocdms-webserver-1" --format "{{.Names}}" | head -n 1)
    if [ -n "$web_container" ]; then
        web_running=1
    else
        web_running=0
    fi

    # Determină dacă MilDocDMS este instalat
    if [ -n "$SUDO_USER" ]; then
        user_home=$(eval echo "~$SUDO_USER")
    else
        user_home="$HOME"
    fi
    mildocdms_dir="$user_home/mildocdms"
    if [ -d "$mildocdms_dir" ]; then
        mildocdms_installed=1
    else
        mildocdms_installed=0
    fi

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
    if [ "$mildocdms_installed" -eq 1 ]; then
        echo "6. Mount container MilDocDMS (docker compose up -d)"
    fi
    if [ "$web_running" -eq 1 ]; then
        echo "7. Creare super utilizator (createsuperuser)"
        echo "8. Accesează shell container webserver"
        echo "9. Afișează path-ul folderului MilDocDMS"
    fi
    echo "10. Instalează și configurează Samba"
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
            apt-get update 2>&1 | tee -a "$LOG_FILE"
            update_exit=${PIPESTATUS[0]}
            apt-get upgrade -y 2>&1 | tee -a "$LOG_FILE"
            upgrade_exit=${PIPESTATUS[0]}
            if [ $update_exit -eq 0 ] && [ $upgrade_exit -eq 0 ]; then
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
            curl -fsSL https://ollama.com/install.sh 2>&1 | tee -a "$LOG_FILE" | sh
            ollama_exit=${PIPESTATUS[2]}
            if [ $ollama_exit -eq 0 ]; then
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
            apt-get update 2>&1 | tee -a "$LOG_FILE"
            update_exit=${PIPESTATUS[0]}
            apt-get install -y ca-certificates curl 2>&1 | tee -a "$LOG_FILE"
            install_exit=${PIPESTATUS[0]}
            install -m 0755 -d /etc/apt/keyrings 2>&1 | tee -a "$LOG_FILE"
            keyrings_exit=${PIPESTATUS[0]}
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc 2>&1 | tee -a "$LOG_FILE"
            curl_exit=${PIPESTATUS[0]}
            chmod a+r /etc/apt/keyrings/docker.asc 2>&1 | tee -a "$LOG_FILE"
            . /etc/os-release
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" \
                | tee /etc/apt/sources.list.d/docker.list 2>&1 | tee -a "$LOG_FILE"
            apt-get update 2>&1 | tee -a "$LOG_FILE"
            apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>&1 | tee -a "$LOG_FILE"
            docker_install_exit=${PIPESTATUS[0]}
            if [ $update_exit -eq 0 ] && [ $install_exit -eq 0 ] && [ $keyrings_exit -eq 0 ] && [ $curl_exit -eq 0 ] && [ $docker_install_exit -eq 0 ]; then
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
            mkdir -p "$mildocdms_dir" 2>&1 | tee -a "$LOG_FILE"
            cd "$mildocdms_dir" || { echo "Nu se poate accesa directorul $mildocdms_dir"; continue; }
            rm -f docker-compose.env docker-compose.yml 2>&1 | tee -a "$LOG_FILE"
            echo "Se descarcă docker-compose.env..."
            wget -O docker-compose.env https://raw.githubusercontent.com/CiubotaruBogdan/dms/main/docker/docker-compose.env 2>&1 | tee -a "$LOG_FILE"
            env_exit=${PIPESTATUS[0]}
            if [ $env_exit -ne 0 ]; then
                echo -e "\033[1;31mEroare la descărcarea docker-compose.env.\033[0m"
                continue
            fi
            echo "Se descarcă docker-compose.yml..."
            wget -O docker-compose.yml https://raw.githubusercontent.com/CiubotaruBogdan/dms/main/docker/docker-compose.yml 2>&1 | tee -a "$LOG_FILE"
            yml_exit=${PIPESTATUS[0]}
            if [ $yml_exit -ne 0 ]; then
                echo -e "\033[1;31mEroare la descărcarea docker-compose.yml.\033[0m"
                continue
            fi
            echo "Pornește MilDocDMS cu docker compose up -d..."
            docker compose up -d 2>&1 | tee -a "$LOG_FILE"
            docker_up_exit=${PIPESTATUS[0]}
            if [ $docker_up_exit -eq 0 ]; then
                echo -e "\033[1;32mMilDocDMS a fost instalat și pornit cu succes.\033[0m"
                log "MilDocDMS instalat cu succes."
                echo -e "\nStatusul containerelor MilDocDMS:"
                docker compose ps 2>&1 | tee -a "$LOG_FILE"
                echo -e "\n--- Urmărirea log-urilor în timp real ---"
                docker compose logs --follow --tail=100
            else
                echo -e "\033[1;31mEroare la instalarea MilDocDMS.\033[0m"
                log "Eroare la instalarea MilDocDMS."
            fi
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        5)
            echo "Dezinstalare MilDocDMS (docker compose down -v)..."
            if [ -d "$mildocdms_dir" ]; then
                cd "$mildocdms_dir" || { echo "Nu se poate accesa directorul $mildocdms_dir"; continue; }
                docker compose down -v 2>&1 | tee -a "$LOG_FILE"
                down_exit=${PIPESTATUS[0]}
                cd - >/dev/null
            else
                echo "Directorul MilDocDMS nu există. Încerc să opresc containerele existente..."
                containers=$(docker ps -aq --filter label=com.docker.compose.project=mildocdms)
                if [ -n "$containers" ]; then
                    docker rm -f $containers 2>&1 | tee -a "$LOG_FILE"
                fi
                volumes=$(docker volume ls -q --filter label=com.docker.compose.project=mildocdms)
                if [ -n "$volumes" ]; then
                    docker volume rm $volumes 2>&1 | tee -a "$LOG_FILE"
                fi
                networks=$(docker network ls -q --filter label=com.docker.compose.project=mildocdms)
                if [ -n "$networks" ]; then
                    docker network rm $networks 2>&1 | tee -a "$LOG_FILE"
                fi
                down_exit=0
            fi
            if [ $down_exit -eq 0 ]; then
                rm -rf "$mildocdms_dir" 2>&1 | tee -a "$LOG_FILE"
                rm_exit=${PIPESTATUS[0]}
                if [ $rm_exit -eq 0 ]; then
                    echo -e "\033[1;32mMilDocDMS a fost dezinstalat și toate fișierele au fost șterse.\033[0m"
                    log "MilDocDMS și datele au fost șterse."
                else
                    echo -e "\033[1;31mContainerele au fost oprite, dar nu am putut șterge fișierele.\033[0m"
                    log "Eroare la ștergerea fișierelor MilDocDMS."
                fi
            else
                echo -e "\033[1;31mEroare la dezinstalarea MilDocDMS.\033[0m"
                log "Eroare la dezinstalarea MilDocDMS."
            fi
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        6)
            echo "Mount container MilDocDMS (docker compose up -d)..."
            if [ "$mildocdms_installed" -eq 0 ]; then
                echo "Directorul MilDocDMS nu există. Instalează MilDocDMS mai întâi (opțiunea 4)."
                read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
                continue
            fi
            cd "$mildocdms_dir" || { echo "Nu se poate accesa directorul $mildocdms_dir"; continue; }
            docker compose up -d 2>&1 | tee -a "$LOG_FILE"
            mount_exit=${PIPESTATUS[0]}
            if [ $mount_exit -eq 0 ]; then
                echo -e "\033[1;32mContainerul MilDocDMS a fost montat cu succes.\033[0m"
                log "Container MilDocDMS montat cu succes."
                echo -e "\nStatusul containerelor MilDocDMS:"
                docker compose ps 2>&1 | tee -a "$LOG_FILE"
                echo -e "\n--- Urmărirea log-urilor în timp real ---"
                docker compose logs --follow --tail=100
            else
                echo -e "\033[1;31mEroare la montarea containerului MilDocDMS.\033[0m"
                log "Eroare la montarea containerului MilDocDMS."
            fi
            read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            ;;
        7)
            if [ "$web_running" -eq 1 ]; then
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
                docker compose run --rm webserver createsuperuser 2>&1 | tee -a "$LOG_FILE"
                read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            fi
            ;;
        8)
            if [ "$web_running" -eq 1 ]; then
                echo "Acces container webserver..."
                container_name=$(docker ps --filter "name=webserver" --format "{{.Names}}" | head -n 1)
                if [ -z "$container_name" ]; then
                    echo "Nu s-a găsit containerul webserver."
                else
                    echo "Intrare în containerul $container_name..."
                    docker exec -it "$container_name" bash 2>&1 | tee -a "$LOG_FILE"
                fi
                read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            fi
            ;;
        9)
            if [ "$web_running" -eq 1 ]; then
                echo "Path-ul folderului MilDocDMS este:"
                if [ -n "$SUDO_USER" ]; then
                    user_home=$(eval echo "~$SUDO_USER")
                else
                    user_home="$HOME"
                fi
                mildocdms_dir="$user_home/mildocdms"
                echo "$mildocdms_dir"
                read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
            fi
            ;;
        10)
            echo "Instalare și configurare Samba..."
            log "Încep instalarea Samba."
            if ! dpkg -s samba >/dev/null 2>&1; then
                apt-get install -y samba 2>&1 | tee -a "$LOG_FILE"
                samba_install_exit=${PIPESTATUS[0]}
                if [ $samba_install_exit -ne 0 ]; then
                    echo -e "\033[1;31mEroare la instalarea Samba.\033[0m"
                    log "Eroare la instalarea Samba."
                    read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
                    continue
                fi
            else
                echo "Samba este deja instalat."
                samba_install_exit=0
            fi
            if [ -n "$SUDO_USER" ]; then
                user_home=$(eval echo "~$SUDO_USER")
            else
                user_home="$HOME"
            fi
            mildocdms_dir="$user_home/mildocdms"
            originals_path="$mildocdms_dir/media/documents/originals"
            archive_path="$mildocdms_dir/media/documents/archive"
            if [ ! -d "$originals_path" ] || [ ! -d "$archive_path" ]; then
                echo "Directorul MilDocDMS sau subdirectoarele necesare nu există."
                log "Eroare: directoarele pentru Samba lipsesc."
                read -n1 -rsp $'\nApasă orice tastă pentru a reveni la meniu...\n'
                continue
            fi
            if ! grep -q "\[originals\]" /etc/samba/smb.conf; then
                cat <<EOF >> /etc/samba/smb.conf

[originals]
   path = $originals_path
   browseable = yes
   writable = yes
   guest ok = yes
   read only = no

[archive]
   path = $archive_path
   browseable = yes
   writable = yes
   guest ok = yes
   read only = no
EOF
            fi
            systemctl restart smbd 2>&1 | tee -a "$LOG_FILE"
            restart_exit=${PIPESTATUS[0]}
            if [ $restart_exit -eq 0 ] && [ $samba_install_exit -eq 0 ]; then
                host_ip=$(hostname -I | awk '{print $1}')
                echo -e "\033[1;32mSamba configurat. Accesați share-urile de pe Windows:\033[0m"
                echo -e "  \\${host_ip}\\originals"
                echo -e "  \\${host_ip}\\archive"
                log "Samba instalat și configurat."
            else
                echo -e "\033[1;31mEroare la configurarea Samba.\033[0m"
                log "Eroare la configurarea Samba."
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
