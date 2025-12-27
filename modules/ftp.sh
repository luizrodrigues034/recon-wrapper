#!/bin/env bash
WORKDIR=workspaces/$1

scan_anonymous_login(){
	local service_name="$1"

	local xml_file="$WORKDIR/$service_name/nmap_$service_name.xml"

	if grep -q "Anonymous FTP login allowed" "$xml_file"
	then
		recursive_extract "$target" "$port" "$service_name"  || echo "[!] Nmap detectou Anonymous, mas a validação falhou."
		return 0
	fi
	echo "[*] Login Anonimo nao e permitido"
	return 1
}

recursive_extract(){
	local target="$1"
        local port="$2"
        local service_name="$3"

        wget -m -nH --no-parent -P "$WORKDIR/$service_name/ftp_loot/" "ftp:anonymous:anonymous/${target}/" 2>/dev/null
	if [ $? -eq 0 ]
	then
		echo "[*]Ftp loot disponivel em $WORKDIR/$service_name/ftp_loot"
		return 0
	elif curl -s --fail -u "anonymous:anonymous" "ftp://$target/"
	then
		echo -e "NMAP_ANONYMOUS_FTP=YES\nTEST_ANONYMOUS_FTP=YES" > "$WORKDIR/$service_name/auth_ftp.txt"
        	return 0
	else
		echo -e "NMAP_ANONYMOUS_FTP=YES\nTEST_ANONYMOUS_FTP=FAIL" > "$WORKDIR/$service_name/auth_ftp.txt"
                return 1
	fi
}

target_arg="$1"
port_arg="$2"
service_name_arg="$3"

scan_anonymous_login "$service_name_arg"
