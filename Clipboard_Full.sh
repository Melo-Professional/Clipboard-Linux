#!/bin/bash

# Clipboard 2.2 - fev-2021 por Melo
# Script para copiar frases para a área de transferência
# Necessário xsel: sudo apt install xsel
# Crie uma pasta chamada "Mensagens" contendo vários arquivos com suas mensagens pré-definidas. Ex: 01.txt, 02.txt, 03.txt.



#Testando a existência do pacote xsel
if ! xsel --version >/dev/null 2>&1; then
 while [ "$ok" == "" ]; do
 PASSWD=$(zenity --entry --hide-text --title "Clipboard" --text "Instalando pacote xsel... \nDigite a senha de root")
   if [[ $? -eq 1 ]]; then
   exit
   else
      if ! echo -e $PASSWD | sudo -S sudo pwd >/dev/null 2>&1; then
      zenity --info --title "Clipboard" --no-wrap --text="Senha errada..." --timeout=2 &
      else
      zenity --info --title "Clipboard" --no-wrap --text="Instalando pacote xsel\n Aguarde..." --timeout=10 &
      ok=1
      fi
   fi
done
if ! echo -e $PASSWD | sudo -S sudo apt-get install -y xsel >/dev/null 2>&1; then
zenity --info --title "Clipboard" --no-wrap --text="Não foi possível instalar xsel. \nVerifique sua conexão com a internet \nInstale manualmente: (via terminal sudo apt-get install -y xsel)" &
exit
fi
fi





#Procurando e indexando as mensagens
for filename in ./Mensagens/*.txt; do
    [ -e "$filename" ] || continue
simplename=$(basename -- "$filename")
extension="${simplename##*.}"
simplename="${simplename%.*}"
myArray+=($(echo $simplename))
myArray+=($(cat $filename | tr -d '\r' | tr -d '\n' | tr ' ' '_' | head -c200))
done
if [ -z "$myArray" ]; then
zenity --info --no-wrap --title "Clipboard" --text="Mensagens não encontradas!\nCrie uma pasta chamada "Mensagens" contendo vários arquivos com suas mensagens pré-definidas.\nEx: 01.txt, 02.txt, 03.txt." &
exit
fi


#Calculando tamanho da interface
TOPMARGIN=27
RIGHTMARGIN=10
SCREEN_WIDTH=$(xwininfo -root | awk '$1=="Width:" {print $2}')
SCREEN_HEIGHT=$(xwininfo -root | awk '$1=="Height:" {print $2}')
W=$(( $SCREEN_WIDTH / 2 - $RIGHTMARGIN ))
H=$(( $SCREEN_HEIGHT - 2 * $TOPMARGIN ))



#Abrindo interface
while [ "$res" == "" ]; do
res="$(zenity --list --print-column="1" --width=$W --height=$H --text="$resumido\n\nSelecione a mensagem desejada" --title "Clipboard" --ok-label="Copiar" --cancel-label="Sair" --column "arq" --column "conteúdo" "${myArray[@]}" 2>/dev/null)"
if [[ $? -eq 1 ]]; then exit; else
    if ler=$(cat ./Mensagens/$res.txt);then
    printf '%s' "$ler" | xsel -i -b
    resumido="Copiado: "
    resumido+=$(cat ./Mensagens/$res.txt | tr -d '\r'  | tr '\n' '_' | head -c100)
    resumido+=" ...\n\n"
    else
    zenity --info --title "Clipboard" --text="Não encontrado!"
    unset resumido
    fi
fi
unset res
done
