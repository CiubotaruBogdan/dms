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
   wget https://raw.githubusercontent.com/CiubotaruBogdan/dms/main/init.sh && \
   dos2unix init.sh && \
   chmod +x init.sh && \
   sudo ./init.sh
   ```

## Funcționalități

### Gestionare Loguri
- **00. Afișează log-uri**  
  Afișează conținutul fișierului de loguri situat în `/tmp/script_intretinere.log`
- **01. Șterge log-uri**  
  Șterge (trunchează) fișierul de loguri pentru a începe o nouă sesiune de diagnosticare

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
- **5. Dezinstalează MilDocDMS**  
  Oprește și elimină containerele MilDocDMS (disponibil când serviciul rulează)
- **6. Mount container MilDocDMS**  
  Pornește containerele MilDocDMS folosind `docker compose up -d`
- **7. Creare super utilizator**  
  Creează un cont de administrator pentru interfața web (disponibil când serviciul rulează)
- **8. Accesează shell container webserver**  
  Deschide un shell în containerul webserver pentru operațiuni avansate
- **9. Afișează path-ul folderului MilDocDMS**
  Arată locația instalării MilDocDMS pe sistemul local
- **10. Instalează și configurează Samba**
  Permite partajarea folderelor `originals` și `archive` prin rețeaua locală

## Monitorizare și Logging

- Toate operațiunile sunt înregistrate în `/tmp/script_intretinere.log`
- Opțiunile de vizualizare (00) și ștergere (01) a logurilor sunt disponibile în meniul principal
- Pentru containerele active, scriptul oferă urmărirea log-urilor în timp real

## Note de Utilizare

- Scriptul trebuie rulat cu drepturi de administrator (sudo/root)
- Anumite opțiuni sunt disponibile doar când containerul MilDocDMS este activ
- Se recomandă instalarea în ordinea prezentată în meniu (1-4) pentru dependențe
- La instalarea MilDocDMS, asigurați-vă că Docker este instalat și funcțional

## Accesare din Windows prin Samba

După rularea opțiunii **10. Instalează și configurează Samba**, directoarele
`originals` și `archive` din MilDocDMS devin disponibile în rețea. Pentru a le
accesa de pe Windows:

1. Aflați adresa IP a serverului Linux cu `hostname -I`.
2. Deschideți Explorer și introduceți calea UNC corespunzătoare, de exemplu:
   ```
   \\<ip-server>\originals
   \\<ip-server>\archive
   ```
3. Puteți crea shortcut-uri sau mapări la aceste locații pentru acces rapid.

## Contribuții

Dacă întâmpinați probleme sau doriți să contribuiți cu îmbunătățiri:
1. Deschideți un issue pentru probleme sau sugestii
2. Creați un pull request pentru modificări
3. Consultați documentația pentru ghiduri de contribuție

## Securitate

- Scriptul verifică privilegiile necesare
- Folosește surse oficiale pentru instalarea componentelor
- Menține izolarea containerelor pentru securitate
