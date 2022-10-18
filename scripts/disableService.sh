#/bin/bash

CONFIRM="n"
# read params
while getopts p:c: flag
do
    case "${flag}" in
        p) PROPS_FILE=${OPTARG};;
        c) CONFIRM=${OPTARG};;
    esac
done

CONFIRM=$(echo ${CONFIRM} | awk '{print tolower($0)}')
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

function disable () {
    JBOSS_PID=$(sudo service --status-all | grep jboss-eap | grep pid | awk '{print $5}' | sed 's/)//g' )
    if [[ ! -z $JBOSS_PID"" ]]; 
    then 
        echo "Stopping previous jboss-eap process with pid "$JBOSS_PID;         
    fi

    sudo service jboss-eap-rhel stop
    sudo chkconfig --del jboss-eap-rhel.sh
    sudo rm --force /etc/init.d/jboss-eap-rhel.sh
    sudo rm --force /etc/default/jboss-eap.conf
}

echo "=== Disbling jboss-eap service"

SUDOER=$(sudo -v)
if [[ -z $SUDOER"" ]]; 
then 
    if [[ $CONFIRM"" == "y" ]];
    then
        disable
    else 

        while true; do
            read -p "Do you really want to disable jboss-eap service running in folder "${EAP_HOME}" ? [y/n] " yn
            case $yn in
                [Yy]* ) disable; break;;
                [Nn]* ) exit;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi

else
    echo "You are NOT a sudoer, ask your admin to run this command !"; 
    exit
fi

