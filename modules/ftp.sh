target=$1
port=$2
workdir=workspaces/$1

banner_grabling(){
	echo "Metodo Chamado"
	banner=$(timeout 5 nc -vn "$1" "$2" 2>/dev/null || \
	echo "QUIT" | timeout 10 openssl s_client -connect "$1:$2" -starttls ftp -quiet 2>/dev/null)
	echo "consultou"
	if [ -z "$banner" ]
	then
		echo "Nenhum Banner encontrado"
		return 1
	else
		echo "Salvando"
		echo "$banner" >> $workdir/ftp_service/banner_ftp.txt
		return 0
	fi
}

if [ ! -d $workdir/ftp_service ]
then
	mkdir $workdir/ftp_service
fi

banner_grabling $1 $2
