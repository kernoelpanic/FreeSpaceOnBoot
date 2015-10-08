#!/bin/bash
# Bash script that purges all installed kerneles which have
# a lower ABI number than the currently running base kernel. 
# This fixes an issue with Ubuntu 14.04 running with full-disk 
# encryption or where /boot volume fills up on regular basis. 

kernelver=$(uname -r | sed -r 's/-[a-z]+//')
kernelbase=$(echo ${kernelver} | cut -d'-' -f1)
kernelabi=$(echo ${kernelver} | cut -d'-' -f2)
otherkernels=$(dpkg -l linux-{image,headers}-"[0-9]*" | awk '/ii/{print $2}' | grep -ve ${kernelver})
rmkernels=""

echo "Current kernel version        : ${kernelver}"
echo "Current base kernel version   : ${kernelbase}"
echo "Current kernel ABI number     : ${kernelabi}"
echo "Additionaly installed kernels :"
#echo $otherkernels | sed 's/\ /\n/g'   #DBG
for kernel in $otherkernels; do
    baseversion=$(echo $kernel | cut -d'-' -f3)
    abiversion=$(echo $kernel | cut -d'-' -f4)
	#echo $abiversion #DBG
	echo -e "\t${kernel}"
	if [[ "${baseversion}" = "${kernelbase}" ]] && [[ $((abiversion)) -lt $((kernelabi)) ]]
	then
		#echo $kernel #DBG
		rmkernels="${rmkernels} ${kernel}"
	fi
done
echo "Kernel(s) that will be removed:"
echo ${rmkernels} | sed 's/\ /\n/g'  

read -e -p "Remove additional kernels? Type upper case YES: " -i "NO" CHOICE

if [[ "YES" = $CHOICE ]]; then
	sudo apt-get purge ${rmkernels}
else
	echo "Nothing to do ..."
fi
