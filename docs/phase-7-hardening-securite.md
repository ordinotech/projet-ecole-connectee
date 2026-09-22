[← Retour au README](../README.md)

# **Phase 7 — Hardening Securité**

## Compte de service dédié pour exécution du script (principe du moindre privilège)

<aside>
⚙

### 1. Créer un **compte de service dédié**

Exemple :
`svc_AD_CreateUsers`

### 2. Lui donner **uniquement les permissions nécessaires**

Dans Active Directory :

- Déléguer à ce compte le droit de :
    - créer des comptes dans une OU spécifique
    - modifier les attributs nécessaires
    - réinitialiser les mots de passe si besoin

### 3. Autoriser ce compte à “Log on as a service”

Dans une GPO :

`Configuration ordinateur → Paramètres Windows → Paramètres de sécurité → Stratégies locales → Attribution des droits utilisateur`

Ajouter :
**Autoriser l’ouverture de session en tant que service** → `svc_AD_CreateUsers`

### 4. Refuser ce droit aux comptes admins

Comme recommandé dans la page Microsoft Learn.

</aside>

## Bloque l’authentification NTLM

[Bloquer l’authentification NTLM Windows - Training](https://learn.microsoft.com/fr-ca/training/modules/manage-security-active-directory/7-block-windows-ntlm-authentication)

## Fine‑Grained Password Policies (FGPP)

## AD Azure Cloud

<aside>
⚙

#### 1. **Créer un tenant Microsoft Entra ID → GRATUIT**

Obtenir un Entra ID Free automatiquement

#### 2. **Installer Entra Connect → GRATUIT**

Microsoft Entra Connect (anciennement Azure AD Connect) :

Permet la synchronisation AD local → Entra ID

✔ Fonctionnalités disponibles :

- Synchronisation AD → Entra
- Mots de passe synchronisés
- SSO Microsoft 365
- MFA de base
- Hybrid Join
- Seamless SSO
- Gestion cloud des comptes AD
- Scénarios hybrides complets
</aside>
