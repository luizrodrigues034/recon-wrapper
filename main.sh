
default_scan(){
	if [ ! -d ~/$1 ]
	then
        	mkdir ~/$1
	fi
	sudo nmap -sS -p- $1 -oX ~/$1/default_scan.xml &&  grep "open" ~/192.168.59.131/default_scan.xml \
| sed -E 's/.*portid="([0-9]+)".*name="([a-zA-Z0-9-]+)".*/\1=\2/' > ~/$1/open_ports.txt
	return 0;
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
                        default_scan "$2"
			shift
                        shift
                        ;;
                *)
                        echo "Opção $1 é invalida"
                        exit 1
                        ;;
        esac
done
