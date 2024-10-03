# dhcp_remove_bad_address

Script de suppression automatique des BAD_ADDRESS DHCP

### 1. Sélection des adresses IP cible
### 2. Itération sur chaque adresse
* Test ping
* Maintien ou suppression de l'IP BAD_ADDRESS
* Composition log avec IP, itération sur nombre total, action réalisée
### 3. Calcul temps de traitement et ajout au log 
### 4. Epuration fichiers logs avec rétention 1 mois pour optimisation de l'espace
