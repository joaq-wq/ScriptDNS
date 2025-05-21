#!/bin/bash

clear
echo "====================================="
echo "  Bem-vindo ao Configurador de DNS!"
echo "====================================="
echo ""
echo "Escolha o sistema operacional:"
echo "1 - Ubuntu"
echo "2 - openSUSE"
echo "3 - CentOS"
echo ""

read -p "Digite sua opção (1, 2 ou 3): " opcao

case $opcao in
    1)
        echo "Você escolheu configurar DNS no Ubuntu."

        SENHA="123"

        echo "Detectando interface de rede..."
        INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
        echo "Interface detectada: $INTERFACE"

        echo "Atualizando pacotes..."
        echo $SENHA | sudo -S apt update
        echo $SENHA | sudo -S apt upgrade -y

        echo "Instalando BIND9..."
        echo $SENHA | sudo -S apt install bind9 bind9utils bind9-doc -y

        echo "Configurando IP fixo 192.168.0.1/24 na interface $INTERFACE..."
        echo $SENHA | sudo -S ip addr flush dev $INTERFACE
        echo $SENHA | sudo -S ip addr add 192.168.0.1/24 dev $INTERFACE
        echo $SENHA | sudo -S ip link set $INTERFACE up

        echo "Configurando zonas no named.conf.local..."
        echo $SENHA | sudo -S tee /etc/bind/named.conf.local > /dev/null <<EOF
// Zona Direta
zone "grau.local" {
    type master;
    file "/etc/bind/db.grau.local";
};

// Zona Reversa
zone "192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192";
};
EOF

        echo "Criando arquivo db.grau.local..."
        echo $SENHA | sudo -S tee /etc/bind/db.grau.local > /dev/null <<EOF
\$TTL    604800
@       IN      SOA     grau.local. root.grau.local. (
                              2         ; Serial
                              604800    ; Refresh
                              86400     ; Retry
                              2419200   ; Expire
                              604800 )  ; Negative Cache TTL

@       IN      NS      grau.local.
@       IN      A       192.168.0.1
www     IN      A       192.168.0.1
ftp     IN      A       192.168.0.1
EOF

        echo "Criando arquivo db.192..."
        echo $SENHA | sudo -S tee /etc/bind/db.192 > /dev/null <<EOF
\$TTL    604800
@       IN      SOA     grau.local. root.grau.local. (
                              2         ; Serial
                              604800    ; Refresh
                              86400     ; Retry
                              2419200   ; Expire
                              604800 )  ; Negative Cache TTL

@       IN      NS      grau.local.
1       IN      PTR     grau.local.
1       IN      PTR     www.grau.local.
1       IN      PTR     ftp.grau.local.
EOF

        echo "Reiniciando o serviço BIND9..."
        echo $SENHA | sudo -S systemctl restart bind9

        echo "Substituindo o arquivo resolv.conf..."
        echo $SENHA | sudo -S mv /etc/resolv.conf /etc/resolv.conf.bkp
        echo $SENHA | sudo -S tee /etc/resolv.conf > /dev/null <<EOF
nameserver 192.168.0.1
www.grau.local 192.168.0.1
ftp.grau.local 192.168.0.1
EOF

        echo "Configuração concluída com sucesso!"
        ;;

    2)
        echo "Você escolheu configurar DNS no openSUSE."

        SENHA="123"

        echo "Detectando interface de rede..."
        INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
        echo "Interface detectada: $INTERFACE"

        echo "Atualizando pacotes..."
        echo $SENHA | sudo -S zypper refresh
        echo $SENHA | sudo -S zypper update --no-confirm

        echo "Instalando BIND..."
        echo $SENHA | sudo -S zypper install --no-confirm bind

        echo "Configurando IP fixo 192.168.0.1/24 na interface $INTERFACE..."
        echo $SENHA | sudo -S ip addr flush dev $INTERFACE
        echo $SENHA | sudo -S ip addr add 192.168.0.1/24 dev $INTERFACE
        echo $SENHA | sudo -S ip link set $INTERFACE up

        echo "Criando backup do named.conf..."
        echo $SENHA | sudo -S cp /etc/named.conf /etc/named.conf.bkp

        echo "Configurando named.conf com options e zonas..."
        echo $SENHA | sudo -S tee /etc/named.conf > /dev/null <<EOF
options {
    directory "/var/lib/named";
    forwarders { };
    allow-query { any; };
    recursion yes;
    listen-on { any; };
    allow-transfer { none; };
};

zone "grau.local" IN {
    type master;
    file "grau.local.conf";
};

zone "192.in-addr.arpa" IN {
    type master;
    file "db.192";
};

include "/etc/named.d/forwarders.conf";
EOF

        echo "Criando arquivo grau.local.conf..."
        echo $SENHA | sudo -S tee /var/lib/named/grau.local.conf > /dev/null <<EOF
\$TTL 604800
@       IN      SOA     grau.local. root.grau.local. (
                              2         ; Serial
                              604800    ; Refresh
                              86400     ; Retry
                              2419200   ; Expire
                              604800 )  ; Negative Cache TTL

@       IN      NS      grau.local.
@       IN      A       192.168.0.1
www     IN      A       192.168.0.1
ftp     IN      A       192.168.0.1
EOF

        echo "Criando arquivo db.192..."
        echo $SENHA | sudo -S tee /var/lib/named/db.192 > /dev/null <<EOF
\$TTL 604800
@       IN      SOA     grau.local. root.grau.local. (
                              2         ; Serial
                              604800    ; Refresh
                              86400     ; Retry
                              2419200   ; Expire
                              604800 )  ; Negative Cache TTL

@       IN      NS      grau.local.
1       IN      PTR     grau.local.
1       IN      PTR     www.grau.local.
1       IN      PTR     ftp.grau.local.
EOF

        echo "Habilitando e reiniciando o serviço named..."
        echo $SENHA | sudo -S systemctl enable named
        echo $SENHA | sudo -S systemctl restart named

        echo "Substituindo o arquivo resolv.conf..."
        echo $SENHA | sudo -S mv /etc/resolv.conf /etc/resolv.conf.bkp
        echo $SENHA | sudo -S tee /etc/resolv.conf > /dev/null <<EOF
nameserver 192.168.0.1
www.grau.local 192.168.0.1
ftp.grau.local 192.168.0.1
EOF

        echo "Configuração concluída com sucesso!"
        ;;

    3)
        echo "Você escolheu configurar DNS no CentOS."

        SENHA="123"

        echo "Detectando interface de rede..."
        INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
        echo "Interface detectada: $INTERFACE"

        echo "Atualizando pacotes..."
        echo $SENHA | sudo -S yum update -y

        echo "Instalando BIND..."
        echo $SENHA | sudo -S yum install -y bind bind-utils

        echo "Configurando IP fixo 192.168.0.1/24 na interface $INTERFACE..."
        echo $SENHA | sudo -S ip addr flush dev $INTERFACE
        echo $SENHA | sudo -S ip addr add 192.168.0.1/24 dev $INTERFACE
        echo $SENHA | sudo -S ip link set $INTERFACE up

        echo "Criando backup do named.conf..."
        echo $SENHA | sudo -S cp /etc/named.conf /etc/named.conf.bkp

        echo "Configurando named.conf com options e zonas..."
        echo $SENHA | sudo -S tee /etc/named.conf > /dev/null <<EOF
options {
    directory "/var/named";
    forwarders { };
    allow-query { any; };
    recursion yes;
    listen-on port 53 { any; };
    allow-transfer { none; };
};

zone "grau.local" IN {
    type master;
    file "grau.local.conf";
};

zone "192.in-addr.arpa" IN {
    type master;
    file "db.192";
};
EOF

        echo "Criando arquivo grau.local.conf..."
        echo $SENHA | sudo -S tee /var/named/grau.local.conf > /dev/null <<EOF
\$TTL 604800
@       IN      SOA     grau.local. root.grau.local. (
                              2         ; Serial
                              604800    ; Refresh
                              86400     ; Retry
                              2419200   ; Expire
                              604800 )  ; Negative Cache TTL

@       IN      NS      grau.local.
@       IN      A       192.168.0.1
www     IN      A       192.168.0.1
ftp     IN      A       192.168.0.1
EOF

        echo "Criando arquivo db.192..."
        echo $SENHA | sudo -S tee /var/named/db.192 > /dev/null <<EOF
\$TTL 604800
@       IN      SOA     grau.local. root.grau.local. (
                              2         ; Serial
                              604800    ; Refresh
                              86400     ; Retry
                              2419200   ; Expire
                              604800 )  ; Negative Cache TTL

@       IN      NS      grau.local.
1       IN      PTR     grau.local.
1       IN      PTR     www.grau.local.
1       IN      PTR     ftp.grau.local.
EOF

        echo "Habilitando e reiniciando o serviço named..."
        echo $SENHA | sudo -S systemctl enable named
        echo $SENHA | sudo -S systemctl restart named

        echo "Substituindo o arquivo resolv.conf..."
        echo $SENHA | sudo -S mv /etc/resolv.conf /etc/resolv.conf.bkp
        echo $SENHA | sudo -S tee /etc/resolv.conf > /dev/null <<EOF
nameserver 192.168.0.1
www.grau.local 192.168.0.1
ftp.grau.local 192.168.0.1
EOF

        echo "Configuração concluída com sucesso!"
        ;;
        
    *)
        echo "Opção inválida. Saindo..."
        exit 1
        ;;
esac
