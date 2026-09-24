[← Retour au README](../README.md)

# **Phase 2 : Windows Server / Active Directory**

## Installation du DC et configuration du domaine

![Installation du DC et configuration du domaine](../images/005-installation-du-dc-et-configuration-du-domaine.png)

![Installation du DC et configuration du domaine](../images/006-installation-du-dc-et-configuration-du-domaine-2.png)

## Structure des OU

<aside>
🚨

udem.lan
├── Employés
│   ├── Administration
│   ├── Professeurs
│   │   ├── Prof_Informatique
│   │   ├── Prof_Santé
│   │   ├── Prof_Littérature
│   │   ├── Prof_Philosophie
│   │   └── Prof_Maths
│   └── Techniciens
└── Etudiants
 |         ├── Informatique
 |         ├── Santé
 |         ├── Littérature
 |         ├── Philosophie
 |         └── Maths
└── Ordinateur de l’école

</aside>

![Structure des OU](../images/007-structure-des-ou.png)

## Les groupes Globaux de Sécurité
Pour classer les utilisateurs plus tard et leurs assigner des permissions spécifiques selon leurs place dans l'hiérarchie

![Les groupes Globaux de Sécurité](../images/008-les-groupes-globaux-de-securite.png)
