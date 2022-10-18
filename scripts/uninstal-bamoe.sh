#/bin/bash


# read params
while getopts p:c: flag
do
    case "${flag}" in
        p) PROPS_FILE=${OPTARG};;
        c) CONFIRM=${OPTARG};;
    esac
done

CONFIRM=${CONFIRM:0:1}

if [[ -z ${PROPS_FILE}"" ]];
then
    # load default props file
    echo "Sourcing default properties file "
    . ./ibm-bamoe-1shot-install.properties
else
    if [[ -f ${PROPS_FILE} ]];
    then
        echo "Sourcing properties file "${PROPS_FILE}
        . ${PROPS_FILE}
    else
        echo "Error properties file "${PROPS_FILE}" not found !!!"
        exit
    fi
fi

function dumpEnvVars () {
    echo "============= ENV VARs ============="
    echo $EAP_NAME
    echo $EAP_MINOR_LVL
    echo $EAP_PATCH_LVL
    echo $EAP_EXPAND_FOLDER
    echo $BAMOE_BC_NAME
    echo $BAMOE_KS_NAME
    echo $INST_SOURCE_FOLDER
    echo $FOLDER_SHARED
    echo $BC_ADMIN_USER
    echo $BC_ADMIN_PWD
    echo $KIE_CTRL_USER
    echo $KIE_CTRL_PWD
    echo $INST_EAP_DIR
    echo $INST_SOURCE_EAP
    echo $INST_SOURCE_EAP_PATCH
    echo $INST_SOURCE_BC
    echo $INST_SOURCE_KS
    echo $EAP_HOME
    echo $INST_BASE_DIR
    echo "------------------------------------"
}

# dumpEnvVars

function uninstall() {
    # remove folder
    if [[ -d ${EAP_HOME} ]];
    then
        # remove service
        echo "Removing jboss-eap service ... "
        ./disableService.sh -p ${PROPS_FILE} -c y
        
        echo "Removing folder "${EAP_HOME}
        rm -fR ${EAP_HOME}
    fi
}

echo "=== Uninstalling "${EAP_HOME}
echo "    WARNING: this script will erase foder "${EAP_HOME}
echo ""

    if [[ $CONFIRM"" == "y" ]];
    then
        uninstall
    else 

        while true; do
            read -p "Do you really want to uninstall jboss-eap and erase the folder "${EAP_HOME}" ? [y/n] " yn
            case $yn in
                [Yy]* ) uninstall; break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi


