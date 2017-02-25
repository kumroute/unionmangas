#!/usr/bin/env bash
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
  num_linhas=$(wc -l ~/Documentos/Unionmangas/config.txt | awk '{print $1}')
  j=1 ; while [ $j -le $num_linhas ] ; do
    printf $j > ~/Documentos/Unionmangas/temp.txt
    printf p >> ~/Documentos/Unionmangas/temp.txt
    valor=$(cat ~/Documentos/Unionmangas/temp.txt) ; rm ~/Documentos/Unionmangas/temp.txt
    nome_manga=$(sed -n $valor ~/Documentos/Unionmangas/config_name_list.txt)
    nome_manga_url=$(sed -n $valor ~/Documentos/Unionmangas/config.txt)
    config $nome_manga_url ; echo "$nome_manga" ; show_cap
    j=$[j+1]
  done
}
function config_file_add() {
  read -p " :: Nome do mangá : " name
  echo $name >> ~/Documentos/Unionmangas/config_name_list.txt
  echo $(echo $name | awk '{print tolower($0)}' | sed -e 's/ /-/g' | sed -e 's/(//g' | sed -e 's/)//g') >> ~/Documentos/Unionmangas/config.txt
}
function config_file_remove() {
  read -p " :: Nome do mangá : " name
  sed -i "/${name}/d" ~/Documentos/Unionmangas/config_name_list.txt
  nome_manga_url=$(echo $name | awk '{print tolower($0)}' | sed -e 's/ /-/g' | sed -e 's/(//g' | sed -e 's/)//g')
  sed -i '/'${nome_manga_url}'/d' ~/Documentos/Unionmangas/config.txt
}
function config_file_list() {
  cat ~/Documentos/Unionmangas/config_name_list.txt
}
if [ "$1" == "help" ] || [ ! $1 ] ; then
  echo "[+] Union Mangás: Leitor Online em Português"
  echo "[+] Uso: unionmangas <opção>"
  echo " :: help         :: mostra essa página de ajuda"
  echo " :: show         :: mostrar os mangás"
  echo " :: config       :: configurações"
  echo "Veja https://github.com/kumroute/unionmangas/ para mais informações"
fi
if [ "$1" == "show" ] ; then
  show $2
fi
if [ "$1" == "config" ] ; then
  if [ ! $2 ] ; then
    echo "[+] Union Mangás: Leitor Online em Português"
    echo "[+] Uso: unionmangas config <opção>"
    echo " :: add          :: adicionar um mangá na lista"
    echo " :: remove       :: remover um mangá da lista"
    echo " :: list         :: mostrar os mangás da lista"
    echo "Veja https://github.com/kumroute/unionmangas/ para mais informações"
  fi
  if [ "$2" == "add" ] ; then
    config_file_add
  fi
  if [ "$2" == "remove" ] ; then
    config_file_remove
  fi
  if [ "$2" == "list" ] ; then
    if [ "$3" == "remove" ] ; then
      rm ~/Documentos/Unionmangas/config_name_list.txt
      rm ~/Documentos/Unionmangas/config.txt
    else
      config_file_list
    fi
  fi
fi
