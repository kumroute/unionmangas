#!/usr/bin/env bash
function version() {
  echo "[+] Union Mangás: Leitor Online em Português 1.1"
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
  curl -s http://unionmangas.net/manga/$1 | grep "font-size: 10px; color: #999" | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed -e 's/                    //g' | head -$param > union.txt
  }
  function show_cap() {
    i=1 ; while [ $i -le $param ] ; do
      echo "  $(cat union.txt | head -$i | tail -1)"
      i=$[i+1]
    done
    rm union.txt
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
    curl -s http://unionmangas.net/manga/$nome_manga_url | grep "font-size: 10px; color: #999" | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed -e 's/                    //g' | head -1 > union.txt
    num_cap=$(cat union.txt | awk {'print $2'})
    echo "[+] Número do capítulo: $num_cap"
  else
    num_cap=$2
    echo "[+] Número do capítulo: $num_cap"
  fi
  nome_manga_url=$(cat ~/Documentos/unionmangas/config_name_list.txt | head -$1 | tail -1 | sed -e 's/ /_/g')
  firefox http://unionmangas.net/leitor/$nome_manga_url/$num_cap
}

verificar_arquivos

if [ "$1" == "help" ] || [ ! $1 ] ; then
  version
  echo "[+] Uso: unionmangas <opção>"
  echo " :: help         :: mostra essa página de ajuda"
  echo " :: show         :: mostrar os mangás"
  echo " :: config       :: configurações"
  echo " :: read         :: ler um mangá"
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
if [ "$1" == "read" ] ; then
  if [ ! $2 ] ; then
    version
    echo "[+] Uso: unionmangas <número do mangá> <capítulo>"
    echo " :: Se <capítulo> for omitido, o capítulo mais recente será selecionado"
    frase
  else
    if [ ! $3 ] ; then param="last"
    else param=$3 ; fi
    read_cap $2 $param
  fi
fi
