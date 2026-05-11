# Disseny de Xarxa i Identitat

## 1. Arquitectura de Xarxa

### Diagrama

```
                        INTERNET
                            │
                    ┌───────┴───────┐
                    │   FIREWALL    │
                    └───────┬───────┘
                            │
              ┌─────────────┴─────────────┐
              │          DMZ              │
              │      10.0.0.0/24          │
              │  (Serveis públics:        │
              │   web, VPN gateway)       │
              └─────────────┬─────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────┴───────┐   ┌───────┴───────┐   ┌───────┴───────┐
│  DEVELOPMENT  │   │    STAGING    │   │  PRODUCTION   │
│ 10.0.1.0/24   │   │ 10.0.2.0/24   │   │ 10.0.3.0/24   │
│               │   │               │   │               │
│ Developers    │   │ QA / Testing  │   │ Serveis       │
│ Data Analysts │   │               │   │ en viu        │
└───────────────┘   └───────────────┘   └───────┬───────┘
                                                │
                                        ┌───────┴───────┐
                                        │   DATABASE    │
                                        │ 10.0.4.0/24   │
                                        │               │
                                        │ BD producció  │
                                        │ (aïllada)     │
                                        └───────────────┘

        ┌───────────────────┐       ┌───────────────────┐
        │  PARTNERS/EXTENS  │       │    OPERATIONS     │
        │  10.0.10.0/24     │       │  10.0.5.0/24      │
        │                   │       │                   │
        │ Accés limitat     │       │ Monitoratge       │
        │ a serveis concrets│       │ CI/CD             │
        └───────────────────┘       └───────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    VPN TUNNEL                           │
│         Oficina Barcelona ◄──────► Oficina Londres      │
│              10.0.1.0/24                10.0.6.0/24     │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Pla d'Adreces IP (CIDR)

### Xarxa Principal
| Xarxa | CIDR | IPs disponibles | Ús |
|-------|------|-----------------|-----|
| Organització sencera | 10.0.0.0/16 | 65.534 | Rang global |
| DMZ | 10.0.0.0/24 | 254 | Serveis públics, VPN gateway |
| Development | 10.0.1.0/24 | 254 | Developers i Data Analysts |
| Staging | 10.0.2.0/24 | 254 | Entorn de proves |
| Production | 10.0.3.0/24 | 254 | Serveis en producció |
| Database | 10.0.4.0/24 | 254 | Bases de dades (aïllades) |
| Operations | 10.0.5.0/24 | 254 | Monitoratge i CI/CD |
| Londres (oficina) | 10.0.6.0/24 | 254 | Xarxa oficina Londres |
| Partners externs | 10.0.10.0/24 | 254 | Accés limitat a partners |

### Justificació del Disseny

**Per què 10.0.0.0/16 com a rang principal?**
Utilitzem el rang privat `10.0.0.0/16` perquè ofereix 65.534 adreces IP, suficients per créixer de 20 a centenars de persones sense redissenyar la xarxa. És un rang privat estàndard (RFC 1918) que no entra en conflicte amb adreces públiques d'Internet.

**Per què /24 per a cada subxarxa?**
Cada subxarxa `/24` ofereix 254 adreces IP usables. Per a GreenDevCorp amb 20+ persones i creixement previst, és més que suficient per a cada entorn. A més, `/24` és fàcil de gestionar i memoritzar, i facilita la configuració de firewalls i polítiques de xarxa.

**Per què separar Development, Staging i Production?**
El principi de segmentació de xarxa estableix que entorns amb nivells de risc diferent han d'estar aïllats. Un error en Development no ha de poder afectar Production. A més, compleix requisits de compliment normatiu (com PCI-DSS o ISO 27001) que exigeixen separació d'entorns.

**Per què una subxarxa de Database aïllada?**
Les bases de dades contenen les dades més sensibles de l'organització. Aïllar-les en una subxarxa pròpia (`10.0.4.0/24`) permet aplicar polítiques de firewall molt restrictives: només els servidors d'aplicació de Production poden accedir-hi, res més.

**Per què una subxarxa per a Partners externs?**
Els partners i contractistes externs necessiten accés limitat a alguns serveis, però no a tota la xarxa interna. Assignar-los una subxarxa pròpia (`10.0.10.0/24`) permet controlar exactament a quins recursos poden accedir i auditar el seu tràfic de forma independent.

---

## 3. Fronteres de Seguretat

### Tràfic permès
| Origen | Destí | Port | Motiu |
|--------|-------|------|-------|
| Development | Staging | 443, 80 | Desplegament i proves |
| Staging | Production | — | Prohibit (manual only) |
| Production | Database | 5432, 3306 | Consultes BD |
| Operations | Tots | 22, 9090 | Administració i monitoratge |
| Partners | DMZ | 443 | Accés a API pública |
| Internet | DMZ | 443, 80 | Tràfic web públic |

### Tràfic bloquejat
| Origen | Destí | Motiu |
|--------|-------|-------|
| Development | Production | Evitar accidents en producció |
| Development | Database | Les BD de producció no són accessibles des de dev |
| Partners | Xarxa interna | Partners només veuen el que cal |
| Internet | Xarxa interna | Cap accés directe a recursos interns |

**Principi de "deny all by default"**: Tota comunicació està bloquejada per defecte. Només s'obre el tràfic explícitament necessari. Això minimitza la superfície d'atac: si un servei és compromès, l'atacant no pot moure's lliurement per la xarxa.
