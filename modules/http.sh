target="$1"
port="$2"
service_name="$3"

WORKDIR="workspaces/$target/$service_name"

run_whatweb(){
	local target="$1"
	local port="$2"

	if command -v whatweb > /dev/null
	then
		whatweb -a 3 "http://$target:$port" > "$WORKDIR/whatweb.txt"
	else
		echo "[!] ERRO: whatweb não esta instalado"
	fi

	if [ -s  "$WORKDIR/whatweb.txt" ]
	then
		echo "[*] Resultado do whatweb foi salvo"
	else
		echo "[!] Resultado do whatweb nao foi salvo."
		return 0
	fi
}
run_nikto(){
	local target="$1"
        local port="$2"
	
	if command -v nikto > /dev/null
	then
		nikto -h "$target" -p "$port" -o "$WORKDIR/nikto.html" -Format htm
	else
		echo "ERRO: nikto nao instalado"
	fi
	if [ -s "$WORKDIR/nikto.html"  ]
	then
		echo "[*] Resultado do nikto foi salvo"
		return 0
	else
		echo "[!] Resultado do nikto nao foi salvo"
		return 1
	fi
}



run_whatweb "$target" "$port" 
run_nikto "$target" "$port" 

