#!/bin/bash

# VARIABLES SECTION

source /app/bin/global.sh # Grab global variables
source /app/libexec/functions.sh # Source global functions

# Config files for emulators with single config files

raconf="/var/config/retroarch/retroarch.cfg"
ra_core_conf="/var/config/retroarch/retroarch-core-options.cfg"
citraconf="/var/config/citra-emu/qt-config.ini"
melondsconf="/var/config/melonDS/melonDS.ini"
rpcs3conf="/var/config/rpcs3/config.yml"
yuzuconf="/var/config/yuzu/qt-config.ini"

# Dolphin config files

dolphinconf="/var/config/dolphin-emu/Dolphin.ini"
dolphingcpadconf="/var/config/dolphin-emu/GCPadNew.ini"
dolphingfxconf="/var/config/dolphin-emu/GFX.ini"
dolphinhkconf="/var/config/dolphin-emu/Hotkeys.ini"
dolphinqtconf="/var/config/dolphin-emu/Qt.ini"

# PCSX2 config files

pcsx2conf="/var/config/PCSX2/inis/GS.ini"
pcsx2uiconf="/var/config/PCSX2/inis/PCSX2_ui.ini"
pcsx2vmconf="/var/config/PCSX2/inis/PCSX2_vm.ini"


# FUNCTION SECTION

browse() {
# Function for browsing directories, sets directory selected to variable $target for use in other functions

path_selected=false

while [ $path_selected == false ]
    do
        target="$(zenity --file-selection --title="Choose target location to $action" --directory)"  
        echo "Path chosen: $target, answer=$?"
        zenity --question --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --title "RetroDECK" \
        --cancel-label="No" \
        --ok-label "Yes" \
        --text="Your new directory will be:\n\n$target\n\nis that ok?"
        if [ $? == 0 ] #yes
        then
            path_selected == true
            break
        else
            zenity --question --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" --title "RetroDECK" --cancel-label="No" --ok-label "Yes" --text="Do you want to quit?"
            if [ $? == 0 ] # yes, quit
            then
                target=
                exit 0
            fi
        fi
    done
}

move() {

}

edit_setting() {
# Function for editing settings
# USAGE: $(edit_setting $setting_name $new_setting_value $system) (needed as different systems use different config file syntaxes)


}

get_setting_value() {
# Function for getting the current value of a setting from a config file
# USAGE: $(get_setting_value $setting_name $system) (needed as different systems use different config file syntaxes)



case $2 in

    "retrodeck" )
    ;;
    
    "retroarch" )
    echo $(grep $2 $raconf | grep -o -P "(?<=$2 = \").*(?=\")")
    ;;

    "retroarch-core-configs" )
    ;;

    "dolphin" )
    ;;

    "duckstation" )
    ;;

    "pcsx2" )
    ;;

    "ppsspp" )
    ;;

    "rpcs3" )
    ;;

    "yuzu" )
    ;;
    
    "citra" )
    ;;

    "melonds" )
    ;;

    "xemu" )
    ;;

esac

}

# DIALOG SECTION

# Configurator Option Tree

# Welcome
#     - Move Directories
#       - Migrate ROM directory
#       - Migrate downloaded_media
#       - Migrate BIOS directory
#     - Change Emulator Options
#         - RetroArch
#           - Change Rewind Setting
#     - Add or Update Files
#       - Add specific cores
#       - Grab all missing cores
#       - Update all cores to nightly
#     - RetroAchivement login
#       - Login prompt
#     - Reset RetroDECK
#       - Reset RetroArch
#       - Reset Standalone Emulators
#       - Reset Tools
#       - Reset All

# Code for the menus should be put in reverse order, so functions for sub-menus exists before it is called by the parent menu

configurator_process_complete_dialog() {
    zenity --icon-name=net.retrodeck.retrodeck --info --no-wrap \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK Configurator Utility - Process Complete" \
    --text="The process of $1 is now complete.\n\nClick OK to return to the Main Menu"
    
    configurator_welcome_dialog
}

configurator_progress_bar_dialog() {

}

configurator_reset_dialog() {
    choice=$(zenity --list --title="RetroDECK Configurator Utility - Reset Options" --cancel-label="Back" \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --column="Choice" --column="Action" \
    "Reset RetroArch" "Reset RetroArch to default settings" \
    "Reset Standalones" "Reset standalone emulators to default settings" \
    "Reset Tools" "Reset Tools menu entries" \
    "Reset All" "Reset RetroDECK to default settings" )

    case $choice in

    "Reset RetroArch" )
        ra_init
        configurator_process_complete_dialog "resetting RetroArch"
        ;;

    "Reset Standalones" )
        standalones_init
        configurator_process_complete_dialog "resetting standalone emulators"
        ;;

    "Reset Tools" )
        tools_init
        configurator_process_complete_dialog "resetting the tools menu"
        ;;

    "Reset All" )
        zenity --icon-name=net.retrodeck.retrodeck --info --no-wrap \
        --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
        --title "RetroDECK Configurator Utility - Reset RetroDECK" \
        --text="You are resetting RetroDECK to its default state.\n\nAfter the process is complete you will need to exit RetroDECK and run it again."
        rm -f "$lockfile"
        configurator_process_complete_dialog "resetting RetroDECK"
        ;;

    "" ) # No selection made or Back button clicked
        configurator_welcome_dialog
        ;;
    
    esac
}

configurator_retroachivement_dialog() {
    login=$(zenity --forms --title="RetroDECK Configurator Utility - RetroAchievements Login" --cancel-label="Back" \
        --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
        --text="Enter your RetroAchievements Account details.\n\nBe aware that this tool cannot verify your login details.\nFor registration and more info visit\nhttps://retroachievements.org/\n" \
        --separator="=SEP=" \
        --add-entry="Username" \
        --add-password="Password")

    if [ $? == 1 ] # Cancel button clicked
    then
        configurator_welcome_dialog
    fi

    arrIN=(${login//=SEP=/ })
    user=${arrIN[0]}
    pass=${arrIN[1]}

    sed -i "s%cheevos_enable =.*%cheevos_enable = \"true\"%" $raconf
    sed -i "s%cheevos_username =.*%cheevos_username = \"$user\"%" $raconf
    sed -i "s%cheevos_password =.*%cheevos_password = \"$pass\"%" $raconf
}

configurator_update_dialog() {

}

configurator_power_user_changes_dialog() {
    zenity --title "RetroDECK Configurator Utility - Power User Options" --question --no-wrap --cancel-label="Back" \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --text="Making manual changes to an emulators configuration may create serious issues,\nand some settings may be overwitten during RetroDECK updates.\n\nplease continue only if you know what you're doing.\n\nDo you want to continue?"
    
    if [ $? == 1 ] # Cancel button clicked
    then
        configurator_options_dialog
    fi

    emulator="$(zenity --list \
    --title "RetroDECK Configurator Utility - Power User Options" --cancel-label="Back" \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --text="Which emulator do you want to configure?" \
    --hide-header \
    --column=emulator \
    "RetroArch" \
    "Citra" \
    "Dolphin" \
    "Duckstation" \
    "MelonDS" \
    "PCSX2-QT" \
    "PCSX2-Legacy" \
    "PPSSPP" \
    "RPCS3" \
    "XEMU" \
    "Yuzu")"

    case $emulator in

    "RetroArch" )
        retroarch
        ;;

    "Citra" )
        citra-qt
        ;;
    
    "Dolphin" )
        dolphin-emu
        ;;
    
    "Duckstation" )
        duckstation-qt
        ;;
    
    "MelonDS" )
        melonDS
        ;;
    
    "PCSX2-QT" )
        pcsx2-qt
        ;;
    
    "PCSX2-Legacy" )
        pcsx2
        ;;
    
    "PPSSPP" )
        PPSSPPSDL
        ;;
    
    "RPCS3" )
        rpcs3
        ;;
    
    "XEMU" )
        xemu
        ;;
    
    "Yuzu" )
        yuzu
        ;;
    
    "" ) # No selection made or Back button clicked
        configurator_options_dialog
        ;;

    esac
}

configurator_rewind_dialog() {
    zenity --question \
    --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --title "RetroDECK" \
    --text="Do you want to enable the rewind function in RetroArch cores?\n\nNOTE:\nThis may impact on performances expecially on the latest systems."

    if [ $? == 0 ] #yes, enable
    then
        sed -i 's%rewind_enable = .*%rewind_enable = "true"' $raconf
        zenity --info \
            --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
            --title "RetroDECK" \
            --text="Rewind enabled\!\nYou can check on Libretro docs to see which cores supports this function."
    else # no, disable
        sed -i 's%rewind_enable = .*%rewind_enable = "false"' $raconf
        zenity --info \
            --no-wrap --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
            --title "RetroDECK" \
            --text="Rewind disabled."
    fi
}

configurator_options_dialog() {
    choice=$(zenity --list --title="RetroDECK Configurator Utility - Change Options" --cancel-label="Back" \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --column="Choice" --column="Action" \
    "Enable-Disable Rewind" "Enable or disable Rewind function in RetroArch" \
    "Power User Changes" "Make changes directly in an emulator" )

    case $choice in

    "Enable-Disable Rewind" )
        configurator_rewind_dialog
        ;;

    "Power User Changes" )
        configurator_power_user_changes_dialog
        ;;

    "" ) # No selection made or Back button clicked
        configurator_welcome_dialog
        ;;
    
    esac
}

configurator_migration_dialog() {

}

configurator_welcome_dialog() {
    # Clear the variables
    target=
    setting=
    action=
    setting_value=

    choice=$(zenity --list --title="RetroDECK Configurator Utility" --cancel-label="Quit" \
    --window-icon="/app/share/icons/hicolor/scalable/apps/net.retrodeck.retrodeck.svg" \
    --column="Choice" --column="Action" \
    "Move Files" "Move files between internal/SD card or to custom locations" \
    "Change Options" "Adjust how RetroDECK behaves" \
    "Upgrade" "Upgrade parts of RetroDECK" \
    "RetroAchivements" "Log in to RetroAchievements" \
    "Reset" "Reset parts of RetroDECK" )

    case $choice in

    "Move Files" )
        configurator_migration_dialog
        ;;

    "Change Options" )
        configurator_options_dialog
        ;;

    "Upgrade" )
        configurator_update_dialog
        ;;

    "RetroAchivements" )
        configurator_retroachivement_dialog
        ;;

    "Reset" )
        configurator_reset_dialog
        ;;
    
    esac
}

# START THE CONFIGURATOR

configurator_welcome_dialog