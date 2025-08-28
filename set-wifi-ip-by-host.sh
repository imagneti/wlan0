#!/bin/bash
# Skrypt ustawia statyczny adres IP dla Wi-Fi na podstawie nazwy hosta
# i restartuje WireGuard

# Interfejs Wi-Fi
IFACE="wlan0"

# Nazwa połączenia NetworkManager dla wlan0
CON_NAME="preconfigured"   # zmień jeśli u Ciebie inna

# Pobierz nazwę hosta
HOST=$(hostname)

# Wydobądź numer z końca hosta, np. belchatow2-m7 -> 7
NUM=$(echo "$HOST" | grep -oP '(?<=-m)\d+')

# Ustal IP wg reguły
if [ "$NUM" -ge 1 ] && [ "$NUM" -le 9 ]; then
    IPADDR="192.168.1.$((40+NUM))"
else
    IPADDR="192.168.1.50"
fi

# Brama i DNS
GATEWAY="192.168.1.1"
DNS="1.1.1.1 8.8.8.8"

echo "Host: $HOST"
echo "Numer: $NUM"
echo "Ustawiam statyczny adres: $IPADDR dla $CON_NAME"

# Ustaw statyczny IP przez nmcli
sudo nmcli connection modify "$CON_NAME" ipv4.addresses "$IPADDR/24" \
    ipv4.gateway "$GATEWAY" ipv4.dns "$DNS" ipv4.method manual

# Restart połączenia Wi-Fi
sudo nmcli connection down "$CON_NAME"
sudo nmcli connection up "$CON_NAME"

# Restart WireGuard
if nmcli connection show --active | grep -q wg0; then
    echo "Wyłączam WireGuard..."
    sudo wg-quick down wg0
fi

echo "Uruchamiam WireGuard..."
sudo wg-quick up wg0

echo "Gotowe! $IFACE ma teraz statyczny adres: $IPADDR"
