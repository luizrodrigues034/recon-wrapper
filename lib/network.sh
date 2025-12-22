#!/bin/env bash
WORKDIR=workspaces/"$1"/"$3"

banner_grabling(){
	local target="$1"
	local port="$2"
	local service_name_arg="$3"
        echo "[*] Coletando banner"
        local banner=$(timeout 5 nc -vn "$target" "$port" 2>/dev/null || \
        echo "QUIT" | timeout 10 openssl s_client -connect "$target:$port" -starttls ftp -quiet 2>/dev/null)
        echo "[*] Termino da Coleta"
        if [ -z "$banner" ]
        then
                echo "[*] Nao houve Resposta"
                return 1
        else
                echo "[*] Banner encontrado"
                echo "[*] Salvando Banner"
                echo "$WORKDIR/banner.txt"
		echo "$banner" > "$WORKDIR/banner.txt"
                return 0
        fi
}
run_nmap(){
        local target="$1"
        local port="$2"
        local service_name="$3"

        nmap -sV -p "$port" -sC -A "$target" -oX "$WORKDIR/nmap_$service_name.xml"> /dev/null

}

target_arg=$1
port_arg=$2
service_name_arg=$3

banner_grabling "$target_arg" "$port_arg" "$service_name_arg" &
run_nmap "$target_arg" "$port_arg" "$service_name_arg" &
wait
