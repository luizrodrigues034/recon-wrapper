#!/bin/env  bash
default_scan(){
	if [ ! -d ./workspaces/$1 ]
	then
        	mkdir -p ./workspaces/$1
	fi
	workdir="./workspaces/$1"
	sudo nmap -sS "$1" -oX "$workdir/default_scan.xml" >/dev/null && xmlstarlet sel -t -m "//port[state/@state='open']" -v "@portid" -o "=" -v "service/@name" -n "$workdir/default_scan.xml" > "$workdir/open_ports.txt"
	return 0;
}

ftp_enum(){
	echo "Teste ftp $1"
	if [ -f modules/ftp.sh ]
	then
		echo Ok
		./modules/ftp.sh $1 21
	fi
}

while [ -n "$1" ]
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
			ftp_enum "$target"
			shift
                        shift
                        ;;
                *)
                        echo "Opção $1 é invalida"
                        exit 1
                        ;;
        esac
done
