#!/bin/bash

clear
echo "====================================="
echo "  Bem-vindo ao Configurador de DNS!"
echo "====================================="
echo ""
echo "Escolha o sistema operacional:"
echo "1 - Ubuntu"
echo "2 - openSUSE"
echo ""

read -p "Digite sua opção (1 ou 2): " opcao

case $opcao in
    1)
        echo "Você escolheu configurar DNS no Ubuntu."
        
        # Senha (somente para fins didáticos!)
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

        echo "Copiando arquivos de zona padrão..."
        echo $SENHA | sudo -S cp /etc/bind/db.local /etc/bind/db.grau.local
        echo $SENHA | sudo -S cp /etc/bind/db.127 /etc/bind/db.192

        echo "Editando arquivo db.grau.local..."
        echo $SENHA | sudo -S tee /etc/bind/db.grau.local > /dev/null <<EOF
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     grau.local. root.grau.local. (
                              2         ; Serial
                              604800    ; Refresh
                              86400     ; Retry
                              2419200   ; Expire
                              604800 )  ; Negative Cache TTL

;
@       IN      NS      grau.local.
@       IN      A       192.168.0.1
www     IN      A       192.168.0.1
ftp     IN      A       192.168.0.1
EOF

        echo "Editando arquivo db.192..."
        echo $SENHA | sudo -S tee /etc/bind/db.192 > /dev/null <<EOF
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     grau.local. root.grau.local. (
                              2         ; Serial
                              604800    ; Refresh
                              86400     ; Retry
                              2419200   ; Expire
                              604800 )  ; Negative Cache TTL

;
@       IN      NS      grau.local.
@       IN      A       192.168.0.1
www     IN      A       192.168.0.1
ftp     IN      A       192.168.0.1
EOF

        echo "Reiniciando o serviço BIND9..."
        echo $SENHA | sudo -S systemctl restart bind9

        echo "Substituindo o arquivo resolv.conf..."
        echo $SENHA | sudo -S mv /etc/resolv.conf /etc/resolv.conf.bkp
        echo $SENHA | sudo -S touch /etc/resolv.conf
        echo $SENHA | sudo -S tee /etc/resolv.conf > /dev/null <<EOF
nameserver 192.168.0.1
www.grau.local 192.168.0.1
ftp.grau.local 192.168.0.1
EOF

        echo "Configuração concluída com sucesso!"
        ;;
    2)
        echo "Você escolheu configurar DNS no openSUSE."
        
        # Senha (somente para fins didáticos!)
        SENHA="123"

        echo "Detectando interface de rede..."
        INTERFACE=$(ip -o -4 route show to default | awk '{print $5}')
        echo "Interface detectada: $INTERFACE"

        echo "Atualizando pacotes..."
        echo $SENHA | sudo -S zypper refresh
        echo $SENHA | sudo -S zypper update -y

        echo "Instalando BIND9..."
        echo $SENHA | sudo -S zypper install bind -y

        echo "Configurando IP fixo 192.168.0.1/24 na interface $INTERFACE..."
        echo $SENHA | sudo -S ip addr flush dev $INTERFACE
        echo $SENHA | sudo -S ip addr add 192.168.0.1/24 dev $INTERFACE
        echo $SENHA | sudo -S ip link set $INTERFACE up

        echo "Configurando zonas no named.conf..."
        echo $SENHA | sudo -S tee /etc/named/named.conf > /dev/null <<EOF
// Zona Direta
zone "grau.local" {
    type master;
    file "/var/lib/named/db.grau.local";
};

// Zona Reversa
zone "192.in-addr.arpa" {
    type master;
    file "/var/lib/named/db.192";
};
EOF

        echo "Copiando arquivos de zona padrão..."
        echo $SENHA | sudo -S cp /var/lib/named/etc/named.local /var/lib/named/db.grau.local
        echo $SENHA | sudo -S cp /var/lib/named/etc/named.127 /var/lib/named/db.192

        echo "Editando arquivo db.grau.local..."
        echo $SENHA | sudo -S tee /var/lib/named/db.grau.local > /dev/null <<EOF
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     grau.local. root.grau.local. (
                              2         ; Serial
                              604800    ; Refresh
                              86400     ; Retry
                              2419200   ; Expire
                              604800 )  ; Negative Cache TTL

;
@       IN      NS      grau.local.
@       IN      A       192.168.0.1
www     IN      A       192.168.0.1
ftp     IN      A       192.168.0.1
EOF

        echo "Editando arquivo db.192..."
        echo $SENHA | sudo -S tee /var/lib/named/db.192 > /dev/null <<EOF
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     grau.local. root.grau.local. (
                              2         ; Serial
                              604800    ; Refresh
                              86400     ; Retry
                              2419200   ; Expire
                              604800 )  ; Negative Cache TTL

;
@       IN      NS      grau.local.
@       IN      A       192.168.0.1
www     IN      A       192.168.0.1
ftp     IN      A       192.168.0.1
EOF

        echo "Reiniciando o serviço BIND9..."
        echo $SENHA | sudo -S systemctl restart named

        echo "Substituindo o arquivo resolv.conf..."
        echo $SENHA | sudo -S mv /etc/resolv.conf /etc/resolv.conf.bkp
        echo $SENHA | sudo -S touch /etc/resolv.conf
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
