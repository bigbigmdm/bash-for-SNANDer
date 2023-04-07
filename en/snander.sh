#!/bin/bash
mode=""
t1="24Cxx - Two-Wire Serial EEPROM"
t2="93Cxx - MICROWIRE Serial EEPROM"
ch_dev=$(lsusb | grep "1a86:" -o)
echo $ch_dev
if [[ "$ch_dev" == "1a86:" ]]
then
epromtype=$(zenity --height=300 --width=300 --list --radiolist --text \
"Please select the EEPROM type:" --column="Set" --column="EEPROM type"\
 FALSE "24Cxx - Two-Wire Serial EEPROM"\
 FALSE "93Cxx - MICROWIRE Serial EEPROM"\
 FALSE "25Cxx - NAND FLASH EEPROM"\
 FALSE "25Qxx - NOR FLASH EEPROM"\ )
 if [ -n "$epromtype" ]
 then
     if [[ "$epromtype" == "24Cxx - Two-Wire Serial EEPROM" ]]
     then
     echo "24Cxx selected"
     eeprom_model=$(zenity --height=320 --width=320 --list --radiolist --text \
"24Cxx - Two-Wire Serial EEPROM:" --column="Set" --column="EEPROM model"\
 TRUE "24c01"\
 FALSE "24c02"\
 FALSE "24c04"\
 FALSE "24c16"\
 FALSE "24c32"\
 FALSE "24c64"\
 FALSE "24c128"\
 FALSE "24c256"\
 FALSE "24c512"\ )
     fi
     if [[ "$epromtype" == "93Cxx - MICROWIRE Serial EEPROM" ]]
     then
     echo "93Cxx selected"
     eeprom_model=$(zenity --height=320 --width=320 --list --radiolist --text \
"93Cxx - Microwire EEPROM:" --column="Set" --column="IC model"\
 TRUE "93c06"\
 FALSE "93c16"\
 FALSE "93c46"\
 FALSE "93c56"\
 FALSE "93c66"\
 FALSE "93c76"\
 FALSE "93c86"\
 FALSE "93c96"\ )
     fi
     if [ "$epromtype" == "25Cxx - NAND FLASH EEPROM" ] || [ "$epromtype" == "25Qxx - NOR FLASH EEPROM" ]
     then
        echo "NOR or NAND selected"
        manufacture='Manufacture: '
        info=$(SNANDer -i)
        if [[ $info == *"id: 7f"* ]]
          then
          zenity --warning \
          --text="Please insert the 1.8 V adapter!"
          fi
        man_code=$(echo "$info" | grep 'spi device id:')
        dev_vcc=$(echo "$info" | grep 'VCC:')
        if [[ $man_code == *"spi device id:"* ]] 
          then
             if [[ $man_code == *"id: 01"* ]]; then man_name="SPANSION"; fi
             if [[ $man_code == *"id: 0b"* ]]; then man_name="XTX"; fi
             if [[ $man_code == *"id: 1c"* ]]; then man_name="Eon"; fi
             if [[ $man_code == *"id: 1f"* ]]; then man_name="Atmel"; fi
             if [[ $man_code == *"id: 20"* ]]; then man_name="Micron"; fi
             if [[ $man_code == *"id: 5e"* ]]; then man_name="Zbit"; fi
             if [[ $man_code == *"id: 68"* ]]; then man_name="Boya"; fi
             if [[ $man_code == *"id: 7f"* ]]; then man_name="ISSI"; fi
             if [[ $man_code == *"id: 85"* ]]; then man_name="PUYA"; fi
             if [[ $man_code == *"id: 9d"* ]]; then man_name="ISSI"; fi
             if [[ $man_code == *"id: a1"* ]]; then man_name="Fudan"; fi
             if [[ $man_code == *"id: ba"* ]]; then man_name="Zetta"; fi
             if [[ $man_code == *"id: c2"* ]]; then man_name="MXIC (Macronix)"; fi
             if [[ $man_code == *"id: c8"* ]]; then man_name="GigaDevice"; fi
             if [[ $man_code == *"id: e0"* ]]; then man_name="PARAGON"; fi
             if [[ $man_code == *"id: ef"* ]]; then man_name="Winbond"; fi   
             if [[ $man_code == *"id: f8"* ]]; then man_name="Fidelix"; fi   
          else  manufacture="Manufacture is not found."
       fi;
       manufacture="${manufacture}<b>${man_name}</b>"
       info=$(echo "$info" | grep 'Flash:')
       rufirst="Found chip "
       rusecond="Size: "
       ruvcc="Pupply voltage:"
       dev_vcc=${dev_vcc/'VCC:'/"$ruvcc <b>"}
       ruinfo=${info/'Detected '/"\n$rufirst"}
       ruinfo=${ruinfo/'Flash Size:'/"\n$rusecond"}
       ruinfo=${ruinfo/'[93m'/"<b>"}
       ruinfo=${ruinfo/'[93m'/"<b>"}
       ruinfo=${ruinfo/'[0m'/"</b>"}
       ruinfo=${ruinfo/'[0m'/"</b>"}
       ruinfo="${ruinfo} \n${manufacture}\n${dev_vcc}</b>"   
     fi
     action_type=$(zenity --height=340 --width=320 --list --radiolist --text \
"Please select the action:" --column="Set" --column="Action"\
 TRUE "Reading"\
 FALSE "Writing"\
 FALSE "Writing and verifying"\
 FALSE "Erasing" )
     if [[ "$action_type" == "Записать/проверить" ]] ; then mode="-v"; else mode=""; fi
     if [[ "$action_type" == "Reading" ]]
     then
     zenity --warning --width=320 \
--text="Please select the storing directory"
     filepath=$(zenity --file-selection --directory)
     filename=$(zenity --entry \
--title="Enter the name of file" \
--text="Name of file to saving:" \
--entry-text "eeprom.bin")
        if [ -n "$eeprom_model" ]
        then
        SNANDer -E$eeprom_model -r $filepath/$filename | tee >(zenity --width=200 --height=100 \
  				    --title="Reading" --progress \
			            --pulsate --text="Please wait..." \
                                    --no-cancel --auto-close \
                                    --percentage=10)
        else
        SNANDer -r $filepath/$filename | tee >(zenity --width=200 --height=100 \
  				    --title="Reading" --progress \
			            --pulsate --text="Please wait" \
                                    --no-cancel --auto-close \
                                    --percentage=10)
        fi
     fi
     if [ "$action_type" == "Writing" ] || [ "$action_type" == "Writing and verifying" ]
     then
     zenity --warning \
--text="Please select the file to write to the EEPROM"
     filename=$(zenity --file-selection)     
        if [ -n "$eeprom_model" ]
        then
        SNANDer -E$eeprom_model -w $filename $mode | tee >(zenity --width=320 --height=100 \
  				    --title="Writing" --progress \
			            --pulsate --text="Please wait..." \
                                    --no-cancel --auto-close \
                                    --percentage=10)
        else
        SNANDer -w $filename $mode | tee >(zenity --width=320 --height=100 \
  				    --title="Writing" --progress \
			            --pulsate --text="Please wait..." \
                                    --no-cancel --auto-close \
                                    --percentage=10)
        fi
     fi
     if [[ "$action_type" == "Erasing" ]]
     then   
        if [ -n "$eeprom_model" ]
        then
        SNANDer -E$eeprom_model -e | tee >(zenity --width=200 --height=100 \
  				    --title="Erasing" --progress \
			            --pulsate --text="Please wait..." \
                                    --no-cancel --auto-close \
                                    --percentage=10)
        else
        SNANDer -e | tee >(zenity --width=200 --height=100 \
  				    --title="Erasing" --progress \
			            --pulsate --text="Please wait..." \
                                    --no-cancel --auto-close \
                                    --percentage=10)
        fi
     fi
     zenity --warning \
--text="Success"
 else 
 echo "The chip is not selected!"
 zenity --error \
--text="The chip is not selected!"
 fi   
else
 zenity --error \
--text="The device CH341A is not found!"
 fi
