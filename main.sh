#!/bin/env  bash
[ "$EUID" -ne 0 ] && echo "Execute como root" && exit 1
set -euo pipefail



default_scan(){

        mkdir -p ./workspaces/$1/init_scan

	workdir="./workspaces/$1"
	nmap -sS "$1" -oX "$workdir/init_scan/default_scan.xml" >/dev/null && \
xmlstarlet sel -t -m "//port[state/@state='open']" -v "@portid" -o "=" -v "service/@name" -n "$workdir/init_scan/default_scan.xml" > \
  "$workdir/init_scan/open_ports.txt" 
	return 0
}

scan_by_service(){
	echo "Dentro Metodo"
	for line in  $(cat "$workdir/init_scan/open_ports.txt")
        do
		
		port=$(echo "$line" | cut -d"=" -f1)
       		service_name=$(echo "$line" | cut -d"=" -f2)
		echo "Trabalhando com o host: $target na porta $port hospendando o servico $service_name"
		case "$service_name" in
			*ftp*)
				ftp_enum "$target" "$port" "$service_name"
		esac
	done
        return 0
}

ftp_enum(){
	if [ -f modules/ftp.sh ]
	then
		echo Ok
		mkdir -p "$workdir/$3/"
		./lib/network.sh $1 $2 $3 &
		./modules/ftp.sh $1 $2 $3 &
		wait
	fi
}

while [ "$#" -gt 0 ]
do
        case "$1" in
                --help | -h)
                        echo "Opção Help"
                        shift
                        ;;
                --host | -H)
                        if [ -z "$2" ]; then
                                echo "Nao passou Ip"
                                exit 1
                        fi
			target=$2
                        default_scan "$target"
			scan_by_service 
			shift 2
                        ;;
                *)
                        echo "Opção $1 é invalida"
                        exit 1
                        ;;
        esac
done
