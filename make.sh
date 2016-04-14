#!/bin/bash

##############################################

if [ "$1" == -h ] || [ "$1" == --help ]; then
	echo "Parameter 1: target system (1-34)"
	echo "Parameter 2: kernel (1-5)"
	echo "Parameter 3: debug (y/N)"
	echo "Parameter 4: player (1-2)"
	echo "Parameter 5: Media Framework (1-4)"
	echo "Parameter 6: External LCD support (1-2)"
	echo "Parameter 7: Image (Enigma=1/2 Neutrino=3/4 (1-4)"
	exit
fi

##############################################

echo "
  _______                     _____              _     _         _
 |__   __|                   |  __ \            | |   | |       | |
    | | ___  __ _ _ __ ___   | |  | |_   _  ____| | __| |_  __ _| | ___ ___
    | |/ _ \/ _\` | '_ \` _ \  | |  | | | | |/  __| |/ /| __|/ _\` | |/ _ | __|
    | |  __/ (_| | | | | | | | |__| | |_| |  (__|   < | |_| (_| | |  __|__ \\
    |_|\___|\__,_|_| |_| |_| |_____/ \__,_|\____|_|\_\ \__|\__,_|_|\___|___/
"

##############################################

CURDIR=`pwd`
echo -ne "\n    Checking the .elf files in $CURDIR/root/boot..."
set='audio_7100 audio_7105 audio_7111 video_7100 video_7105 video_7109 video_7111'
for i in $set;
do
  if [ ! -e $CURDIR/root/boot/$i.elf ]; then
    echo -e "\n    ERROR: One or more .elf files are missing in ./root/boot!"
    echo "           ($i.elf is one of them)"
    echo
    echo "    Correct this and retry."
    echo
    exit
  fi
done
echo " [OK]"
echo
echo

##############################################

case $1 in
	[1-9] | 1[0-9] | 2[0-9] | 3[0-9]) REPLY=$1;;
	*)
		echo "Target receivers:"
		echo "    1) Kathrein UFS-910"
		echo "    2) Kathrein UFS-912"
		echo "    3) Kathrein UFS-913"
		echo "    4) Kathrein UFS-922"
		echo "    5) Kathrein UFC-960"
		echo "    6) Topfield TF77X0 HDPVR"
		echo "    7) IPBOX55"
		echo "    8) IPBOX99"
		echo "    9) IPBOX9900"
		echo "   10) Cuberevo [ IPBOX 9000 ]"
		echo "   11) Cuberevo mini [ IPBOX 900 ]"
		echo "   12) Cuberevo mini2 [ IPBOX 910 ]"
		echo "   13) Cuberevo 250 [ IPBOX 91 ]"
		echo "   14) Cuberevo 9500HD [ 7000HD ]"
		echo "   15) Cuberevo 2000HD"
		echo "   16) Cuberevo mini_fta [ 200HD ]"
		echo "   17) Xsarius Alpha [ Cuberevo 3000HD ]"
		echo "   18) Fortis HDbox [ Fortis FS9000/9200 ]"
		echo "   19) Octagon SF1008P [ Fortis HS9510 ]"
		echo "   20) Atevio AV7500 [ Fortis HS8200 ]"
		echo "   21) Atemio AM520"
		echo "   22) Atemio AM530"
		echo "   23) Fortis HS7110"
		echo "   24) Fortis HS7119"
		echo "   25) Fortis HS7810A"
		echo "   26) Fortis HS7819"
		echo "   27) Edision Argus VIP1 v1 [ single tuner + 2 CI + 2 USB ]"
		echo "   28) SpiderBox HL-101"
		echo "   29) SPARK"
		echo "   30) SPARK7162"
		echo "   31) B4Team ADB 5800S"
		echo "   32) Vitamin HD5000"
		echo "   33) SagemCom 88 series"
		echo "   34) Ferguson Ariva @Link 200"
		read -p "Select target (1-34)? ";;
esac

case "$REPLY" in
	 1) TARGET="ufs910";;
	 2) TARGET="ufs912";;
	 3) TARGET="ufs913";;
	 4) TARGET="ufs922";;
	 5) TARGET="ufc960";;
	 6) TARGET="tf7700";;
	 7) TARGET="ipbox55";;
	 8) TARGET="ipbox99";;
	 9) TARGET="ipbox9900";;
	10) TARGET="cuberevo";;
	11) TARGET="cuberevo_mini";;
	12) TARGET="cuberevo_mini2";;
	13) TARGET="cuberevo_250hd";;
	14) TARGET="cuberevo_9500hd";;
	15) TARGET="cuberevo_2000hd";;
	16) TARGET="cuberevo_mini_fta";;
	17) TARGET="cuberevo_3000hd";;
	18) TARGET="fortis_hdbox";;
	19) TARGET="octagon1008";;
	20) TARGET="atevio7500";;
	21) TARGET="atemio520";;
	22) TARGET="atemio530";;
	23) TARGET="hs7110";;
	24) TARGET="hs7119";;
	25) TARGET="hs7810a";;
	26) TARGET="hs7819";;
	27) TARGET="hl101";;
	28) TARGET="hl101";;
	29) TARGET="spark";;
	30) TARGET="spark7162";;
	31) TARGET="adb_box";;
	32) TARGET="vitamin_hd5000";;
	33) TARGET="sagemcom88";;
	34) TARGET="arivalink200";;
	 *) TARGET="atevio7500";;
esac
echo "BOXTYPE=$TARGET" > config

##############################################

case $2 in
	[1-5]) REPLY=$2;;
	*)	echo -e "\nKernel:"
		echo "   1) STM 24 P0209"
		echo "   2) STM 24 P0211"
		echo "   3) STM 24 P0214"
		echo "   4) STM 24 P0215"
		echo "   5) STM 24 P0217 (recommended)"
		read -p "Select kernel (1-5)? ";;
esac

case "$REPLY" in
	1)  KERNEL="p0209";;
	2)  KERNEL="p0211";;
	3)  KERNEL="p0214";;
	4)  KERNEL="p0215";;
	5)  KERNEL="p0217";;
	*)  KERNEL="p0217";;
esac
echo "KERNEL=$KERNEL" >> config

##############################################

echo -e "\nKernel debug:"
if [ "$3" ]; then
	REPLY="$3"
else
	REPLY=N
	read -p "   Activate debug (y/N)? "
fi
[ "$REPLY" == "y" -o "$REPLY" == "Y" ] && echo "KERNELDEBUG=debug" >> config

##############################################

case $4 in
	[1-2]) REPLY=$4;;
	*)	echo -e "\nPlayer:"
		echo "   1) Player 191 (stmfb-3.1_stm24_0102)"
		echo "   2) Player 191 (stmfb-3.1_stm24_0104, recommended)"
		read -p "Select player (1-2)? ";;
esac

case "$REPLY" in
	1) 	echo "PLAYER=player191" >> config
		echo "MULTICOM=multicom324" >> config
		cd ../driver/include/
		if [ -L player2 ]; then
			rm player2
		fi

		if [ -L stmfb ]; then
			rm stmfb
		fi

		if [ -L multicom ]; then
			rm multicom
		fi

		ln -s player2_191 player2
		ln -s stmfb-3.1_stm24_0102 stmfb
		ln -s ../multicom-3.2.4/include multicom
		cd - &>/dev/null

		cd ../driver/
		if [ -L player2 ]; then
			rm player2
		fi

		if [ -L multicom ]; then
			rm multicom
		fi

		ln -s player2_191 player2
		ln -s multicom-3.2.4 multicom
		echo "export CONFIG_PLAYER_191=y" >> .config
		echo "export CONFIG_MULTICOM324=y" >> .config
		cd - &>/dev/null

		cd ../driver/stgfb
		if [ -L stmfb ]; then
			rm stmfb
		fi
		ln -s stmfb-3.1_stm24_0102 stmfb
		cd - &>/dev/null
	;;
	2) 	echo "PLAYER=player191" >> config
		echo "MULTICOM=multicom324" >> config
		cd ../driver/include/
		if [ -L player2 ]; then
			rm player2
		fi

		if [ -L stmfb ]; then
			rm stmfb
		fi

		if [ -L multicom ]; then
			rm multicom
		fi

		ln -s player2_191 player2
		ln -s stmfb-3.1_stm24_0104 stmfb
		ln -s ../multicom-3.2.4/include multicom
		cd - &>/dev/null

		cd ../driver/
		if [ -L player2 ]; then
			rm player2
		fi

		if [ -L multicom ]; then
			rm multicom
		fi

		ln -s player2_191 player2
		ln -s multicom-3.2.4 multicom
		echo "export CONFIG_PLAYER_191=y" >> .config
		echo "export CONFIG_MULTICOM324=y" >> .config
		cd - &>/dev/null

		cd ../driver/stgfb
		if [ -L stmfb ]; then
			rm stmfb
		fi
		ln -s stmfb-3.1_stm24_0104 stmfb
		cd - &>/dev/null
	;;
	*) PLAYER="--enable-player191 --enable-multicom324";;
esac

##############################################

case $5 in
	[1-4]) REPLY=$5;;
	*)	echo -e "\nMedia Framework:"
		echo "   1) eplayer3"
		echo "   2) gstreamer"
		echo "   3) use built-in (required for Neutrino)"
		echo "   4) gstreamer+eplayer3 (recommended for OpenPLi)"
		read -p "Select media framework (1-4)? ";;
esac

case "$REPLY" in
	1) MEDIAFW="eplayer3";;
	2) MEDIAFW="gstreamer";;
	3) MEDIAFW="buildinplayer";;
	4) MEDIAFW="gst-eplayer3";;
	*) MEDIAFW="buildinplayer";;
esac
echo "MEDIAFW=$MEDIAFW" >> config

##############################################

case $6 in
	[1-2]) REPLY=$6;;
	*)	echo -e "\nExternal LCD support:"
		echo "   1) No external LCD"
		echo "   2) graphlcd for external LCD"
		read -p "Select external LCD support (1-2)? ";;
esac

case "$REPLY" in
	1) EXTERNAL_LCD="";;
	2) EXTERNAL_LCD="externallcd";;
	*) EXTERNAL_LCD="";;
esac
echo "EXTERNAL_LCD=$EXTERNAL_LCD" >> config
##############################################

case $7 in
	[1-4]) REPLY=$7;;
	*)	echo -e "\nWhich Image do you want to build:"
		echo "   1) Enigma2"
		echo "   2) Enigma2 (includes WLAN drivers)"
		echo "   3) Neutrino"
		echo "   4) Neutrino (includes WLAN drivers)"
		read -p "Select Image to build (1-5)? ";;
esac

case "$REPLY" in
	1) IMAGE="enigma2";;
	2) IMAGE="enigma2-wlandriver";;
	3) IMAGE="neutrino";;
	4) IMAGE="neutrino-wlandriver";;
	*) IMAGE="neutrino";;
esac
echo "IMAGE=$IMAGE" >> config

##############################################
echo " "
make printenv
echo " "
##############################################
echo "Your build environment is ready :-)"
echo "Your next step could be:"
case "$IMAGE" in
		neutrino*)
		echo "  make yaud-neutrino-mp-next"
		echo "  make yaud-neutrino-mp-cst-next"
		echo "  make yaud-neutrino-alpha"
		echo "  make yaud-neutrino-test"
		echo "  make yaud-neutrino-hd2";;
		enigma2*)
		echo "  make yaud-enigma2-pli-nightly";;
		*)
esac
echo " "
