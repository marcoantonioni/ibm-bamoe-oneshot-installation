#/bin/bash

# if file props

. ./ibm-bamoe-1shot-install.properties

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

echo "=== Installing as user '"$USER"' in folder "${EAP_HOME}

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
unzip -q ${INST_SOURCE_EAP} -d ${INST_BASE_DIR}/tempinst 
mv ${INST_BASE_DIR}/tempinst/${EAP_EXPAND_FOLDER} ${INST_BASE_DIR}

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

echo "=== Extracting Business Central binaries"
mkdir -p ${INST_BASE_DIR}/tempinst/bc
unzip -q ${INST_SOURCE_BC} -d ${INST_BASE_DIR}/tempinst/bc

echo "=== Extracting KIE binaries"
mkdir -p ${INST_BASE_DIR}/tempinst/kie
unzip -q ${INST_SOURCE_KS} -d ${INST_BASE_DIR}/tempinst/kie 


echo "=== Deploying BC and KIE apps"
cp -r --force ${INST_BASE_DIR}/tempinst/bc/${EAP_NAME}.${EAP_MINOR_LVL}/* ${EAP_HOME}
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

echo "=== Configure KIE / BC"
${EAP_HOME}/bin/jboss-cli.sh --commands="embed-server --std-out=echo,/subsystem=elytron/filesystem-realm=ApplicationRealm:add-identity(identity="${KIE_CTRL_USER}"),/subsystem=elytron/filesystem-realm=ApplicationRealm:set-password(identity="${KIE_CTRL_USER}", clear={password="${KIE_CTRL_PWD}"}),/subsystem=elytron/filesystem-realm=ApplicationRealm:add-identity-attribute(identity="${KIE_CTRL_USER}", name=role, value=[admin,rest-all,kie-server])" > /dev/null 2>&1

echo "=== Configure admin user '"${BC_ADMIN_USER}"'"
${EAP_HOME}/bin/jboss-cli.sh --commands="embed-server --std-out=echo,/subsystem=elytron/filesystem-realm=ApplicationRealm:add-identity(identity="${BC_ADMIN_USER}"),/subsystem=elytron/filesystem-realm=ApplicationRealm:set-password(identity="${BC_ADMIN_USER}", clear={password="${BC_ADMIN_PWD}"}),/subsystem=elytron/filesystem-realm=ApplicationRealm:add-identity-attribute(identity="${BC_ADMIN_USER}", name=role, value=[admin,rest-all,kie-server])" > /dev/null 2>&1

echo "=== Installation complete."
echo "=== now execute command: ${EAP_HOME}/bin/standalone.sh" 
echo "=== or run service configuration with XYZ.sh"
echo "=== follow the server log using command: tail -n 10000 -f ${EAP_HOME}/standalone/log/server.log"

