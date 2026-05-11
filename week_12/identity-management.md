# Gestió d'Identitat: Autenticació, Autorització i Identitat Centralitzada

## Autenticació vs. Autorització

### Autenticació

L'autenticació és el procés de verificar que un usuari és qui diu ser. És la resposta a la pregunta: *"qui ets?"*. Els mecanismes d'autenticació més comuns són la combinació de nom d'usuari i contrasenya, però també inclouen factors addicionals com codis temporals (2FA), certificats digitals o dades biomètriques.

En una organització, l'autenticació és la primera línia de defensa: sense saber qui és l'usuari, no és possible prendre cap decisió sobre el que pot fer. Un sistema d'autenticació robust garanteix que només persones amb credencials vàlides poden accedir als recursos de l'empresa.

### Autorització

L'autorització és el procés de determinar què pot fer un usuari autenticat. És la resposta a la pregunta: *"què pots fer?"*. Un cop sabem qui és l'usuari (autenticació), el sistema comprova quins permisos té i permet o denega cada acció concreta.

Per exemple, a GreenDevCorp un developer autenticat pot accedir al repositori de codi i desplegar a l'entorn de development, però no pot accedir a les bases de dades de producció ni modificar la configuració del firewall. Aquesta distinció entre autenticació i autorització és fonamental: autenticar correctament un usuari no implica que pugui fer qualsevol cosa.

---

## Identitat Centralitzada

### Quin problema resol?

Sense identitat centralitzada, cada aplicació gestiona els seus propis usuaris i contrasenyes. Això genera múltiples problemes: els empleats han de recordar contrasenyes diferents per a cada servei, quan algú abandona l'empresa cal desactivar el seu compte en cada sistema manualment (amb risc d'oblidar-ne algun), i no hi ha una visió global de qui té accés a què.

La identitat centralitzada resol aquests problemes amb un directori únic d'usuaris. Quan un empleat s'uneix a l'empresa, es crea un compte en un sol lloc i automàticament té accés a tots els serveis configurats. Quan marxa, es desactiva un únic compte i perd l'accés a tot instantàniament.

### LDAP (Lightweight Directory Access Protocol)

LDAP és un protocol estàndard per accedir i gestionar directoris d'informació, principalment usuaris i grups. Un directori LDAP organitza la informació de forma jeràrquica, similar a un arbre: l'organització al nivell superior, departaments com a branques, i usuaris com a fulles.

Les aplicacions poden consultar el directori LDAP per verificar credencials d'usuari i obtenir informació sobre grups i permisos. LDAP és obert i compatible amb pràcticament qualsevol sistema operatiu i aplicació, cosa que el converteix en l'estàndard de facto per a la gestió d'identitat en entorns heterogenis.

### Active Directory (AD)

Active Directory és la implementació de Microsoft d'un servei de directori basat en LDAP, però amb funcionalitats addicionals. Inclou gestió de polítiques de grup (GPO), autenticació Kerberos, DNS integrat i eines gràfiques d'administració. És l'estàndard en entorns corporatius basats en Windows.

La seva principal avantatge respecte a un servidor LDAP genèric és la integració nativa amb tots els productes Microsoft (Windows, Office 365, Azure) i la facilitat d'administració. El seu principal inconvenient és que requereix llicències i està orientat a entorns Windows, cosa que pot ser una limitació en empreses amb infraestructura mixta o basada en Linux.

### SSO (Single Sign-On)

SSO és un mecanisme d'autenticació que permet als usuaris accedir a múltiples aplicacions amb una sola autenticació. L'usuari s'autentica una vegada (per exemple, en obrir l'ordinador o accedir al portal de l'empresa) i pot accedir a totes les aplicacions configurades sense tornar a introduir credencials.

El SSO millora significativament l'experiència d'usuari i la seguretat. Millora la seguretat perquè els usuaris tendeixen a usar contrasenyes més fortes quan n'han de recordar menys, i perquè centralitza els controls d'accés. Els protocols més comuns per implementar SSO són SAML 2.0 i OpenID Connect (OIDC).

---

## Recomanació d'Identitat per a GreenDevCorp

### Situació actual

GreenDevCorp té 20+ persones distribuïdes en múltiples equips (developers, data analysts, operations) i dues oficines (Barcelona i Londres). La infraestructura és basada en Linux i contenidors, sense dependència de productes Microsoft.

### Recomanació: Keycloak + LDAP

Per a GreenDevCorp, recomanem implementar **Keycloak** com a servidor d'identitat centralitzada amb un directori **OpenLDAP** com a backend d'usuaris.

**Keycloak** és una solució open-source de gestió d'identitat que ofereix SSO, autenticació multifactor (MFA), i suport per als protocols estàndard OIDC i SAML 2.0. Permet que totes les aplicacions internes (GitLab, Grafana, aplicacions pròpies) s'autentiquin contra un únic punt sense necessitat de gestionar usuaris en cada sistema.

**OpenLDAP** actua com a directori d'usuaris i grups. Keycloak el consulta per verificar credencials i obtenir informació de grups, que es mapegen a rols i permisos dins de cada aplicació.

### Per què no Active Directory?

Active Directory seria una opció vàlida si GreenDevCorp fos una empresa basada en Windows. Però donat que la infraestructura és Linux i basada en contenidors, AD afegiria complexitat i costos de llicència innecessaris. Keycloak ofereix les mateixes funcionalitats de SSO i MFA sense dependència de Microsoft.

### Per què no un sistema d'usuaris per aplicació?

Amb 20+ persones i creixement previst, gestionar usuaris en cada aplicació per separat és insostenible. Quan algú marxa, caldria revocar l'accés manualment en cada sistema, amb risc d'oblidar-ne algun. Un sistema centralitzat garanteix que la revocació és immediata i completa.

### Avantatges i inconvenients de la proposta

**Avantatges:**
* Open-source i sense costos de llicència
* Compatible amb Linux i infraestructura de contenidors
* SSO per a totes les aplicacions internes
* Suport per a MFA (seguretat addicional)
* Estàndards oberts (OIDC, SAML) compatibles amb qualsevol aplicació

**Inconvenients:**
* Requereix temps d'implantació i configuració inicial
* Afegeix dos components nous a mantenir (Keycloak + OpenLDAP)
* L'equip d'operacions ha d'aprendre a administrar-lo

### Conclusió

Per a una empresa de 20+ persones en creixement com GreenDevCorp, la identitat centralitzada amb Keycloak i OpenLDAP és una inversió que s'amortitza ràpidament. El cost de configurar-la és molt inferior al cost de gestionar un incident de seguretat per credencials no revocades o contrasenyes febles en sistemes distribuïts.
