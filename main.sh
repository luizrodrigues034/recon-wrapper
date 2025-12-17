default_scan(){
        mkdir ~/$1 && sudo nmap -sS $1 -oX ~/$1/default_scan.xml && cat ~/$1/default_scan.xml
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
