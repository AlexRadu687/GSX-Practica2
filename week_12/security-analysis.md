# Anàlisi de Seguretat i Mitigació de Riscos

Aquest document analitza les possibles vulnerabilitats de la infraestructura de GreenDevCorp i les estratègies per mantenir els límits de seguretat definits en el disseny de xarxa i identitat.

## 1. Anàlisi de Riscos: Què pot anar malament?

Malgrat tenir una arquitectura segmentada, cap sistema és invulnerable. Aquests són els escenaris de risc principals:

| Risc Identificat | Descripció | Impacte |
| --- | --- | --- |
| **SPOF (Single Point of Failure)** | Si el servidor d'identitat (Keycloak/LDAP) o el Firewall central cauen, tota l'empresa queda inoperativa. | Crític |
| **Moviment Lateral** | Si un atacant compromet un pod en un entorn (ex. Dev), podria intentar saltar a un altre (ex. Prod) si les NetworkPolicies no són prou restrictives. | Alt |
| **Compromís de Credencials** | Un atac de *phishing* contra un empleat podria donar accés a un atacant a través del SSO. | Alt |
| **Misconfiguració Accidental** | Un error humà al modificar un manifest de Terraform o una NetworkPolicy podria obrir un port sensible a Internet. | Mig |

## 2. Estratègies de Mitigació

Per protegir les fronteres de seguretat de l'organització, s'implementen les següents mesures:

### A. Defensa en Profunditat (Layered Security)

No confiem només en el Firewall. La seguretat s'aplica en múltiples capes:

* **Xarxa:** Segmentació per VLANs i CIDR.
* **Clúster:** NetworkPolicies de Kubernetes (Default Deny).
* **Aplicació:** Autenticació obligatòria i xifrat TLS (HTTPS).

### B. Mitigació de fallades d'Identitat

* **Alta Disponibilitat (HA):** Desplegarem Keycloak i LDAP amb múltiples rèpliques distribuïdes en diferents nodes del clúster per evitar talls de servei.
* **MFA (Multi-Factor Authentication):** Per mitigar el robatori de contrasenyes, el MFA serà obligatori per a tots els usuaris, especialment per a aquells amb permisos d'administració o accés a producció.

### C. Control de canvis i "IaC Review"

Per evitar la **misconfiguració accidental**, seguim el flux de treball de GitOps:

* Tots els canvis a la xarxa o a les NetworkPolicies han de passar per un **Pull Request**.
* Abans d'aplicar-se a producció, els canvis es validen automàticament (`terraform validate`) i es proven a l'entorn de **Staging**.

## 3. Prevenció del Moviment Lateral

El moviment lateral és la tècnica on un atacant es mou per la xarxa interna després d'haver aconseguit un punt d'entrada inicial. Com ho evitem?

1. **Aïllament Estricte de Databases:** La subxarxa `10.0.4.0/24` només accepta tràfic de les IPs específiques dels servidors de producció. Cap terminal de treballador hi pot arribar directament.
2. **NetworkPolicies de Namespace:** Cada entorn (Dev, Staging, Prod) resideix en un Namespace de Kubernetes diferent, amb polítiques que bloquegen explícitament el tràfic entre ells.
3. **Mínim Privilegi:** Els usuaris només tenen rols d'autorització per als recursos que necessiten per a la seva feina diària (RBAC - Role-Based Access Control).

## 4. Conclusió

La seguretat de GreenDevCorp no es basa en un únic mur infranquejable, sinó en la combinació de **segmentació de xarxa**, **identitat centralitzada robusta** i **visibilitat operativa**. L'ús de polítiques declaratives (IaC) ens permet auditar en qualsevol moment l'estat de les nostres fronteres de seguretat i reaccionar ràpidament davant de qualsevol anomalia.