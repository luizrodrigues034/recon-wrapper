#!/bin/env bash
WORKDIR=workspaces/$1/

run_ssh_audit(){
	local target="$1"
	local port="$2"
	local service_name="$3"
	echo "[*] Iniciando ssh-audit"
	ssh-audit -p "$port" -j "$target" |jq 1> "$WORKDIR/$service_name/ssh_audit_result.json" 2>/dev/null 
	if [ -s "$WORKDIR/$service_name/ssh_audit_result.json" ]
	then
		echo "ssh-audit feito com sucesso"
		return 0
	else
		echo "[!]ssh-audit falhou"
		return 1
	fi
}


target_arg="$1"
port_arg="$2"
service_name_arg="$3"

run_ssh_audit "$target_arg" "$port_arg" "$service_name_arg"
