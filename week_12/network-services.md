# Serveis de Xarxa Essencials: DNS, DHCP i NTP

## DNS (Domain Name System)

### Què és i quin problema resol?

DNS és el sistema que tradueix noms llegibles per humans (com `greendervcorp.com` o `backend.intern`) a adreces IP numèriques que els ordinadors entenen. Sense DNS, per accedir a qualsevol servei caldria memoritzar adreces com `192.168.1.45` en lloc de noms com `servidor-backend`.

En una organització com GreenDevCorp, DNS és fonamental per dues raons. Primera, els usuaris i sistemes utilitzen noms per accedir als serveis interns (`gitlab.intern`, `monitoring.intern`), cosa que facilita la gestió i evita errors. Segona, quan les IPs canvien (per exemple, en migrar un servidor), només cal actualitzar el DNS en un lloc; tots els sistemes que utilitzen el nom continuen funcionant sense cap canvi.

### Com funciona (a alt nivell)?

Quan un sistema vol connectar-se a `python-backend`, pregunta al servidor DNS: "quina IP té `python-backend`?". El servidor DNS consulta la seva base de dades i respon amb la IP corresponent. Aquest procés s'anomena *resolució de noms* i tarda mil·lisegons. Kubernetes utilitza el seu propi servidor DNS intern (CoreDNS) per resoldre els noms dels Services dins del clúster, per això `http://python-backend:8080` funciona entre pods.

---

## DHCP (Dynamic Host Configuration Protocol)

### Què és i quin problema resol?

DHCP és el protocol que assigna automàticament adreces IP i altres paràmetres de xarxa (gateway, DNS, màscara de subxarxa) als dispositius quan es connecten a la xarxa. Sense DHCP, un administrador hauria de configurar manualment la IP de cada ordinador, telèfon o impressora que s'uneixi a la xarxa.

En una empresa com GreenDevCorp, amb 20+ persones i múltiples dispositius cadascuna, la gestió manual d'IPs seria inviable. DHCP automatitza completament aquest procés: quan un nou empleat connecta el seu ordinador portàtil, rep automàticament una IP vàlida, la configuració del DNS i la ruta per sortir a Internet, tot en qüestió de segons. A més, les IPs s'alliberen quan els dispositius es desconnecten, evitant l'esgotament del rang d'adreces disponibles.

### Com funciona (a alt nivell)?

Quan un dispositiu es connecta a la xarxa, envia un missatge de difusió (*broadcast*) preguntant "hi ha algun servidor DHCP?". El servidor DHCP respon oferint una adreça IP del seu rang disponible. El dispositiu accepta l'oferta i el servidor registra l'assignació durant un temps determinat (*lease time*). Quan el lease expira, l'adreça torna a estar disponible per a altres dispositius.

---

## NTP (Network Time Protocol)

### Què és i quin problema resol?

NTP és el protocol que sincronitza els rellotges de tots els sistemes d'una xarxa amb una font de temps precisa. Pot semblar trivial, però la sincronització horària és crítica per a la seguretat i les operacions en qualsevol organització.

En termes de seguretat, molts protocols d'autenticació (com Kerberos, que utilitza Active Directory) rebutgen peticions si la diferència horària entre client i servidor supera 5 minuts. Si els rellotges estan desincronitzats, els usuaris no podran autenticar-se. En termes operacionals, quan es produeix un incident o un error, els administradors analitzen els logs de múltiples sistemes per reconstruir què va passar. Si cada servidor té un rellotge diferent, correlacionar els events és impossible: un log pot dir que l'error va passar a les 14:32 i un altre a les 14:28, quan en realitat van ser simultanis.

### Com funciona (a alt nivell)?

NTP utilitza una jerarquia de servidors anomenada *stratum*. Els servidors *stratum 0* són fonts de temps atòmiques o GPS d'alta precisió. Els servidors *stratum 1* es sincronitzen directament amb els *stratum 0*. En una organització, es configura un servidor NTP intern (*stratum 2*) que es sincronitza amb servidors públics fiables (com `pool.ntp.org`) i tots els sistemes interns s'hi sincronitzen. Això minimitza el nombre de connexions externes i garanteix consistència interna.
