#!/bin/bash

[ "$EUID" -ne 0 ] && echo "Por favor, execute como root." && exit 1

#Define o usuário real (quem chamou o sudo) para ajustar permissões depois
REAL_USER=${SUDO_USER:-$USER}

echo "[*] Atualizando repositórios e instalando dependências do sistema..."
apt-get update > /dev/null

#Adicionado python3-venv, necessário para criar ambientes virtuais no Debian
apt-get install -y nmap xmlstarlet wget curl git python3 python3-pip python3-venv > /dev/null

echo "[*] Configurando ambiente Python (Venv) para ssh-audit..."

#Cria o ambiente virtual se não existir
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

#Instala o ssh-audit DENTRO do venv (sem afetar o sistema)
./.venv/bin/pip install --upgrade ssh-audit > /dev/null

#Cria um link simbólico para /usr/local/bin
if [ -f ".venv/bin/ssh-audit" ]; then
    ln -sf "$(pwd)/.venv/bin/ssh-audit" /usr/local/bin/ssh-audit
    echo "[*] Link simbólico criado. Você pode rodar 'ssh-audit' globalmente."
fi

#Corrige as permissões da pasta .venv para o usuário original
chown -R "$REAL_USER":"$REAL_USER" .venv

echo "[+] Configuração concluída."
