# Recon Wrapper

## 🚀 Status: Em Desenvolvimento / Em Uso

Recon Wrapper é um framework modular de reconhecimento automatizado de hosts que simplifica e automatiza a enumeração de serviços em redes. O projeto está em desenvolvimento ativo e já inclui módulos para FTP, HTTP e SSH, além de bibliotecas auxiliares em `lib/`.

---

## 📋 Descrição do Projeto

O Recon Wrapper é um **framework modular** que funciona da seguinte forma:

1. **Scan Inicial**: Realiza um scan SYN com Nmap para identificar todas as portas abertas no host alvo
2. **Identificação de Serviços**: Extrai informações de qual serviço está rodando em cada porta
3. **Enumeração Inteligente**: Executa scripts de enumeração específicos conforme o tipo de serviço detectado
4. **Persistência de Dados**: Todos os resultados são salvos em arquivos organizados por host e serviço

Este é um projeto em **desenvolvimento ativo**, onde novos módulos de enumeração estão sendo adicionados continuamente para cobrir mais tipos de serviços.

---

## 🎯 Objetivo

Criar um wrapper automatizado que:
- Reduza o tempo de reconhecimento manual
- Organize resultados de enumeração de forma estruturada
- Seja facilmente extensível com novos módulos de enumeração
- Execute diferentes técnicas conforme o serviço identificado (FTP, SSH, HTTP, SMB, etc.)

---

## 🏗️ Arquitetura

### Estrutura de Diretórios
```
recon-wrapper/
├── main.sh              # Script principal - orquestra o fluxo
├── modules/             # Diretório contendo módulos de enumeração
│   ├── ftp.sh           # Módulo de enumeração FTP (banner grabbing)
│   ├── http.sh          # Módulo de enumeração HTTP
│   └── ssh.sh           # Módulo de enumeração SSH
├── lib/                 # Scripts auxiliares (ex: network helpers)
│   └── network.sh
├── workspaces/         # Diretório de saída (criado automaticamente)
│   └── {host}/
│       ├── init_scan/
│       │   ├── default_scan.xml      # Resultado XML do Nmap
│       │   └── open_ports.txt        # Portas abertas identificadas
│       ├── ftp_service/
│       │   └── banner_ftp.txt        # Banner grabbing do FTP
│       └── ...
└── README.md
```

### Fluxo de Execução

```
┌─────────────────────────────────────┐
│   Alvo: Host com IP/Hostname        │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│   Default Scan (Nmap SYN)           │
│   Identifica portas abertas         │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│   Parsing de Serviços               │
│   Extrai: porta=serviço             │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│   Enumeração por Serviço            │
│   • FTP → ftp.sh                    │
│   • SSH → ssh.sh                    │
│   • HTTP → http.sh                  │
│   • ...                             │
└────────────────┬────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│   Salvamento em Arquivos            │
│   workspaces/{host}/{servico}/      │
└─────────────────────────────────────┘
```

---

## 📦 Módulos de Enumeração

### Módulo FTP (ftp.sh)
- **Status**: Implementado (em desenvolvimento)
- **Funcionalidade**: Realiza Banner Grabbing do serviço FTP
- **Saída**: Banner do FTP salvo em `ftp_service/banner_ftp.txt`
- **Técnicas**:
  - Conexão direta via Netcat
  - Conexão segura via OpenSSL STARTTLS

### Módulos Adicionais (planejados)
- `smb.sh` - Enumeração SMB (shares, usuários)
- `dns.sh` - Enumeração DNS (zonas, registros)
- `ldap.sh` - Enumeração LDAP (diretórios, usuários)

---

## 🛠️ Requisitos

- **Linux/Unix** (ou Windows com WSL)
- **Bash** 4.0+
- **Nmap** - Para scan de portas
- **Netcat** - Para banner grabbing
- **OpenSSL** - Para conexões seguras
- **XMLStarlet** - Para parsing de XML do Nmap
- **Privilégios sudo** - Para executar Nmap SYN

### Instalação de Dependências

**Debian/Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install nmap netcat-openbsd openssl xmlstarlet
```

**Fedora/RHEL:**
```bash
sudo dnf install nmap ncat openssl xmlstarlet
```

---

## 🚀 Uso

### Sintaxe Básica
```bash
./main.sh --host <IP_ou_hostname>
```

### Exemplo
```bash
./main.sh --host 192.168.1.100
./main.sh -H 10.0.0.50
```

### O que Acontece
1. Cria um workspace em `./workspaces/192.168.1.100/`
2. Executa Nmap para descobrir portas abertas
3. Salva resultados em XML e lista de portas
4. Identifica serviços em cada porta
5. Executa enumeração específica para cada serviço
6. Salva todos os resultados organizados por tipo de serviço

### Estrutura de Saída
```
workspaces/192.168.1.100/
├── init_scan/
│   ├── default_scan.xml           # Scan Nmap completo
│   └── open_ports.txt             # Formato: porta=serviço
├── ftp_service/
│   └── banner_ftp.txt             # Banner do FTP
└── ...
```

---

## 📝 Exemplo de Resultado

**open_ports.txt:**
```
21=ftp
22=ssh
80=http
443=https
3306=mysql
```

**banner_ftp.txt:**
```
220 ProFTPD 1.3.5 Server (Debian) [192.168.1.100]
```

---

## 🔧 Desenvolvimento

### Criando um Novo Módulo

1. Crie um arquivo em `modules/servico.sh`
2. Receba os parâmetros: host (`$1`) e porta (`$2`)
3. Crie o diretório de saída em `workspaces/{host}/{tipo_servico}/`
4. Salve os resultados em arquivos apropriados
5. Registre o módulo no `scan_by_service()` do `main.sh`

**Template:**
```bash
#!/bin/bash
target=$1
port=$2
workdir="workspaces/$1"

if [ ! -d $workdir/servico_service ]
then
    mkdir -p $workdir/servico_service
fi

# Sua lógica de enumeração aqui
# Salve em: $workdir/servico_service/resultado.txt
```

### Integração no main.sh
```bash
case "$service_name" in
    *ftp*)
        ftp_enum "$target" "$port"
        ;;
    *ssh*)
        ssh_enum "$target" "$port"
        ;;
    *http*)
        http_enum "$target" "$port"
        ;;
esac
```

---

## 📚 Roadmap

- [x] Estrutura base do framework
- [x] Scan Nmap automatizado
- [x] Parser de portas abertas
- [x] Módulo FTP (banner grabbing)
- [ ] Módulo SSH
- [ ] Módulo HTTP/HTTPS
 - [x] Estrutura base do framework
 - [x] Scan Nmap automatizado
 - [x] Parser de portas abertas
 - [x] Módulo FTP (banner grabbing)
 - [x] Módulo SSH
 - [x] Módulo HTTP/HTTPS
- [ ] Módulo SMB
- [ ] Módulo DNS
- [ ] Tratamento de erros aprimorado
- [ ] Logging centralizado
- [ ] Interface web (futuro)
- [ ] Suporte a múltiplos hosts

---

## ⚠️ Notas Importantes

- Sempre use com **permissões apropriadas** e **autorização do proprietário da rede**
- Este é um **projeto de segurança ofensiva** - use responsavelmente
- Certifique-se de ter **privilégios sudo** configurados
- Os resultados são salvos localmente em `workspaces/`

---

## 📄 Licença

Ver arquivo [LICENSE](LICENSE) para detalhes.

---

## 🤝 Contribuições

Este é um projeto em desenvolvimento. Contribuições são bem-vindas! Sinta-se livre para:
- Reportar bugs
- Sugerir novos módulos
- Melhorar a documentação
- Otimizar o código existente

---

## ✉️ Contato

Para dúvidas ou sugestões sobre o projeto, entre em contato.

---

**Última atualização**: 28 de Dezembro de 2025