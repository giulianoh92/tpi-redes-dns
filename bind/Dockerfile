FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y bind9 bind9-utils bind9-doc && \
    rm -rf /var/lib/apt/lists/*

# BIND leerá /etc/bind (lo montamos con los archivos de zona)
EXPOSE 53/udp 53/tcp

# Corre en primer plano con log en stdout
CMD ["named", "-g", "-f"]
