#!/bin/bash


#title           :noticiaschile.sh
#description     :Este script funciona como motor de busqueda de noticias chilenas desde la terminal en unix.
#author		 :cristobalvch (github)
#date            :2024-01-18
#version         :0.1    
#usage		 :bash noticiaschile.sh
#==============================================================================


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


function ctrl_c(){
        echo -e "\n\n${redColour}[!] Saliendo...\n"
        exit 1
}
trap ctrl_c INT


#VARIABLES GLOBALES
biobiochile="https://www.biobiochile.cl/news-sitemap.xml"
latercera="https://www.latercera.com/arc/outboundfeeds/sitemap/?outputType=xml&from="
lacuarta="https://www.lacuarta.com/arc/outboundfeeds/sitemap/?outputType=xml&from="
elmostrador="https://www.elmostrador.cl/sitemap_news.xml"
publimetro="https://www.publimetro.cl/arc/outboundfeeds/sitemap-news-index/?outputType=xml"
lanacion="$(curl -s https://www.lanacion.cl/sitemap_index.xml | grep "post-sitemap" | awk -F'</?loc>' '{print $2}' | tail -n 1)"
lahora="https://lahora.cl/news-sitemap.xml"
elciudadano="https://www.elciudadano.com/news-sitemap.xml"
eldinamo="https://www.eldinamo.cl/news-sitemap.xml"
eldesconcierto="https://www.eldesconcierto.cl/sitemap_news.xml"
cooperativa="https://www.cooperativa.cl/noticias/sitemap_news.xml"
fayerwayer="https://www.fayerwayer.com/arc/outboundfeeds/sitemap-news-index/?outputType=xml"
meganoticias="https://www.meganoticias.cl/sitemaps/sitemap-news.xml"
cnnchile="https://www.cnnchile.com/sitemap_news.xml"

medios=("biobiochile" "latercera" "lacuarta" "elmostrador" "publimetro" "lanacion" "lahora" "elciudadano" "eldinamo" "eldesconcierto" "cooperativa" "fayerwayer" "meganoticias" "cnnchile")



XMLFOLDER="tmp/xml"
CSVFOLDER="tmp/csv"

MAXITER=400

#FUNCIONES DEL SCRIPT

#Funcion de ayuda
function helpPanel(){
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour} $0"
	echo -e "\t${purpleColour}v)${endColour}${grayColour} Ver ultimas noticias ${endColour}"
	echo -e "\t${purpleColour}f)${endColour}${grayColour} Filtrar por fecha (formato: yyyy-mm-dd)${endColour}"
        echo -e "\t${purpleColour}p)${endColour}${grayColour} Filtrar por palabra${endColour}"
        echo -e "\t${purpleColour}m)${endColour}${grayColour} Filtrar por medio digital${endColour}"
        echo -e "\t${purpleColour}u)${endColour}${grayColour} Actualizar ultimas noticias${endColour}"
        echo -e "\t${purpleColour}l)${endColour}${grayColour} Listar medios digitales disponibles${endColour}"
        echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar panel de ayuda${endColour}"
}


function listEditorials(){
	
	echo "\n"
	for element in ${medios[@]};do
		echo -e "\t${yellowColour}[+]${endColour}${grayColour} "$element"${endColour}"
	done

}


function iterateFiles(){
url=$1
filename=$2
	
	files=""
	tempUrl=""
	tempFileName=""
	for i in {0..300.100}
	do	
		files+="$XMLFOLDER/$filename$i.xml " 
		tempUrl="$url$i" &&
		tempFileName="$XMLFOLDER/$filename$i.xml" &&
		curl -s -o "$tempFileName" "$tempUrl" && 
		xmllint --format "$tempFileName" -o "$tempFileName"
	done
	cat $files > "$XMLFOLDER/$filename.xml"

	for file in $files
	do
		rm  $file
	done	
}

function formatData(){
	
	#biobiochile
	cat "$XMLFOLDER/biobiochile.xml" | grep -E '<loc>|<news:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|biobiochile,|' > "$CSVFOLDER/biobiochile.csv" &&
	
	#latercera
	 cat "$XMLFOLDER/latercera.xml" | grep -E '<loc>|<lastmod>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|latercera,|' > "$CSVFOLDER/latercera.csv" &&
	
	#elmostrador
	cat "$XMLFOLDER/elmostrador.xml" | grep -E '<loc>|<n:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|elmostrador,|' > "$CSVFOLDER/elmostrador.csv" &&
	
	#lacuarta
	cat "$XMLFOLDER/lacuarta.xml" | grep -E '<loc>|<lastmod>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|lacuarta,|' > "$CSVFOLDER/lacuarta.csv" &&

	#lanacion
	cat "$XMLFOLDER/lanacion.xml" | grep -E '<loc>|<lastmod>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}'  | sed 's|^|lanacion,|' > "$CSVFOLDER/lanacion.csv" &&

	#publimetro
	cat "$XMLFOLDER/publimetro.xml" | grep -E '<loc>|<news:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|publimetro,|' > "$CSVFOLDER/publimetro.csv" &&
	
	#lahora
	cat "$XMLFOLDER/lahora.xml" | grep -E '<loc>|<news:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|lahora,|' > "$CSVFOLDER/lahora.csv" &&
	
	#elciudadano
	cat "$XMLFOLDER/elciudadano.xml" | grep -E '<loc>|<news:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|elciudadano,|' > "$CSVFOLDER/elciudadano.csv" && 
	
	#eldimano
	cat "$XMLFOLDER/eldinamo.xml" | grep -E '<loc>|<news:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|eldinamo,|' > "$CSVFOLDER/eldinamo.csv" &&
	
	#eldesconcierto
	cat "$XMLFOLDER/eldesconcierto.xml" | grep -E '<loc>|<n:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|eldesconcierto,|' > "$CSVFOLDER/eldesconcierto.csv" &&

	#cooperativa
	cat  "$XMLFOLDER/cooperativa.xml" | grep -E '<loc>|<news:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|cooperativa,|'  > "$CSVFOLDER/cooperativa.csv" &&

	#cnnchile
	cat  "$XMLFOLDER/cnnchile.xml" | grep -E '<loc>|<n:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|cnnchile,|' > "$CSVFOLDER/cnnchile.csv" &&

	#fayerwayer
	cat  "$XMLFOLDER/fayerwayer.xml" | grep -E '<loc>|<news:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|fayerwayer,|'	> "$CSVFOLDER/fayerwayer.csv" &&		
	#meganoticias
	cat  "$XMLFOLDER/meganoticias.xml" | grep -E '<loc>|<news:publication_date>' | sed -n 'N;s/\n/,/p' | awk -F'[<>]' '{print $3 "," $7}' | sed 's|^|meganoticias,|' > "$CSVFOLDER/meganoticias.csv"

	#Consolidar
	echo "medio,url,fecha" > "tmp/noticias.csv" &&
	for element in ${medios[@]};do
		cat "$CSVFOLDER/$element.csv"  >> "tmp/noticias.csv"
	done	
}


function updateFiles(){

	if [ ! -d tmp ]; then
		mkdir -p tmp
	fi
	mkdir $XMLFOLDER
	mkdir $CSVFOLDER

        echo -e "\n\t${yellowColour}[+]${endColour}${grayColour} Actualizando ultimas noticias${endColour}"

        curl -s $biobiochile > "$XMLFOLDER/biobiochile.xml" &&

	curl -s $elmostrador > "$XMLFOLDER/elmostrador.xml" &&

	curl -s $publimetro > "$XMLFOLDER/publimetro.xml" &&
		xmllint --format "$XMLFOLDER/publimetro.xml" -o "$XMLFOLDER/publimetro.xml" &&
	
	curl -s $lanacion > "$XMLFOLDER/lanacion.xml" &&
	
	curl -s $lahora > "$XMLFOLDER/lahora.xml" &&
	
	curl -s $elciudadano > "$XMLFOLDER/elciudadano.xml" &&
	
	curl -s $eldinamo > "$XMLFOLDER/eldinamo.xml" &&
	
	curl -s $eldesconcierto > "$XMLFOLDER/eldesconcierto.xml" &&
	
	curl -s $cooperativa > "$XMLFOLDER/cooperativa.xml" &&
	
	curl -s -o "$XMLFOLDER/fayerwayer.xml" $fayerwayer  &&
		xmllint --format "$XMLFOLDER/fayerwayer.xml" -o "$XMLFOLDER/fayerwayer.xml"

	curl -s -o "$XMLFOLDER/meganoticias.xml" $meganoticias  &&
		xmllint --format "$XMLFOLDER/meganoticias.xml" -o "$XMLFOLDER/meganoticias.xml"
	
	curl -s $cnnchile > "$XMLFOLDER/cnnchile.xml" &&

	iterateFiles $latercera "latercera" &&
	
	iterateFiles $lacuarta "lacuarta" &&
	
	formatData 
	rm -rf $XMLFOLDER
	rm -rf $CSVFOLDER

        echo -e "\t${yellowColour}[+]${endColour}${grayColour} Noticias actualizadas${endColour}"
        	
}

function renderData(){

url=$(echo $1 | cut -d ',' -f 1)
date=$(echo $1 | cut -d ',' -f 2)

	# Extraer partes de la URL
	protocolo=$(echo "$url" | sed 's|\(.*://\).*|\1|')
	host=$(echo "$url" | sed 's|.*://\([^/]*\)/.*|\1|')
	ruta="$(echo "$url" | sed 's|.*://[^/]*/\(.*\)|\1|' | sed 's/-/ /g')"
	parametros=$(echo "$url" | sed 's|.*\?\(.*\)|\1|')

	# Mostrar partes con colores ANSI
	echo -e "\n${yellowColour}Url: $url${endColour}"
	echo -e "${greenColour}Medio: $host${endColour}"
	echo -e "${blueColour}Fecha: $date${endColour}"	
}

function viewNews()
{
news=$1

	IFS=$'\n'
	for linea in $news;do
		renderData $linea	
	done

}


#Indicadores para identificar los parametros
declare -i parameter_counter=0
declare -i parameter_date=0
declare -i parameter_word=0
declare -i parameter_medio=0

while getopts "vulhp:m:f:" arg; do
        case $arg in
		v) let parameter_counter+=1;;
		u) let parameter_counter+=2;;
                l) let parameter_counter+=3;;
                f) dateFilter=$OPTARG; let parameter_date=1;;
                p) wordFilter=$OPTARG; let parameter_word=1;;
                m) medioFilter=$OPTARG; let parameter_medio=1;;
                h) ;;
        esac
done


if [ $parameter_counter -eq 1 ]; then     

	news="$(awk -F ',' 'NR>1 {print $2 "," $3}' "tmp/noticias.csv")"
	

	if [ $parameter_word -eq 1 ]; then
		news="$(echo "$news" | grep $wordFilter)"
		
	fi
	if [ $parameter_medio -eq 1 ]; then		
		news="$(echo "$news" | grep $medioFilter)"
	fi
	if [ $parameter_date -eq 1 ]; then		
		news="$(echo "$news" | grep $dateFilter)"
	fi

	if [[ -z "$news" ]];then
		echo -e "\n${redColour}[!]: No se encontraron resultados$url${endColour}"
	else
		viewNews "$news"
	fi	

elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	listEditorials
else
        helpPanel
fi
