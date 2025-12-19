target=$1
port=$2
service_name=$3
workdir=workspaces/"$1"/"$service_name"

banner_grabling(){
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
                echo "$banner" > "$workdir/banner.txt"
                return 0
        fi
}

banner_grabling
