# ibm-bamoe-oneshot-installation

To install IBM Business Automation Manager Open Editions in a single JVM in less than 60 seconds follow these instructions

## Prerequisites

A JVM, use standard JVM installation for your linux box, in a RH box use the command

```
sudo yum install java-11-openjdk
```

Archives for EAP and IBAMOE product installation

### From IBM Passport Advantage
<code>
IBAMOE-8.0-BC7.zip

IBAMOE-8.0-KS8.zip
</code>


### From RedHat Portal
<code>
jboss-eap-7.4.0.zip

jboss-eap-7.4.7-patch.zip
</code>


## Clone this repo

```
git clone https://github.com/marcoantonioni/ibm-bamoe-oneshot-installation
```

## Enter the scripts folder

```
cd ./ibm-bamoe-oneshot-installation/scripts
```

## Change file permission using

```
chmod a+x ./*.sh
```
 
## Edit properties file 

Change at least the folder name (INST_SOURCE_FOLDER) where you downloaded the .zip files.

Change also product version and patch numbers as needed.

<i>Nota: Values of EAP_NAME, EAP_MINOR_LVL, EAP_PATCH_LVL, BAMOE_BC_NAME and BAMOE_KS_NAME are used by the installation script to build full archive names.</i>

```
vim ibm-bamoe-1shot-install.properties
```

Change following vars with your values

```
EAP_NAME=jboss-eap-7
EAP_MINOR_LVL=4
EAP_PATCH_LVL=7
EAP_EXPAND_FOLDER=${EAP_NAME}.${EAP_MINOR_LVL}
BAMOE_BC_NAME=IBAMOE-8.0-BC7
BAMOE_KS_NAME=IBAMOE-8.0-KS8
INST_SOURCE_FOLDER=/home/marco/Downloads
FOLDER_SHARED=/opt

BC_ADMIN_USER=admin
BC_ADMIN_PWD=passw0rd
```

Save propetries file 

## Start installation

Run the following command to install and measure the elapsed time

```
time ./ibm-bamoe-1shot-install.sh
```

## Execute the standalone server 

Use the command 

```
<your-destination-installation-folder>/bin/standalone.sh
```

## Follow the server log file 

Use the command 

```
tail -n 10000 -f <your-destination-installation-folder>/standalone/log/server.log
```

## Access Business Central console

Use your browser and login at Business Central console http://localhost:8080/business-central/kie-wb.jsp using credentials defined in BC_ADMIN_USER and BC_ADMIN_PWD


## Conclusion

You now have a basic environment for developing BPMN and DMN applications with IBM Business Automation Manager Open Editions.
