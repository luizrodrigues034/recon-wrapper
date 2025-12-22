#!/bin/env  bash
[ "$EUID" -ne 0 ] && echo "Execute como root" && exit 1
set -euo pipefail



default_scan(){
        mkdir -p ./workspaces/"$1"/init_scan
	local target="$1"
	WORKDIR="./workspaces/$target"
	nmap -sS "$1" -oX "$WORKDIR/init_scan/default_scan.xml" >/dev/null && \
xmlstarlet sel -t -m "//port[state/@state='open']" -v "@portid" -o "=" -v "service/@name" -n "$WORKDIR/init_scan/default_scan.xml" > \
  "$WORKDIR/init_scan/open_ports.txt" 
	return 0
}

scan_by_service(){
	for line in  $(cat "$WORKDIR/init_scan/open_ports.txt")
        do
		local target="$1"
		local port=$(echo "$line" | cut -d"=" -f1)
       		local service_name=$(echo "$line" | cut -d"=" -f2)
		echo "Trabalhando com o host: $target na porta $port hospendando o servico $service_name"
		case "$service_name" in
			*ftp*)
				ftp_enum "$target" "$port" "$service_name"
				;;
			*ssh*)
				ssh_enum "$target" "$port" "$service_name"	
				;;
		esac
	done
        return 0
}

ftp_enum(){
	local target="$1"
	local port="$2"
	local service_name="$3"
	
	if [ -f modules/ftp.sh ]
	then
		echo "[*]Iniciando enumeração FTP"
		mkdir -p "$WORKDIR/$service_name/"
		./lib/network.sh "$target" "$port" "$service_name"
		./modules/ftp.sh "$target" "$port" "$service_name"

		echo "[*]Enumeração do FTP finalizada"
		return 0
	fi
}

ssh_enum(){
	echo Teste
	local target="$1"
        local port="$2"
        local service_name="$3"
	if [ -f modules/ssh.sh ]
	then
                echo "[*]Iniciando enumeração SSH"
                mkdir -p "$WORKDIR/$service_name/"
                ./lib/network.sh "$target" "$port" "$service_name"
		./modules/ssh.sh "$target" "$port" "$service_name"
		return 0
	fi
}

while [ "$#" -gt 0 ]
do
        case "$1" in
                --help | -h)
                        echo -e "Command Options: -h, --help, -H, --host"
                        shift
                        ;;
                --host | -H)
                        if [ -z "$2" ]; then
                                echo "Nao passou Ip"
                                exit 1
                        fi
			target_arg="$2" 
                        default_scan "$target_arg"
			scan_by_service "$target_arg"
			shift 2
                        ;;
                *)
                        echo "Opção $1 é invalida"
                        exit 1
                        ;;
        esac
done
