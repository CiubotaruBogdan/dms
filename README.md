# Ubuntu Initializer

Acest repository conține script-ul `ubuntu_initializer.sh` care oferă un meniu interactiv pentru a actualiza sistemul Ubuntu și a instala diverse aplicații utile, inclusiv:
- Actualizare Linux
- Instalare Ollama
- Instalare Docker
- Instalare MilDocDMS

## Funcționalități

- **00. Afișează log-uri:**  
  Afișează conținutul fișierului de loguri localizat în `/tmp/script_intretinere.log`.

- **01. Șterge log-uri:**  
  Șterge (trunchează) fișierul de loguri pentru a începe o nouă sesiune de diagnosticare.

- **1. Actualizează Linux:**  
  Rulează `apt-get update` și `apt-get upgrade -y` pentru a actualiza sistemul cu cele mai recente pachete.

- **2. Instalează Ollama:**  
  Instalează Ollama prin rularea comenzii:
  ```bash
  curl -fsSL https://ollama.com/install.sh | sh
