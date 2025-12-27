target="$1"
port="$2"
service_name="$3"

WORKDIR="workspaces/$target/$service_name"

run_whatweb(){
	local target="$1"
	local port="$2"
	local service_name="$3"
	echo "$target"
	echo "$port"
	echo "$target:$port"
	if command -v whatweb > /dev/null
	then
		whatweb -a 3 "http://$target:$port" > "$WORKDIR/whatweb.txt"
	else
		echo "[!] ERRO: what web não esta instalado"
	fi

	if [ -s  "$WORKDIR/whatweb.txt" ]
	then
		echo "[*] Resultado do whatweb foi salvo"
	else
		echo "[!] Resultado do whatweb nao foi salvo."
		return 0
	fi
}

run_whatweb "$target" "$port" "$service_name"
