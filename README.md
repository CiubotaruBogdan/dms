# MilDocDMS Installer

Acest repository conține script-ul `init.sh`, un instrument interactiv de întreținere pentru Ubuntu. Script-ul permite instalarea și gestionarea MilDocDMS și a dependențelor sale, precum și monitorizarea și întreținerea sistemului.

## Cerințe Sistem
- Ubuntu Linux
- Drepturi de administrator (root)
- Conexiune la internet
- Pachete necesare:
  ```bash
  sudo apt install -y wget dos2unix xrdp curl
  ```

## Instalare și Rulare

1. Descarcă și pregătește scriptul pentru rulare:
   ```bash
   rm -f init.sh* && wget https://raw.githubusercontent.com/CiubotaruBogdan/dms/main/init.sh && dos2unix init.sh && chmod +x init.sh && sudo ./init.sh
   ```

## Funcționalități

### Gestionare Loguri
- **00. Afișează log-uri**
  Afișează conținutul fișierului de loguri situat în `/tmp/script_intretinere.log`
- **01. Șterge log-uri**
  Șterge (trunchează) fișierul de loguri pentru a începe o nouă sesiune de diagnosticare
- **02. Alătură sistemul la domeniu**
  Configurează integrarea în domeniul Active Directory folosind `realm join`.

### Instalare și Actualizare
- **1. Actualizează Linux**
  Actualizează sistemul folosind `apt-get update` și `apt-get upgrade -y`
- **2. Instalează Ollama**
  Instalează platforma Ollama folosind scriptul oficial de instalare
- **3. Instalează Docker**
  Configurează și instalează Docker și componentele necesare:
  - docker-ce
  - docker-ce-cli
  - containerd.io
  - docker-buildx-plugin
  - docker-compose-plugin
- **4. Instalează MilDocDMS**
  Instalează și configurează MilDocDMS:
  - Creează directorul de lucru în home-ul utilizatorului
  - Descarcă și configurează fișierele docker-compose
  - Pornește containerele necesare
  - Oferă opțiunea de urmărire log-uri în timp real

### Gestionare Container MilDocDMS
- **6. Dezinstalează complet MilDocDMS**
  Elimină containerele, volumele și directorul MilDocDMS (dacă există). Curăță orice resurse Docker rămase chiar dacă folderul a fost șters, inclusiv volumele cu baza de date și fișierele media.
- **7. Mount container MilDocDMS**
  Pornește containerele MilDocDMS folosind `docker compose up -d` (disponibil doar după instalare)
- **8. Creare super utilizator**
  Creează un cont de administrator pentru interfața web (disponibil când serviciul rulează)
- **9. Accesează shell container webserver**
  Deschide un shell în containerul webserver pentru operațiuni avansate
- **10. Afișează path-ul folderului MilDocDMS**
  Arată locația instalării MilDocDMS pe sistemul local

## Monitorizare și Logging

- Toate operațiunile sunt înregistrate în `/tmp/script_intretinere.log`
- Opțiunile de vizualizare (00) și ștergere (01) a logurilor sunt disponibile în meniul principal
- Pentru containerele active, scriptul oferă urmărirea log-urilor în timp real

## Note de Utilizare

- Scriptul trebuie rulat cu drepturi de administrator (sudo/root)
- Anumite opțiuni sunt disponibile doar când containerul MilDocDMS este activ
- Se recomandă instalarea în ordinea prezentată în meniu (1-4) pentru dependențe
- La instalarea MilDocDMS, asigurați-vă că Docker este instalat și funcțional

## Accesare foldere din sistemul host

După instalarea aplicației, documentele sunt stocate în directorul `~/mildocdms`. Puteți accesa fișierele originale și arhivate la:

```bash
~/mildocdms/media/documents/originals
~/mildocdms/media/documents/archive
```


## Contribuții

Dacă întâmpinați probleme sau doriți să contribuiți cu îmbunătățiri:
1. Deschideți un issue pentru probleme sau sugestii
2. Creați un pull request pentru modificări
3. Consultați documentația pentru ghiduri de contribuție

## Securitate

- Scriptul verifică privilegiile necesare
- Folosește surse oficiale pentru instalarea componentelor
- Menține izolarea containerelor pentru securitate
