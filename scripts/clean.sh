#!/bin/bash

TOP=$(pwd)

## Remove extracted directories
cd src
for d in $(ls); do
	[[ "$d" == "toolchain" ]] && printf "\n\t SKIP: toolchain\n\n" && continue;
	cd $d; _cd_ok=$?;
	if [[ $_cd_ok -eq 0 ]]; then
		ls *.tar*
		if [[ $? -eq 0 ]]; then
			for subd in $(ls); do
				if [[ -d $subd ]]; then echo "Removing \"$subd\"";  rm -rf $subd; fi;
			done
		fi
		cd ..
	fi
done

cd $TOP

## Remove top-level dotfiles
for dot in $(ls src/*/.[^.]*); do
	[[ "$dot"  == "src/vim/.vimrc" ]] && printf "\n\t SKIP: .vimrc\n\n" && continue;
	echo "Clearing \"$dot\"";
	rm -f $dot;
done


### end
