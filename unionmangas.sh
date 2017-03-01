#!/usr/bin/env bash
function version() {
  echo "[+] Union Mangás: Leitor Online em Português 1.3"
}
function frase() {
  echo "Veja https://github.com/kumroute/unionmangas/ para mais informações"
}
function verificar_arquivos() {
  if [ ! -e ~/Documentos/unionmangas/config_name_list.txt ] ; then
    echo "Tales of Demons and Gods" > ~/Documentos/unionmangas/config_name_list.txt
  fi
  if [ ! -e ~/Documentos/unionmangas/config.txt ] ; then
    echo "tales-of-demons-and-gods" > ~/Documentos/unionmangas/config.txt
  fi
}
function show() {
  if [ $1 ] ; then param=$1
  else param=2 ; fi
  function config() {
  curl -s http://unionmangas.net/manga/$1 | grep "font-size: 10px; color: #999" | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed -e 's/                    //g' | head -$param > ~/Documentos/unionmangas/union.txt
  }
  function show_cap() {
    i=1 ; while [ $i -le $param ] ; do
      echo "  $(cat ~/Documentos/unionmangas/union.txt | head -$i | tail -1)"
      i=$[i+1]
    done
    rm ~/Documentos/unionmangas/union.txt
  }
  echo "[+] Hoje é dia $(date +%d/%m/%Y)"
  num_linhas=$(wc -l ~/Documentos/unionmangas/config.txt | awk '{print $1}')
  j=1 ; while [ $j -le $num_linhas ] ; do
    printf $j > ~/Documentos/unionmangas/temp.txt
    printf p >> ~/Documentos/unionmangas/temp.txt
    valor=$(cat ~/Documentos/unionmangas/temp.txt) ; rm ~/Documentos/unionmangas/temp.txt
    nome_manga=$(sed -n $valor ~/Documentos/unionmangas/config_name_list.txt)
    nome_manga_url=$(sed -n $valor ~/Documentos/unionmangas/config.txt)
    config $nome_manga_url ; echo "[#$j] $nome_manga" ; show_cap
    j=$[j+1]
  done
}
function config_file_add() {
  read -p " :: Nome do mangá : " name
  echo $name >> ~/Documentos/unionmangas/config_name_list.txt
  echo $(echo $name | awk '{print tolower($0)}' | sed -e 's/ /-/g' | sed -e 's/(//g' | sed -e 's/)//g') >> ~/Documentos/unionmangas/config.txt
}
function config_file_remove() {
  read -p " :: Número do mangá : " numero
  name=$(cat ~/Documentos/unionmangas/config_name_list.txt | head -$numero | tail -1)
  sed -i "/${name}/d" ~/Documentos/unionmangas/config_name_list.txt
  nome_manga_url=$(echo $name | awk '{print tolower($0)}' | sed -e 's/ /-/g' | sed -e 's/(//g' | sed -e 's/)//g')
  sed -i '/'${nome_manga_url}'/d' ~/Documentos/unionmangas/config.txt
}
function config_file_list() {
  num_linhas=$(wc -l ~/Documentos/unionmangas/config_name_list.txt | awk '{print $1}')
  k=1 ; while [ $k -le $num_linhas ] ; do
    echo "[#$k] $(cat ~/Documentos/unionmangas/config_name_list.txt | head -$k | tail -1)"
    k=$[k+1]
  done
}
function read_cap() {
  nome_manga=$(cat ~/Documentos/unionmangas/config_name_list.txt | head -$1 | tail -1)
  echo "[+] Nome do mangá: $nome_manga"
  nome_manga_url=$(cat ~/Documentos/unionmangas/config.txt | head -$1 | tail -1)
  if [ "$2" == "last" ] ; then
    curl -s http://unionmangas.net/manga/$nome_manga_url | grep "font-size: 10px; color: #999" | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed -e 's/                    //g' | head -1 > ~/Documentos/unionmangas/union.txt
    num_cap=$(cat ~/Documentos/unionmangas/union.txt | awk {'print $2'})
    echo "[+] Número do capítulo: $num_cap"
  else
    num_cap=$2
    echo "[+] Número do capítulo: $num_cap"
  fi
  nome_manga_url=$(cat ~/Documentos/unionmangas/config_name_list.txt | head -$1 | tail -1 | sed -e 's/ /_/g')
  firefox http://unionmangas.net/leitor/$nome_manga_url/$num_cap
  rm ~/Documentos/unionmangas/union.txt
}
function download() {
  nome_manga=$(cat ~/Documentos/unionmangas/config_name_list.txt | head -$1 | tail -1)
  echo "[+] Nome do mangá: $nome_manga"
  nome_manga_url=$(cat ~/Documentos/unionmangas/config.txt | head -$1 | tail -1)
  if [ "$2" == "last" ] ; then
    curl -s http://unionmangas.net/manga/$nome_manga_url | grep "font-size: 10px; color: #999" | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed -e 's/                    //g' | head -1 > ~/Documentos/unionmangas/union.txt
    num_cap=$(cat ~/Documentos/unionmangas/union.txt | awk {'print $2'})
    echo "[+] Número do capítulo: $num_cap"
  else
    num_cap=$2
    echo "[+] Número do capítulo: $num_cap"
  fi
  nome_manga_url=$(cat ~/Documentos/unionmangas/config_name_list.txt | head -$1 | tail -1 | sed -e 's/ /_/g')
  curl -s http://unionmangas.net/leitor/$nome_manga_url/$num_cap | grep ".jpg" | grep "data-lazy" | sed -e 's/<img data-lazy=\"//g' | sed -e 's/  class=\"real img-responsive\" id=\"imagem-//g' | sed -e 's/.jpg\"/.jpg /g' | sed -e 's/  \/>//g' | sed -e 's/                    //g' > ~/Documentos/unionmangas/union_links.txt
  nome_dir=$(echo $nome_manga | sed -e 's/ /_/g')
  if [ ! -d ~/Documentos/unionmangas/$nome_dir ] ; then
    mkdir ~/Documentos/unionmangas/$nome_dir
  fi
  if [ ! -d ~/Documentos/unionmangas/$nome_dir/$num_cap ] ; then
    mkdir ~/Documentos/unionmangas/$nome_dir/$num_cap
  fi
  num_linhas=$(wc -l ~/Documentos/unionmangas/union_links.txt | awk '{print $1}')
  n=1 ; while [ $n -le $num_linhas ] ; do
    capitulo=$(cat ~/Documentos/unionmangas/union_links.txt | sed -e 's/ /_/g' | sed -e 's/.jpg_/.jpg /g' | head -$n | tail -1 | awk {'print $2'})
    echo "[+] Baixando $capitulo..."
    link_baixar=$(cat ~/Documentos/unionmangas/union_links.txt | sed -e 's/ /_/g' | sed -e 's/.jpg_/.jpg /g' | head -$n | tail -1 | awk {'print $1'} | sed -e 's/_/ /g' | sed -e 's/UnM /UnM_/g')
    wget -q "$link_baixar"
    mv ./"$(echo $capitulo | sed -e 's/_/ /g')" ~/Documentos/unionmangas/$nome_dir/$num_cap/
    n=$[n+1]
  done
  rm ~/Documentos/unionmangas/union_links.txt
}
function news() {
  curl -s http://unionmangas.net | grep "&nbsp;<a href" | sed -e "s/&nbsp;<a href=\"http:\/\/unionmangas.net\/leitor\///g" | sed -e 's/<\/a>//g' | sed -e 's/\">/ /g' | sed -e 's/                                / /g' | sed -e 's/\// /g' > ~/Documentos/unionmangas/union.txt
  quantidade=$1
  m=1 ; while [ $m -le $quantidade ] ; do
    printf $m > ~/Documentos/unionmangas/temp.txt
    printf p >> ~/Documentos/unionmangas/temp.txt
    valor=$(cat ~/Documentos/unionmangas/temp.txt) ; rm ~/Documentos/unionmangas/temp.txt
    nome_manga=$(sed -n $valor ~/Documentos/unionmangas/union.txt | awk {'print $1'} | sed -e 's/_/ /g')
    numero_cap=$(sed -n $valor ~/Documentos/unionmangas/union.txt | awk {'print $4'})
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
    if [ "$3" == "remove" ] ; then
      rm ~/Documentos/unionmangas/config_name_list.txt
      rm ~/Documentos/unionmangas/config.txt
    else
      config_file_list
    fi
  fi
fi
if [ "$1" == "read" ] || [ "$1" == "download" ] ; then
  if [ ! $2 ] ; then
    version
    echo "[+] Uso: unionmangas $1 <número do mangá> <capítulo>"
    echo " :: Se <capítulo> for omitido, o capítulo mais recente será selecionado"
    frase
  else
    if [ ! $3 ] ; then param="last"
    else param=$3 ; fi
    if [ "$1" == "read" ] ; then read_cap $2 $param
    else download $2 $param ; fi
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
