#!/bin/bash
t1="24Cxx - Two-Wire Serial EEPROM"
t2="93Cxx - MICROWIRE Serial EEPROM"
ch_dev=$(lsusb | grep "1a86:" -o)
echo $ch_dev
if [[ "$ch_dev" == "1a86:" ]]
then
epromtype=$(zenity --height=320 --width=320 --list --radiolist --text \
"Выберите тип EEPROM:" --column="Set" --column="Тип микросхемы"\
 FALSE "24Cxx - Two-Wire Serial EEPROM"\
 FALSE "93Cxx - MICROWIRE Serial EEPROM"\
 FALSE "25Cxx - NAND FLASH EEPROM"\
 FALSE "25Qxx - NOR FLASH EEPROM"\ )
 if [ -n "$epromtype" ]
 then
     if [[ "$epromtype" == "24Cxx - Two-Wire Serial EEPROM" ]]
     then
     eeprom_model=$(zenity --height=330 --width=320 --list --radiolist --text \
"24Cxx - Two-Wire Serial EEPROM:" --column="Set" --column="Модель микросхемы"\
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
     eeprom_model=$(zenity --height=320 --width=320 --list --radiolist --text \
"93Cxx - Microwire EEPROM:" --column="Set" --column="Модель микросхемы"\
 TRUE "93c06"\
 FALSE "93c16"\
 FALSE "93c46"\
 FALSE "93c56"\
 FALSE "93c66"\
 FALSE "93c76"\
 FALSE "93c86"\
 FALSE "93c96"\ )
     fi
     action_type=$(zenity --height=340 --width=320 --list --radiolist --text \
"Выберите действие:" --column="Set" --column="Действие"\
 TRUE "Считать"\
 FALSE "Записать"\
 FALSE "Стереть" )
     if [[ "$action_type" == "Считать" ]]
     then
     zenity --warning --width=320 \
--text="Выберите каталог для сохранения файла"
     filepath=$(zenity --file-selection --directory)
     filename=$(zenity --entry \
--title="Введите имя файла" \
--text="Имя файла для сохранения:" \
--entry-text "eeprom.bin")
        if [ -n "$eeprom_model" ]
        then        
        SNANDer -E$eeprom_model -r $filepath/$filename | tee >(zenity --width=200 --height=100 \
  				    --title="Считывание" --progress \
			            --pulsate --text="Подождите, процесс выполняется..." \
                                    --auto-kill --auto-close \
                                    --percentage=10)
        else
        SNANDer -r $filepath/$filename | tee >(zenity --width=200 --height=100 \
  				    --title="Считывание" --progress \
			            --pulsate --text="Подождите, процесс выполняется..." \
                                    --auto-kill --auto-close \
                                    --percentage=10)
        fi
     fi
     if [[ "$action_type" == "Записать" ]]
     then
     zenity --warning \
--text="Выберите файл для записи микросхемы"
     filename=$(zenity --file-selection)     
        if [ -n "$eeprom_model" ]
        then
        SNANDer -E$eeprom_model -w $filename | tee >(zenity --width=200 --height=100 \
  				    --title="Запись" --progress \
			            --pulsate --text="Подождите, процесс выполняется..." \
                                    --auto-kill --auto-close \
                                    --percentage=10)
        else
        SNANDer -w $filename | tee >(zenity --width=200 --height=100 \
  				    --title="Запись" --progress \
			            --pulsate --text="Подождите, процесс выполняется..." \
                                    --auto-kill --auto-close \
                                    --percentage=10)
        fi
     fi
     if [[ "$action_type" == "Стереть" ]]
     then   
        if [ -n "$eeprom_model" ]
        then
        SNANDer -E$eeprom_model -e | tee >(zenity --width=200 --height=100 \
  				    --title="Стирание" --progress \
			            --pulsate --text="Подождите, процесс выполняется..." \
                                    --auto-kill --auto-close \
                                    --percentage=10)
        else
        SNANDer -e | tee >(zenity --width=200 --height=100 \
  				    --title="Стирание" --progress \
			            --pulsate --text="Подождите, процесс выполняется..." \
                                    --auto-kill --auto-close \
                                    --percentage=10)
        fi
     fi
     zenity --warning \
--text="Готово" \
--icon-name='applications-electronics'
 else 
 echo "Микросхема не выбрана"
 zenity --error \
--text="Микросхема не выбрана"
 fi
 else
 zenity --error \
--text="Программатор CH341A не подключен!"
 fi

