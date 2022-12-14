#/bin/bash

CONFIG_SERVICE=""
REMOVE_TEMP=""
HEADLESS_MODE=false

# read params
while getopts p:r:s:h: flag
do
    case "${flag}" in
        p) PROPS_FILE=${OPTARG};;
        r) REMOVE_TEMP=${OPTARG};;
        s) CONFIG_SERVICE=${OPTARG};;
        h) HEADLESS_MODE=${OPTARG};;
    esac
done

REMOVE_TEMP=$(echo ${REMOVE_TEMP} | awk '{print tolower($0)}')
CONFIG_SERVICE=$(echo ${CONFIG_SERVICE} | awk '{print tolower($0)}')
HEADLESS_MODE=$(echo ${HEADLESS_MODE} | awk '{print tolower($0)}')

REMOVE_TEMP=${REMOVE_TEMP:0:1}
CONFIG_SERVICE=${CONFIG_SERVICE:0:1}

echo "=== Installing as user '"$USER"' in folder "${EAP_HOME}

# echo "Property file: ${PROPS_FILE}";
# echo "Remove temporary installation folder: ${REMOVE_TEMP}";
# echo "Configure service: ${CONFIG_SERVICE}";

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

function javaExists () {
    if ! command -v java &> /dev/null
    then
        echo "*** Error: java could not be found"
        echo "    run: sudo yum install java-11-openjdk"
        exit
    fi
}

function archiveExists() {
    if [ ! -f "${INST_SOURCE_EAP}" ]; then
        echo "*** Error: ${INST_SOURCE_EAP} doesn't exists"
        exit
    fi
    if [ ! -f "${INST_SOURCE_EAP_PATCH}" ]; then
        echo "*** Error: ${INST_SOURCE_EAP_PATCH} doesn't exists"
        exit
    fi
    if [ ! -f "${INST_SOURCE_BC}" ]; then
        echo "*** Error: ${INST_SOURCE_BC} doesn't exists"
        exit
    fi
    if [ ! -f "${INST_SOURCE_KS}" ]; then
        echo "*** Error: ${INST_SOURCE_KS} doesn't exists"
        exit
    fi
}


javaExists

archiveExists


if [ $USER == "root" ]; then 
    chown -R root:wheel ${INST_SOURCE_EAP}
    chown -R root:wheel ${INST_SOURCE_EAP_PATCH}
    chown -R root:wheel ${INST_SOURCE_BC}
    chown -R root:wheel ${INST_SOURCE_KS} 
fi

echo "=== Extracting EAP binaries"
mkdir -p ${INST_BASE_DIR}/tempinst
unzip -o -q ${INST_SOURCE_EAP} -d ${INST_BASE_DIR}/tempinst 
mv --force ${INST_BASE_DIR}/tempinst/${EAP_EXPAND_FOLDER} ${INST_BASE_DIR}

echo "=== Updating EAP configuration"
cp ${EAP_HOME}/bin/init.d/jboss-eap.conf ${EAP_HOME}/bin/init.d/jboss-eap.conf.original
echo "JBOSS_HOME=\"${EAP_HOME}\"" >> ${EAP_HOME}/bin/init.d/jboss-eap.conf
echo "JBOSS_USER="$USER >> ${EAP_HOME}/bin/init.d/jboss-eap.conf


echo "=== Applying EAP patches"
mkdir -p ${INST_BASE_DIR}/tempinst
echo "patch apply "${INST_SOURCE_EAP_PATCH} > ${INST_BASE_DIR}/tempinst/patch-apply.txt
echo "patch info" > ${INST_BASE_DIR}/tempinst/patch-info.txt
${EAP_HOME}/bin/jboss-cli.sh --file=${INST_BASE_DIR}/tempinst/patch-apply.txt

echo "=== Current EAP version"
${EAP_HOME}/bin/jboss-cli.sh --file=${INST_BASE_DIR}/tempinst/patch-info.txt

if [[ ${HEADLESS_MODE}"" == "false" ]];
then
    echo "=== Extracting Business Central binaries"
    mkdir -p ${INST_BASE_DIR}/tempinst/bc
    unzip -o -q ${INST_SOURCE_BC} -d ${INST_BASE_DIR}/tempinst/bc
else
    echo "=== Headless mode"
fi

echo "=== Extracting KIE binaries"
mkdir -p ${INST_BASE_DIR}/tempinst/kie
unzip -o -q ${INST_SOURCE_KS} -d ${INST_BASE_DIR}/tempinst/kie 


if [[ ${HEADLESS_MODE}"" == "false" ]];
then
    echo "=== Deploying BC apps"
    cp -r --force ${INST_BASE_DIR}/tempinst/bc/${EAP_NAME}.${EAP_MINOR_LVL}/* ${EAP_HOME}
fi

echo "=== Deploying KIE apps"
cp -r --force ${INST_BASE_DIR}/tempinst/kie/kie-server.war ${EAP_HOME}/standalone/deployments/
cp -r --force ${INST_BASE_DIR}/tempinst/kie/SecurityPolicy/* ${EAP_HOME}/bin
touch ${EAP_HOME}/standalone/deployments/kie-server.war.dodeploy


echo "=== Updating Standalone configuration"
STANDALONE_ORIGINAL=${EAP_HOME}/standalone/configuration/standalone.xml.original
if [[ ! -f ${STANDALONE_ORIGINAL} ]]; then cp ${EAP_HOME}/standalone/configuration/standalone.xml ${STANDALONE_ORIGINAL}; fi
cp ${EAP_HOME}/standalone/configuration/standalone-full.xml ${EAP_HOME}/standalone/configuration/standalone.xml
sed -i '/<!--.*-->/d' ${EAP_HOME}/standalone/configuration/standalone.xml
sed -i 's/<!--//g' ${EAP_HOME}/standalone/configuration/standalone.xml
sed -i 's/-->//g' ${EAP_HOME}/standalone/configuration/standalone.xml
sed -i 's/name="org.kie.server.controller.pwd" value="controllerUser1234;"/name="org.kie.server.controller.pwd" value="'${KIE_CTRL_PWD}'"/g' ${EAP_HOME}/standalone/configuration/standalone.xml
sed -i 's/name="org.kie.server.pwd" value="controllerUser1234;"/name="org.kie.server.pwd" value="'${KIE_CTRL_PWD}'"/g' ${EAP_HOME}/standalone/configuration/standalone.xml


echo "=== Configure KIE user"
${EAP_HOME}/bin/jboss-cli.sh --commands="embed-server --std-out=echo,/subsystem=elytron/filesystem-realm=ApplicationRealm:add-identity(identity="${KIE_CTRL_USER}"),/subsystem=elytron/filesystem-realm=ApplicationRealm:set-password(identity="${KIE_CTRL_USER}", clear={password="${KIE_CTRL_PWD}"}),/subsystem=elytron/filesystem-realm=ApplicationRealm:add-identity-attribute(identity="${KIE_CTRL_USER}", name=role, value=[admin,rest-all,kie-server])" > /dev/null 2>&1

if [[ ${HEADLESS_MODE}"" == "false" ]];
then
    echo "=== Configure BC admin user '"${BC_ADMIN_USER}"'"
    ${EAP_HOME}/bin/jboss-cli.sh --commands="embed-server --std-out=echo,/subsystem=elytron/filesystem-realm=ApplicationRealm:add-identity(identity="${BC_ADMIN_USER}"),/subsystem=elytron/filesystem-realm=ApplicationRealm:set-password(identity="${BC_ADMIN_USER}", clear={password="${BC_ADMIN_PWD}"}),/subsystem=elytron/filesystem-realm=ApplicationRealm:add-identity-attribute(identity="${BC_ADMIN_USER}", name=role, value=[admin,rest-all,kie-server])" > /dev/null 2>&1
fi

echo "=== Installation complete."

if [[ ${CONFIG_SERVICE}"" == "y" ]];
then
    ./enableService.sh
else
    echo "=== now execute command: ${EAP_HOME}/bin/standalone.sh" 
    echo "=== or run service configuration with ./enableService.sh"
fi

echo "=== follow the server log using command: tail -n 10000 -f ${EAP_HOME}/standalone/log/server.log"

if [[ ${REMOVE_TEMP}"" == "y" ]];
then
    rm -fR ${INST_BASE_DIR}/tempinst
else
    echo ""
    while true; do
        read -p "Remove temporary folder installation "${INST_BASE_DIR}/tempinst" ? [y/n] " yn
        case $yn in
            [Yy]* ) rm -fR ${INST_BASE_DIR}/tempinst; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi