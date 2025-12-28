#!/bin/bash
set -e

[ "$EUID" -ne 0 ] && echo "Por favor, execute como root." && exit 1

# Define o usuário real (quem chamou o sudo) para ajustar permissões depois
REAL_USER=${SUDO_USER:-$USER}

echo "[*] Verificando gestor de pacotes (apt-get)..."
command -v apt-get >/dev/null 2>&1 || { echo "apt-get não encontrado. Execute este script em um sistema Debian/Ubuntu."; exit 1; }

echo "[*] Atualizando repositórios e instalando dependências do sistema..."
export DEBIAN_FRONTEND=noninteractive
apt-get update > /dev/null

# Instala dependências mínimas (mantendo o script simples)
apt-get install -y nmap netcat-openbsd openssl xmlstarlet wget curl git python3 python3-pip python3-venv > /dev/null

echo "[*] Configurando ambiente Python (venv) para ssh-audit..."

# Cria o ambiente virtual se não existir
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi

# Atualiza pip dentro do venv e instala ssh-audit
./.venv/bin/pip install --upgrade pip > /dev/null || true
./.venv/bin/pip install --upgrade ssh-audit > /dev/null || echo "[!] Falha ao instalar ssh-audit (verifique a internet)"

# Cria um link simbólico para /usr/local/bin se disponível
if [ -f ".venv/bin/ssh-audit" ]; then
    ln -sf "$(pwd)/.venv/bin/ssh-audit" /usr/local/bin/ssh-audit || true
    echo "[*] Link simbólico criado. Você pode rodar 'ssh-audit' globalmente."
fi

# Corrige as permissões da pasta .venv para o usuário original (se definido)
if [ -n "$REAL_USER" ]; then
    chown -R "$REAL_USER":"$REAL_USER" .venv || true
fi

echo "[+] Configuração concluída."
