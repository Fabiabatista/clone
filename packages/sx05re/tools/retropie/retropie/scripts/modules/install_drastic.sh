#!/bin/bash

source /retropie/scripts/env.sh
source "$scriptdir/scriptmodules/supplementary/esthemes.sh"
rp_registerAllModules

joy2keyStart

function drastic_confirm() {
     if dialog --yesno "This will install Drastic and enable it on Emulationstation, you will need to restart ES after this script ends, continue?"  22 76 >/dev/tty; then
		drastic_install
		dialog --msgbox "Drastic installation is done!, don't forget to install roms to /storage/roms/nds and restart Emulationstation!" 22 76 >/dev/tty 
      fi
 }

function drastic_install() {
LINK="https://github.com/Retro-Arena/binaries/raw/master/odroid-xu4/drastic.tar.gz"
ES_FOLDER="/storage/.emulationstation"
LINKDEST="$ES_FOLDER/scripts/drastic.tar.gz"
CFG="$ES_FOLDER/es_systems.cfg"
EXE="/usr/bin/emuelecRunEmu.sh DRASTIC"

mkdir -p "$ES_FOLDER/scripts/"

wget -O $LINKDEST $LINK
tar xvf $LINKDEST -C "$ES_FOLDER/scripts"
rm $LINKDEST

if grep -q '<name>nds</name>' "$CFG"
then
	echo 'Drastic is already setup in your es_systems.cfg file'
	echo 'deleting...nds from es_system.cfg'
	xmlstarlet ed -L -P -d "/systemList/system[name='nds']" $CFG	
fi

	echo 'Adding Drastic to systems list'
	xmlstarlet ed --omit-decl --inplace \
		-s '//systemList' -t elem -n 'system' \
		-s '//systemList/system[last()]' -t elem -n 'name' -v 'nds'\
		-s '//systemList/system[last()]' -t elem -n 'fullname' -v 'Nintendo DS'\
		-s '//systemList/system[last()]' -t elem -n 'path' -v '/storage/roms/nds'\
		-s '//systemList/system[last()]' -t elem -n 'extension' -v '.nds .zip .NDS .ZIP'\
		-s '//systemList/system[last()]' -t elem -n 'command' -v "$EXE %ROM%"\
		-s '//systemList/system[last()]' -t elem -n 'platform' -v 'nds'\
		-s '//systemList/system[last()]' -t elem -n 'theme' -v 'nds'\
		$CFG

read -d '' content <<EOF
#!/bin/sh

cd /storage/.emulationstation/scripts/drastic/
./drastic "\$1"

EOF
echo "$content" > $ES_FOLDER/scripts/drastic.sh
chmod +x $ES_FOLDER/scripts/drastic.sh

echo "Done, restart ES"

}

drastic_confirm
