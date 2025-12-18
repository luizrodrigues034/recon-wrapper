target=$1
port=$2
workdir=workspaces/$1

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
		echo "$banner" >> $workdir/ftp_service/banner_ftp.txt
		return 0
	fi
}

nmap_ftp(){
	nmap -sV -p "$port" -sC -A "$target" -oX $workdir/ftp_service/nmap_ftp.xml > /dev/null
	xml_file="$workdir/ftp_service/nmap_ftp.xml"

	if grep -q "Anonymous FTP login allowed" "$xml_file"
	then
		echo "[*]Chama metodo de download recursivo"
		echo "[*]Metodo de listagem de diretorios caso nao for possivel"
		return 0
	fi
	echo "[*] Login Anonimo nao e permitido"
	return 1
}

mkdir -p "$workdir/ftp_service"


banner_grabling &
nmap_ftp &
wait 
