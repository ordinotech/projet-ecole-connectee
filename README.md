# 🔎 Projet École Connectée (En Cours)

Infrastructure complète d'école connectée simulée sous Proxmox : segmentation réseau par VLAN, Active Directory, filtrage DNS, portail web d'inscription (PHP/MariaDB) exposé en HTTPS via une PKI interne (ADCS), automatisation PowerShell, durcissement sécurité, et un chatbot IT local (Ollama + Open WebUI) pour le support technique.

> **Statut :** projet en cours. La Phase 6 (fichiers SMB + audit sécurité) est planifiée mais pas encore réalisée.

## Stack technique

`Proxmox VE` · `OPNsense` · `Windows Server / Active Directory` · `Pi-hole` · `PHP` · `MariaDB` · `Nginx` · `ADCS (PKI interne)` · `PowerShell` · `Docker / Docker Compose` · `Ollama` · `Open WebUI`

## Architecture réseau

```
vmbr0 (WAN) ──► OPNsense ──► vmbr1 (trunk VLAN-aware)
                                   ├── VLAN 10 → Étudiants  (10.0.10.0/24)
                                   ├── VLAN 20 → Serveurs   (10.0.20.0/24)
                                   └── VLAN 30 → Profs      (10.0.30.0/24)
```

## Sommaire du lab

| Phase | Contenu | Doc |
| --- | --- | --- |
| 1 | Proxmox & plan réseau : VLANs, vSwitchs, plan des VMs/CTs | [docs/phase-1-proxmox-reseau.md](docs/phase-1-proxmox-reseau.md) |
| 2 | Windows Server / Active Directory : DC, OUs, groupes de sécurité | [docs/phase-2-windows-server-ad.md](docs/phase-2-windows-server-ad.md) |
| 3 | Infrastructure réseau : Pi-hole, DHCP | [docs/phase-3-pihole-dhcp.md](docs/phase-3-pihole-dhcp.md) |
| 4 | Site web d'inscription : PHP + MariaDB en architecture 2-tier, HTTPS via ADCS | [docs/phase-4-site-web-inscription.md](docs/phase-4-site-web-inscription.md) |
| 5 | Automatisation PowerShell : synchronisation AD, pré-stage des postes | [docs/phase-5-automatisation-powershell.md](docs/phase-5-automatisation-powershell.md) |
| 6 | Serveur de fichiers SMB + audit sécurité *(à venir)* | [docs/phase-6-fichiers-smb-audit.md](docs/phase-6-fichiers-smb-audit.md) |
| 7 | Hardening sécurité : comptes de service, NTLM, FGPP, Azure AD | [docs/phase-7-hardening-securite.md](docs/phase-7-hardening-securite.md) |
| 8 | Chatbot IT local : LXC Docker, Ollama, Open WebUI, HTTPS | [docs/phase-8-chatbot-it-local.md](docs/phase-8-chatbot-it-local.md) |
| - | Problèmes rencontrés & solutions (troubleshooting complet) | [docs/troubleshooting.md](docs/troubleshooting.md) |

## Structure du repo

```
.
├── README.md              : ce fichier
├── docs/                   : contenu détaillé de chaque phase
├── images/                 : toutes les captures, numérotées dans l'ordre du lab 
└── code/                   : scripts et configs complets, un dossier par phase
    ├── phase-4-site-web-inscription/
    ├── phase-5-automatisation-powershell/
    ├── phase-8-chatbot-it-local/
    └── troubleshooting/
```

Chaque fichier `/docs/*.md` contient le récit complet de la phase (captures inline + extraits de code). Les scripts et fichiers de configuration complets sont dans `/code/<phase>/`, référencés depuis la doc correspondante.
