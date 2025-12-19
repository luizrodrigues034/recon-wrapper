target=$1
port=$2
service_name=$3
workdir=workspaces/$1

nmap_ftp(){
	nmap -sV -p "$port" -sC -A "$target" -oX "$workdir/$service_name/nmap_ftp.xml"> /dev/null
	xml_file="$workdir/$service_name/nmap_ftp.xml"

	if grep -q "Anonymous FTP login allowed" "$xml_file"
	then
		recursive_extract || echo "[!] Nmap detectou Anonymous, mas a validação falhou."
		return 0
	fi
	echo "[*] Login Anonimo nao e permitido"
	return 1
}

recursive_extract(){
        wget -m -nH --no-parent -P "$workdir/$service_name/ftp_loot/" "ftp://$target/" 2>/dev/null
	if [ $? -eq 0 ]
	then
		echo "[*]Ftp loot disponivel em $workdir/$service_name/ftp_loot"
		return 0
	elif curl -s --fail -u "anonymous:anonymous" "ftp://$target/"
	then
		echo -e "NMAP_ANONYMOUS_FTP=YES\nTEST_ANONYMOUS_FTP=YES" > "$workdir/$service_name/auth_ftp.txt"
        	return 0
	else
		echo -e "NMAP_ANONYMOUS_FTP=YES\nTEST_ANONYMOUS_FTP=FAIL" > "$workdir/$service_name/auth_ftp.txt"
                return 1
	fi
}

nmap_ftp 



