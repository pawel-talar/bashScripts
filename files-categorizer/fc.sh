#!/bin/bash

set -u 
set -e

readonly STARTADDRESS=$(pwd)
readonly OTHERS="other"


declare -A TYPE_TO_DIR
TYPE_TO_DIR["zip"]="archives"
TYPE_TO_DIR["image/"]="images"
TYPE_TO_DIR["video/"]="videos"
TYPE_TO_DIR["pdf"]="texts"
TYPE_TO_DIR["texts/"]="texts"
TYPE_TO_DIR["audio/"]="audios"
TYPE_TO_DIR["octet-stream"]="audios"


make_addres()
{	
	mime_type="$1"
	for pattern in "${!TYPE_TO_DIR[@]}"
	do
		if grep -q "${pattern}" <<< "${mime_type}"; then
			directory="${TYPE_TO_DIR[$pattern]}"
			echo "${STARTADDRESS}/${directory}"
			return 
		fi
	done
	echo "${STARTADDRESS}/${OTHERS}"
}

process_directory()
{
	name="$1"
	echo -n "${name} is a catalog! Sort files contain in $IT?[y/N] "
	read ANSWER
	if [[ $ANSWER == "Y" || $ANSWER == "y" ]]; then
		sort_files "$name"
	fi
}

process_file()
{
	name="$1"
	declare -a MIMETYPE=($(file -b -i -- "${name}"))
	addres="$(make_addres "${MIMETYPE[0]}")"
	mv -v -- "${name}" "${addres}"
}

sort_files()
{
	local_path="$1"
	if [[ ! -d $1 ]]; then
		echo "Catalog named '$1' doesn't exist!"
		exit 1
	fi		
	if [ $# != 1 ]; then
		echo "Number of arguments isn't equal 1, sort_files() require 1 argument"
		exit 2
	fi
	for IT in "${local_path}"/*; do
		echo $IT
		if [[ -d "${IT}" ]]; then
			process_directory "${IT}"
		elif [[ -f "${IT}" ]]; then
			process_file "${IT}"
		fi 
	done
}

main()
{
	sort_files "$1"
}

readonly ROOTCAT="${HOME}/Pobrane"
main "${ROOTCAT}"