#/bin/bash

# read params
while getopts p:c: flag
do
    case "${flag}" in
        p) PROPS_FILE=${OPTARG};;
        c) CONFIRM=${OPTARG};;
    esac
done

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

echo "=== Enabling service for "${EAP_HOME}

SUDOER=$(sudo -v)
if [[ -z $SUDOER"" ]]; 
then 
    # echo "You are a sudoer !"; 

    JBOSS_SVC=$(sudo service --status-all | grep jboss-eap | awk '{print $1}')
    JBOSS_PID=$(sudo service --status-all | grep jboss-eap | grep pid | awk '{print $5}' | sed 's/)//g' )
    if [[ ! -z $JBOSS_PID"" ]]; 
    then 
        echo "Killing previous process with pid "$JBOSS_PID; 
        sudo kill -9 $JBOSS_PID
    fi

    sudo cp ${EAP_HOME}/bin/init.d/jboss-eap.conf /etc/default
    sudo cp ${EAP_HOME}/bin/init.d/jboss-eap-rhel.sh /etc/init.d
    sudo chmod +x /etc/init.d/jboss-eap-rhel.sh
    sudo restorecon /etc/init.d/jboss-eap-rhel.sh
    sudo chkconfig --add jboss-eap-rhel.sh
    sudo chkconfig jboss-eap-rhel.sh on
    sudo chkconfig --list jboss-eap-rhel.sh
    sudo service jboss-eap-rhel restart
else
    echo "You are NOT a sudoer, ask your admin to run this command !"; 
    exit
fi

