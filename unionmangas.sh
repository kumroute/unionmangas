#!/usr/bin/env bash
function version() {
  echo "[+] Union Mangás: Leitor Online em Português 1.5"
}
function frase() {
  echo "Veja https://github.com/kumroute/unionmangas/ para mais informações"
}
function verificar_arquivos() {
  : ${XDG_CONFIG_HOME:="$HOME/.config"}
  diretorio_config="$XDG_CONFIG_HOME/unionmangas"
  : ${MANGA_DOWNLOAD:="$diretorio_config/Downloads"}
  if [ ! -d $diretorio_config ] ; then
    mkdir $diretorio_config
  fi
  if [ ! -d $MANGA_DOWNLOAD ] ; then
    mkdir $MANGA_DOWNLOAD
  fi
  if [ ! -e $diretorio_config/config_name_list.txt ] ; then
    echo "Tales of Demons and Gods" > $diretorio_config/config_name_list.txt
  fi
  if [ ! -e $diretorio_config/config.txt ] ; then
    echo "tales-of-demons-and-gods" > $diretorio_config/config.txt
  fi
}
function show() {
  if [ $1 ] ; then param=$1
  else param=2 ; fi
  function config() {
  union=$(curl -s "http://unionmangas.net/manga/$1" | grep "font-size: 10px; color: #999" | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed -e 's/                    //g' | head -$param)
  }
  function show_cap() {
    i=1 ; while [ $i -le $param ] ; do
      echo "  $(echo "$union" | head -$i | tail -1)"
      i=$[i+1]
    done
  }
  echo "[+] Hoje é dia $(date +%d/%m/%Y)"
  num_linhas=$(wc -l $diretorio_config/config.txt | awk '{print $1}')
  j=1 ; while [ $j -le $num_linhas ] ; do
    valor=$(printf "$j" ; printf "p")
    nome_manga=$(sed -n $valor $diretorio_config/config_name_list.txt)
    nome_manga_url=$(sed -n $valor $diretorio_config/config.txt)
    config $nome_manga_url ; echo "[#$j] $nome_manga" ; show_cap
    j=$[j+1]
  done
}
function config_file_add() {
  read -p " :: Nome do mangá : " name
  echo $name >> $diretorio_config/config_name_list.txt
  echo $(echo $name | awk '{print tolower($0)}' | sed -e 's/ /-/g' | sed -e 's/(//g' | sed -e 's/)//g') >> $diretorio_config/config.txt
}
function config_file_remove() {
  read -p " :: Número do mangá : " numero
  name=$(cat $diretorio_config/config_name_list.txt | head -$numero | tail -1)
  sed -i "/${name}/d" $diretorio_config/config_name_list.txt
  nome_manga_url=$(echo $name | awk '{print tolower($0)}' | sed -e 's/ /-/g' | sed -e 's/(//g' | sed -e 's/)//g')
  sed -i '/'${nome_manga_url}'/d' $diretorio_config/config.txt
}
function config_file_list() {
  num_linhas=$(wc -l $diretorio_config/config_name_list.txt | awk '{print $1}')
  k=1 ; while [ $k -le $num_linhas ] ; do
    echo "[#$k] $(cat $diretorio_config/config_name_list.txt | head -$k | tail -1)"
    k=$[k+1]
  done
}
function read_cap() {
  nome_manga_url=$(cat $diretorio_config/config_name_list.txt | head -$1 | tail -1 | sed -e 's/ /_/g')
  firefox http://unionmangas.net/leitor/$nome_manga_url/$num_cap
}
function read_manga() {
    nome_do_manga=$(echo "$1" | sed -e 's/ /_/g')
    primeira_imagem=$(ls -t -l $MANGA_DOWNLOAD/$nome_do_manga/$2 | tail -1 | awk {'print $9'})
    viewnior "$MANGA_DOWNLOAD/$nome_do_manga/$2/$primeira_imagem"
}
function download() {
  num_cap=$2
  nome_manga=$(cat $diretorio_config/config_name_list.txt | head -$1 | tail -1)
  echo "[+] Nome do mangá: $nome_manga"
  nome_manga_url=$(cat $diretorio_config/config.txt | head -$1 | tail -1)
  nome_manga_url=$(cat $diretorio_config/config_name_list.txt | head -$1 | tail -1 | sed -e 's/ /_/g')
  curl -s "http://unionmangas.net/leitor/$nome_manga_url/$num_cap" | grep -E ".jpg|.png" | grep "data-lazy" | sed -e 's/<img data-lazy=\"//g' | sed -e 's/  class=\"real img-responsive\" id=\"imagem-//g' | sed -e 's/.jpg\"/.jpg /g' | sed -e 's/.png\"/.png /g' | sed -e 's/  \/>//g' | sed -e 's/                    //g' > $diretorio_config/union_links.txt
  nome_dir=$(echo $nome_manga | sed -e 's/ /_/g')
  if [ ! -d $MANGA_DOWNLOAD/$nome_dir ] ; then
    mkdir $MANGA_DOWNLOAD/$nome_dir
  fi
  if [ ! -d $MANGA_DOWNLOAD/$nome_dir/$num_cap ] ; then
    mkdir $MANGA_DOWNLOAD/$nome_dir/$num_cap
  fi
  num_linhas=$(wc -l $diretorio_config/union_links.txt | awk '{print $1}')
  n=1 ; while [ $n -le $num_linhas ] ; do
    capitulo=$(cat $diretorio_config/union_links.txt | head -$n | tail -1 | sed -e 's/ /_/g' | sed -e 's/.jpg_/.jpg /g' | sed -e 's/.png_/.png /g' | awk {'print $2'})
    nome_manga_url=$(cat $diretorio_config/union_links.txt | head -$n | tail -1 | sed -e 's/ /_/g' | sed -e 's/.jpg_/.jpg /g' | sed -e 's/.png_/.png /g' | awk {'print $1'} | sed -e 's/\// /g' | awk '{print $5}' | sed -e 's/_/ /g')
    arquivo=$(cat $diretorio_config/union_links.txt | sed -e 's/ /_/g' | sed -e 's/.jpg_/.jpg /g' | sed -e 's/.png_/.png /g' | head -$n | tail -1 | awk {'print $1'} | sed -e 's/\// /g' | awk '{print $7}' | sed -e 's/-_/- /g')
    link_baixar="http://unionmangas.net/leitor/mangas/$nome_manga_url/$num_cap/$arquivo"
    if [ "$arquivo" ] ; then
      echo "[+] Baixando $capitulo..."
      wget --max-redirect=0 -q "$link_baixar"
      if [ $? -eq 0 ] ; then
        mv ./"$(echo $capitulo | sed -e 's/-_/- /g')" $MANGA_DOWNLOAD/$nome_dir/$num_cap/$capitulo
      fi
    fi
    n=$[n+1]
  done
  read -n 1 -p " :: Gostaria de ler o capítulo agora ? [S/N] : " escolha
  printf "\n"
  if [ "$escolha" == "s" ] || [ "$escolha" == "S" ] ; then
    primeiro_cap=$(ls -t -l $MANGA_DOWNLOAD/$nome_dir/$num_cap/ | tail -1 | awk {'print $9'})
    viewnior $MANGA_DOWNLOAD/$nome_dir/$num_cap/$primeiro_cap
  fi
  rm $diretorio_config/union_links.txt
}
function news() {
  union=$(curl -s http://unionmangas.net | grep "&nbsp;<a href" | sed -e "s/&nbsp;<a href=\"http:\/\/unionmangas.net\/leitor\///g" | sed -e 's/<\/a>//g' | sed -e 's/\">/ /g' | sed -e 's/                                / /g' | sed -e 's/\// /g')
  quantidade=$1
  m=1 ; while [ $m -le $quantidade ] ; do
    nome_manga=$(echo "$union" | head -$m | tail -1 | awk {'print $1'} | sed -e 's/_/ /g')
    numero_cap=$(echo "$union" | head -$m | tail -1 | awk {'print $4'})
    echo "[#$m] $nome_manga"
    echo "  Cap. $numero_cap"
    m=$[m+1]
  done
}

verificar_arquivos

if [ "$1" == "help" ] || [ ! $1 ] ; then
  version
  echo "[+] Uso: unionmangas <opção>"
  echo " :: help         :: mostra essa página de ajuda"
  echo " :: show         :: mostrar os mangás configurados"
  echo " :: config       :: configurações"
  echo " :: read         :: ler um mangá"
  echo " :: news         :: mostra os últimos mangás publicados"
  echo " :: download     :: baixa um capítulo de algum mangá"
  frase
fi
if [ "$1" == "show" ] ; then
  if [ ! $2 ] ; then
    version
    echo "[+] Uso: unionmangas show <número de capítulos>"
    frase
  else
    show $2
  fi
fi
if [ "$1" == "config" ] ; then
  if [ ! $2 ] ; then
    version
    echo "[+] Uso: unionmangas config <opção>"
    echo " :: add          :: adicionar um mangá na lista"
    echo " :: remove       :: remover um mangá da lista"
    echo " :: list         :: mostrar os mangás da lista"
    frase
  fi
  if [ "$2" == "add" ] ; then
    config_file_add
  fi
  if [ "$2" == "remove" ] ; then
    config_file_remove
  fi
  if [ "$2" == "list" ] ; then
    config_file_list
  fi
fi
if [ "$1" == "read" ] ; then
  if [ ! $2 ] ; then
    version
    echo "[+] Uso: unionmangas read <opção> <número do mangá> <capítulo>"
    echo " :: <opção> pode ser online (pelo firefox) ou offline (por um mangá já baixado)"
    echo " :: Se <capítulo> for omitido, o capítulo mais recente será selecionado"
    frase
  else
    if [ ! $4 ] ; then
      num_cap=$(show 1 | grep "Cap." | head -$3 | tail -1 | awk {'print $2'})
      echo "[+] Número do capítulo: $num_cap"
    else
      num_cap=$4
      echo "[+] Número do capítulo: $num_cap"
    fi
    nome_manga=$(cat $diretorio_config/config_name_list.txt | head -$3 | tail -1)
    echo "[+] Nome do mangá: $nome_manga"
    if [ "$2" == "online" ] ; then
      read_cap $3 $num_cap
    fi
    if [ "$2" == "offline" ] ; then
      read_manga "$nome_manga" $num_cap
    fi
  fi
fi

if [ "$1" == "download" ] ; then
  if [ ! $2 ] ; then
    version
    echo "[+] Uso: unionmangas download <número do mangá> <capítulo>"
    echo " :: Se <capítulo> for omitido, o capítulo mais recente será selecionado"
    frase
  else
    if [ ! $3 ] ; then
    num_cap=$(show 1 | grep "Cap." | head -$2 | tail -1 | awk {'print $2'})
    echo "[+] Número do capítulo: $num_cap"
  else
    num_cap=$3
    echo "[+] Número do capítulo: $num_cap"
  fi
  download $2 $num_cap
  fi
fi
if [ "$1" == "news" ] ; then
  if [ ! $2 ] ; then
    version
    echo "[+] Uso: unionmangas news <número de mangás>"
    frase
  else
    news $2
  fi
fi
if [ "$1" == "reset" ] ; then
  rm -rf $diretorio_config/config.txt
  rm -rf $diretorio_config/config_name_list.txt
  rm -rf $diretorio_config/union_links.txt
fi

