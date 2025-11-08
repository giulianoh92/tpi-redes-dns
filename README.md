# 🧩 TPI – Taller de Redes Locales  
## Paso 3 – Implementación y prueba del servidor DNS BIND9

### 👥 Integrantes
- **Giuliano Hillebrand**  
- **González Martín Gastón**  
- **Prado Valentina**

### 🏫 Carrera
Ingeniería en Informática — Cátedra: **Taller de Redes Locales**  
Año lectivo: **2025**
Univeridad Gastón Dachary (UGD)

### 📘 Objetivo
Implementar un **servidor de nombres (DNS)** para el dominio interno  
**`misiotic.com`**, configurando:
- Zonas **directa e inversa** de la organización.
- Registros A, CNAME, MX y PTR para los servicios principales (web, correo, archivos, proxy, DNS y firewall).
- **Resolución recursiva limitada** a la red interna `10.1.0.0/16`.
- **Forwarders públicos** a `8.8.8.8` y `1.1.1.1`.

La implementación se realizó mediante un entorno reproducible en **Docker Compose**, que emula la **DMZ del diseño físico** del TPI.

---

## 🏗️ Estructura del proyecto

```

tpi-dns/
├─ docker-compose.yml
├─ README.md
├─ bind/
│  ├─ Dockerfile
│  ├─ named.conf
│  ├─ named.conf.options
│  ├─ named.conf.local
│  ├─ db.misiotic.com          # Zona directa
│  └─ db.10.1.80               # Zona inversa
└─ alpine-host/
└─ Dockerfile

````

---

## ⚙️ Servicios desplegados

| Servicio | Imagen base | Rol | IP DMZ | Hostname / FQDN |
|-----------|-------------|------|--------|-----------------|
| **dns** | ubuntu:22.04 + bind9 | Servidor DNS BIND9 master | 10.1.80.6 | dns.misiotic.com |
| **www** | alpine:3.20 | Simulación servidor web | 10.1.80.2 | www.misiotic.com |
| **proxy** | alpine:3.20 | Simulación proxy/firewall | 10.1.80.3 | proxy.misiotic.com |
| **mail** | alpine:3.20 | Simulación correo | 10.1.80.4 | mail.misiotic.com |
| **file** | alpine:3.20 | Simulación archivos/ftp | 10.1.80.5 | file.misiotic.com |
| **tester** | alpine:3.20 | Cliente de pruebas | 10.1.80.20 | tester.misiotic.com |

Todos los contenedores comparten la red `dmz (10.1.80.0/27)`  
y utilizan al DNS (10.1.80.6) como servidor de nombres.

---

## 🚀 Ejecución

### 1️⃣ Levantar el entorno

```bash
docker compose up -d --build
````

El contenedor `dns` expone el puerto **5353** del host → 53/tcp/udp del servicio
(para evitar conflicto con `systemd-resolved`).

### 2️⃣ Ver estado

```bash
docker compose ps
docker compose logs dns --tail=20
```

El log debe mostrar:

```
zone misiotic.com/IN: loaded serial ...
zone 80.1.10.in-addr.arpa/IN: loaded serial ...
running
```

---

## 🔍 Pruebas de funcionamiento

### Dentro del contenedor *tester*:

```bash
docker compose exec tester sh
```

#### a) Resolución directa (autoritativa)

```bash
dig +short @10.1.80.6 www.misiotic.com
dig +short @10.1.80.6 mail.misiotic.com
dig +short @10.1.80.6 file.misiotic.com
dig +short @10.1.80.6 proxy.misiotic.com
dig +short @10.1.80.6 dns.misiotic.com
```

#### b) Resolución inversa

```bash
dig +short @10.1.80.6 -x 10.1.80.2
dig +short @10.1.80.6 -x 10.1.80.6
```

#### c) Recursión (vía forwarders)

```bash
dig +short @10.1.80.6 www.google.com
```

#### d) Control de políticas

```bash
dig +norecurse +short @10.1.80.6 www.cloudflare.com   # vacía, no recursiva
```

#### e) Desde el host (puerto 5353)

```bash
dig @127.0.0.1 -p 5353 www.misiotic.com
```

---

## 📄 Archivos de zona

### `/etc/bind/db.misiotic.com` (zona directa)

Define los registros **A**, **CNAME**, **MX** y el **NS** principal.

### `/etc/bind/db.10.1.80` (zona inversa)

Asocia direcciones IP ↔ nombres FQDN con registros **PTR**.

---

## 🔒 Políticas y seguridad

* **allow-query { 10.1.0.0/16; localhost; };**
  Limita el acceso recursivo a la red interna.
* **dnssec-validation auto;**
  Valida respuestas de forwarders.
* **listen-on-v6 { none; };**
  Deshabilita IPv6 en contenedor sin soporte.

---

## ✅ Resultados

* **Resolución interna**: correcta para todos los registros del dominio `misiotic.com`.
* **Resolución inversa**: PTRs devuelven los nombres definidos.
* **Recursión externa**: operativa mediante forwarders (8.8.8.8 / 1.1.1.1).
* **Política de seguridad**: consultas permitidas solo desde la red 10.1.0.0/16.
* **Coherencia de IPs**: las direcciones corresponden a la DMZ (10.1.80.0/27) del diseño físico del TPI.

---

## 🧾 Comandos de validación adicionales

```bash
docker compose exec dns named-checkconf /etc/bind/named.conf
docker compose exec dns named-checkzone misiotic.com /etc/bind/db.misiotic.com
docker compose exec dns named-checkzone 80.1.10.in-addr.arpa /etc/bind/db.10.1.80
```

---

## 🧠 Notas técnicas

* Este entorno emula solo el **Paso 3 (DNS)** del TPI; no incluye NAT ni firewall.
* Los contenedores **Alpine** funcionan como hosts DMZ para validar A/PTR.
* El uso del puerto **5353** evita conflictos con `systemd-resolved` del host.
* Puede adaptarse fácilmente para incluir un **esclavo DNS** (`type slave`) replicando la zona.

---

## 🧩 Conclusión

El entorno Docker reproduce con precisión el comportamiento del **servidor DNS BIND9** planificado para la DMZ de *MisioTIC S.A.*
Permite evidenciar la configuración funcional de:

* zonas directa e inversa,
* recursión controlada, y
* resolución hacia forwarders externos.

Este proyecto constituye la **evidencia práctica completa** del cumplimiento del **Paso 3 del TPI de Redes**.