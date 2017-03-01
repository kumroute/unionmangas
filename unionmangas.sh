#!/usr/bin/env bash
function version() {
  echo "[+] Union Mangás: Leitor Online em Português 1.3"
}
function frase() {
  echo "Toda saída desse programa vai pra $"PASTA_MANGAS" sinta-se avontade para mudar para outra pasta"
  echo "Veja https://github.com/kumroute/unionmangas/ para mais informações"
}
function verificar_arquivos() {
  { # abre "econdedor de saída"
    : ${XDG_CONFIG_HOME:="$HOME/.config"} #Seta se nao existente
    . $XDG_CONFIG_HOME/unionmangas # se existente carrega o arquivo de config.
    if [[ $PASTA_MANGAS == "" ]]; then
      PASTA_MANGAS=~/Documentos/unionmangas
    fi
    mkdir $PASTA_MANGAS # nao faz nada se já existir 
  } #&> /dev/null # Esconde a saída dos comandos acima

  if [ ! -e $PASTA_MANGAS/config_name_list.txt ] ; then
    echo "test"
    echo "Tales of Demons and Gods" > $PASTA_MANGAS/config_name_list.txt
  fi
  if [ ! -e $PASTA_MANGAS/config.txt ] ; then
    echo "tales-of-demons-and-gods" > $PASTA_MANGAS/config.txt
  fi
}
function show() {
  if [ $1 ] ; then param=$1
  else param=2 ; fi
  function config() {
  curl -s http://unionmangas.net/manga/$1 | grep "font-size: 10px; color: #999" | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed -e 's/                    //g' | head -$param > $PASTA_MANGAS/union.txt
  }
  function show_cap() {
    i=1 ; while [ $i -le $param ] ; do
      echo "  $(cat $PASTA_MANGAS/union.txt | head -$i | tail -1)"
      i=$[i+1]
    done
    rm $PASTA_MANGAS/union.txt
  }
  echo "[+] Hoje é dia $(date +%d/%m/%Y)"
  num_linhas=$(wc -l $PASTA_MANGAS/config.txt | awk '{print $1}')
  j=1 ; while [ $j -le $num_linhas ] ; do
    printf $j > $PASTA_MANGAS/temp.txt
    printf p >> $PASTA_MANGAS/temp.txt
    valor=$(cat $PASTA_MANGAS/temp.txt) ; rm $PASTA_MANGAS/temp.txt
    nome_manga=$(sed -n $valor $PASTA_MANGAS/config_name_list.txt)
    nome_manga_url=$(sed -n $valor $PASTA_MANGAS/config.txt)
    config $nome_manga_url ; echo "[#$j] $nome_manga" ; show_cap
    j=$[j+1]
  done
}
function config_file_add() {
  read -p " :: Nome do mangá : " name
  echo $name >> $PASTA_MANGAS/config_name_list.txt
  echo $(echo $name | awk '{print tolower($0)}' | sed -e 's/ /-/g' | sed -e 's/(//g' | sed -e 's/)//g') >> $PASTA_MANGAS/config.txt
}
function config_file_remove() {
  read -p " :: Número do mangá : " numero
  name=$(cat $PASTA_MANGAS/config_name_list.txt | head -$numero | tail -1)
  sed -i "/${name}/d" $PASTA_MANGAS/config_name_list.txt
  nome_manga_url=$(echo $name | awk '{print tolower($0)}' | sed -e 's/ /-/g' | sed -e 's/(//g' | sed -e 's/)//g')
  sed -i '/'${nome_manga_url}'/d' $PASTA_MANGAS/config.txt
}
function config_file_list() {
  num_linhas=$(wc -l $PASTA_MANGAS/config_name_list.txt | awk '{print $1}')
  k=1 ; while [ $k -le $num_linhas ] ; do
    echo "[#$k] $(cat $PASTA_MANGAS/config_name_list.txt | head -$k | tail -1)"
    k=$[k+1]
  done
}
function read_cap() {
  nome_manga=$(cat $PASTA_MANGAS/config_name_list.txt | head -$1 | tail -1)
  echo "[+] Nome do mangá: $nome_manga"
  nome_manga_url=$(cat $PASTA_MANGAS/config.txt | head -$1 | tail -1)
  if [ "$2" == "last" ] ; then
    curl -s http://unionmangas.net/manga/$nome_manga_url | grep "font-size: 10px; color: #999" | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed -e 's/                    //g' | head -1 > $PASTA_MANGAS/union.txt
    num_cap=$(cat $PASTA_MANGAS/union.txt | awk {'print $2'})
    echo "[+] Número do capítulo: $num_cap"
  else
    num_cap=$2
    echo "[+] Número do capítulo: $num_cap"
  fi
  nome_manga_url=$(cat $PASTA_MANGAS/config_name_list.txt | head -$1 | tail -1 | sed -e 's/ /_/g')
  firefox http://unionmangas.net/leitor/$nome_manga_url/$num_cap
  rm $PASTA_MANGAS/union.txt
}
function download() {
  nome_manga=$(cat $PASTA_MANGAS/config_name_list.txt | head -$1 | tail -1)
  echo "[+] Nome do mangá: $nome_manga"
  nome_manga_url=$(cat $PASTA_MANGAS/config.txt | head -$1 | tail -1)
  if [ "$2" == "last" ] ; then
    curl -s http://unionmangas.net/manga/$nome_manga_url | grep "font-size: 10px; color: #999" | sed -n '/^$/!{s/<[^>]*>//g;p;}' | sed -e 's/                    //g' | head -1 > $PASTA_MANGAS/union.txt
    num_cap=$(cat $PASTA_MANGAS/union.txt | awk {'print $2'})
    echo "[+] Número do capítulo: $num_cap"
  else
    num_cap=$2
    echo "[+] Número do capítulo: $num_cap"
  fi
  nome_manga_url=$(cat $PASTA_MANGAS/config_name_list.txt | head -$1 | tail -1 | sed -e 's/ /_/g')
  curl -s http://unionmangas.net/leitor/$nome_manga_url/$num_cap | grep ".jpg" | grep "data-lazy" | sed -e 's/<img data-lazy=\"//g' | sed -e 's/  class=\"real img-responsive\" id=\"imagem-//g' | sed -e 's/.jpg\"/.jpg /g' | sed -e 's/  \/>//g' | sed -e 's/                    //g' > $PASTA_MANGAS/union_links.txt
  nome_dir=$(echo $nome_manga | sed -e 's/ /_/g')
  if [ ! -d $PASTA_MANGAS/$nome_dir ] ; then
    mkdir $PASTA_MANGAS/$nome_dir
  fi
  if [ ! -d $PASTA_MANGAS/$nome_dir/$num_cap ] ; then
    mkdir $PASTA_MANGAS/$nome_dir/$num_cap
  fi
  num_linhas=$(wc -l $PASTA_MANGAS/union_links.txt | awk '{print $1}')
  n=1 ; while [ $n -le $num_linhas ] ; do
    capitulo=$(cat $PASTA_MANGAS/union_links.txt | sed -e 's/ /_/g' | sed -e 's/.jpg_/.jpg /g' | head -$n | tail -1 | awk {'print $2'})
    echo "[+] Baixando $capitulo..."
    nome_manga_url=$(cat $PASTA_MANGAS/union_links.txt | head -$n | tail -1 | sed -e 's/ /_/g' | sed -e 's/.jpg_/.jpg /g' | awk {'print $1'} | sed -e 's/\// /g' | awk '{print $5}' | sed -e 's/_/ /g')
    arquivo=$(cat $PASTA_MANGAS/union_links.txt | sed -e 's/ /_/g' | sed -e 's/.jpg_/.jpg /g' | head -$n | tail -1 | awk {'print $1'} | sed -e 's/\// /g' | awk '{print $7}' | sed -e 's/-_/- /g')    
    link_baixar=$(cat $PASTA_MANGAS/union_links.txt | sed -e 's/ /_/g' | sed -e 's/.jpg_/.jpg /g' | head -$n | tail -1 | awk {'print $1'} | sed -e 's/_/ /g' | sed -e 's/UnM /UnM_/g')
    wget -q "$link_baixar"
    mv ./"$(echo $capitulo | sed -e 's/_/ /g')" $PASTA_MANGAS/$nome_dir/$num_cap/$capitulo
    if [ $n -eq 1 ] ; then primeiro_cap=$capitulo ; fi
    n=$[n+1]
  done
  read -n 1 -p " :: Gostaria de ler o capítulo agora ? [S/N] : " escolha
  printf "\n"
  if [ "$escolha" == "s" ] || [ "$escolha" == "S" ] ; then
    viewnior ~/Documentos/unionmangas/$nome_dir/$num_cap/$primeiro_cap
  fi
  rm $PASTA_MANGAS/union_links.txt
}
function news() {
  curl -s http://unionmangas.net | grep "&nbsp;<a href" | sed -e "s/&nbsp;<a href=\"http:\/\/unionmangas.net\/leitor\///g" | sed -e 's/<\/a>//g' | sed -e 's/\">/ /g' | sed -e 's/                                / /g' | sed -e 's/\// /g' > $PASTA_MANGAS/union.txt
  quantidade=$1
  m=1 ; while [ $m -le $quantidade ] ; do
    printf $m > $PASTA_MANGAS/temp.txt
    printf p >> $PASTA_MANGAS/temp.txt
    valor=$(cat $PASTA_MANGAS/temp.txt) ; rm $PASTA_MANGAS/temp.txt
    nome_manga=$(sed -n $valor $PASTA_MANGAS/union.txt | awk {'print $1'} | sed -e 's/_/ /g')
    numero_cap=$(sed -n $valor $PASTA_MANGAS/union.txt | awk {'print $4'})
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
      rm $PASTA_MANGAS/config_name_list.txt
      rm $PASTA_MANGAS/config.txt
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
