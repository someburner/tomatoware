#!/bin/bash

cd src

for d in $(ls); do
	[[ "$d" == "toolchain" ]] && echo "skipping toolchain dir.." && continue;
	cd $d && ls *.tar*
	if [[ $? -eq 0 ]]; then
		for subd in $(ls); do
			[[ -d $subd ]] && echo "Removing \"$subd\"" && rm -rf $subd;
		done
	fi
	cd ..
done

#.tar.gz
