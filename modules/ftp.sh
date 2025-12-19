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
		recursive_extract || echo "[!] Nmap detectou Anonymous, mas a validação falhou."
		return 0
	fi
	echo "[*] Login Anonimo nao e permitido"
	return 1
}

recursive_extract(){
        wget -m -nH --no-parent -P "$workdir/ftp_service/ftp_loot/" "ftp://$target/" 2>/dev/null
	if [ $? -eq 0 ]
	then
		echo "[*]Ftp loot disponivel em $workdir/ftp_service/ftp_loot"
		return 0
	elif curl -s --fail -u "anonymous:anonymous" "ftp://$target/"
	then
		echo -e "NMAP_ANONYMOUS_FTP=YES\nTEST_ANONYMOUS_FTP=YES" > "$workdir/ftp_service/auth_ftp.txt"
        	return 0
	else
		echo -e "NMAP_ANONYMOUS_FTP=YES\nTEST_ANONYMOUS_FTP=FAIL" > "$workdir/ftp_service/auth_ftp.txt"
                return 1
	fi
}


mkdir -p "$workdir/ftp_service"


banner_grabling &
nmap_ftp &
wait 
