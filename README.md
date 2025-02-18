# MilDocDMS Installer

Acest repository conține script-ul `init.sh`, un instrument interactiv de întreținere pentru Ubuntu. Script-ul permite actualizarea sistemului și instalarea unor aplicații utile, precum Ollama, Docker și MilDocDMS, precum și gestionarea logurilor operațiunilor.

## Funcționalități

- **00. Afișează log-uri**  
  Afișează conținutul fișierului de loguri situat în `/tmp/script_intretinere.log`.

- **01. Șterge log-uri**  
  Șterge (trunchează) fișierul de loguri pentru a începe o nouă sesiune de diagnosticare.

- **1. Actualizează Linux**  
  Rulează `apt-get update` și `apt-get upgrade -y` pentru a actualiza sistemul cu cele mai recente pachete.

- **2. Instalează Ollama**  
  Instalează Ollama rulând comanda:
  ```bash
  curl -fsSL https://ollama.com/install.sh | sh
  ```
  Activitatea este logată în fișierul `/tmp/script_intretinere.log`.

- **3. Instalează Docker**  
  Configurează depozitul oficial Docker, importă cheia GPG și instalează Docker împreună cu componentele aferente:
  - `docker-ce`
  - `docker-ce-cli`
  - `containerd.io`
  - `docker-buildx-plugin`
  - `docker-compose-plugin`

- **4. Instalează MilDocDMS**  
  *Precondiție:* Docker trebuie să fie instalat (opțiunea 3).
  - Creează un director numit `mildocdms` în directorul home al utilizatorului non-root (cel care a folosit `sudo`).
  - Descarcă fișierele `docker-compose.env` și `docker-compose.yml` din repository-ul acestui proiect.
  - Pornește MilDocDMS cu comanda:
    ```bash
    docker compose up -d
    ```
  - După instalare, script-ul te întreabă dacă dorești să urmărești logurile în timp real (folosind `docker compose logs -f`).

- **q. Ieșire**  
  Închide script-ul.

## Prerequisites

Asigură-te că ai instalate următoarele pachete necesare pentru rularea scriptului:
```bash
sudo apt install -y wget dos2unix xrdp
```

## Instrucțiuni de Instalare și Rulare

1. Descărcă și rulează script-ul într-o singură comandă:
   ```bash
   wget https://github.com/CiubotaruBogdan/dms/init.sh && dos2unix init.sh && chmod +x init.sh && sudo ./init.sh
   ```

## Loguri
Toate operațiunile sunt logate în fișierul `/tmp/script_intretinere.log`. Utilizează opțiunile `00` pentru a vizualiza logurile și `01` pentru a le șterge.

## Contribuții
Dacă întâmpini probleme sau dorești să adaugi noi funcționalități, te rugăm să deschizi un issue sau să contribui printr-un pull request.
