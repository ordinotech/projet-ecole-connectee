[← Retour au README](../README.md)

# **Phase 1 : Proxmox & Plan réseau**

Création des VLANs (Étudiants / Serveurs / Profs), vSwitchs, et plan des VMs/CTs à créer.

## Création des Vlans

<aside>
<img src="https://app.notion.com/icons/network_blue.svg" alt="https://app.notion.com/icons/network_blue.svg" width="40px" />

vmbr0 (WAN) ──► OPNsense ──► vmbr1 (trunk VLAN-aware)
                                                                       ├── VLAN 10 → Étudiants  (10.0.10.0/24)
                                                                       ├── VLAN 20 → Serveurs   (10.0.20.0/24)
                                                                       └── VLAN 30 → Profs      (10.0.30.0/24)

</aside>

![Création des Vlans](../images/001-creation-des-vlans.png)

![Création des Vlans](../images/002-creation-des-vlans-2.png)

![Création des Vlans](../images/003-creation-des-vlans-3.png)

## DHCP Settings

| VLAN | Range | DNS à distribuer | Gateway |
| --- | --- | --- | --- |
| OPT2 (Étudiants) | 10.0.10.100 → .200 | 10.0.20.2 (PiHole) | .1 |
| OPT3 (Serveurs) | 10.0.20.10 → .50 | 10.0.20.2 (PiHole) | .1 |
| OPT4 (Profs) | 10.0.30.100 → .150 | 10.0.20.2 (PiHole) | .1 |

## Plan des VMs et CTs

![Plan des VMs et CTs](../images/004-plan-des-vms-et-cts.png)
