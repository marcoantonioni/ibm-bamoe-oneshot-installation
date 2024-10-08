# ibm-bamoe-oneshot-installation

To install IBM Business Automation Manager Open Editions in a single JVM in less than 60 seconds follow these instructions

## Updates

December 2022: EAP 7.4.8 / BAM 8.0.1

## Prerequisites

A JVM, use standard JVM installation for your linux box, in a RH box use the command

```
sudo yum install java-11-openjdk
```

Download archives for EAP and IBAMOE product installation

### From IBM Passport Advantage

https://www.ibm.com/software/passportadvantage/

Login at https://www.ibm.com/software/passportadvantage/pao_customer.html

Search for:

<code>
IBM Business Automation Manager Open Editions 8.0 - Business Central for EAP 7 Multilingual (IBAMOE-8.0-BC7.zip) - M06VVML

IBM Business Automation Manager Open Editions 8.0 - KIE Server EE8 Multilingual (IBAMOE-8.0-KS8.zip) - M06VYML
</code>

download files:

<code>
IBAMOE-8.0-BC7.zip

IBAMOE-8.0-KS8.zip
</code>

#### UPDATE october 2022

From the first fix available the package nomenclature has changed.

To install a new environment directly using the latest version/fix available search and download from IBM Fix Central (https://www.ibm.com/support/fixcentral, Product selector* as "IBM Business Automation Manager Open Editions") all the archives you want to install/update, for example

<code>
bamoe-8.0.1-business-central-eap7-deployable.zip

bamoe-8.0.1-kie-server-ee8.zip
</code>

use for example the following setting in the properties file

<code>
BAMOE_BC_NAME=bamoe-8.0.1-business-central-eap7-deployable

BAMOE_KS_NAME=bamoe-8.0.1-kie-server-ee8
</code>


#### More infos at IBM Business Automation Manager Open Editions 8.0 download document

https://www.ibm.com/support/pages/node/6596913

### From RedHat Customer Portal

Red Hat Customer Portal (https://access.redhat.com)

1. Log in to the Red Hat Customer Portal .
2. Click Downloads.
3. Select Red Hat JBoss Enterprise Application Platform in the Product Downloads list.
4. In the Version drop-down list, select 7.4.
5. Find Red Hat JBoss Enterprise Application Platform 7.4.0 in the list and click the Download
link.

download files:

<code>
jboss-eap-7.4.0.zip

jboss-eap-7.4.7-patch.zip
</code>


Copy the files you downloaded in a folder accessible from the installation, the complete path must then be set as the value of the <b>INST_SOURCE_FOLDER</b> variable (next steps).

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
KIE_CTRL_PWD=newPassw0rd
```

Or if you are installing latest fixes for example
```
BAMOE_BC_NAME=bamoe-8.0.1-business-central-eap7-deployable
BAMOE_KS_NAME=bamoe-8.0.1-kie-server-ee8
```

Save propetries file 

## Start installation

Run the following command to install and measure the elapsed time

```
time ./ibm-bamoe-1shot-install.sh
```

or specify properties file (-p), autostart as a service (-s), clean temporary installation directory (-r)

```
./ibm-bamoe-1shot-install.sh -p ./ibm-bamoe-1shot-install.properties -s y -r y
```

use the following parameters to specify

<b>-p</b> <i>..path-of-properties-file-name..</i> # if located in different folder 

<b>-c</b> <i>[y/n]</i> # to clear the temporary folder used to install 

<b>-s</b> <i>[y/n]</i> # to configure the service for autostart option


## Execute the standalone server 

```
export EAP_HOME=<your-destination-installation-folder>
cd ${EAP_HOME}
./bin/standalone.sh
```

## Follow the server log file 

Use the command 

```
tail -n 10000 -f <your-destination-installation-folder>/standalone/log/server.log
```

## Access Business Central console

Use your browser and login at Business Central console http://localhost:8080/business-central/kie-wb.jsp using credentials defined in BC_ADMIN_USER and BC_ADMIN_PWD

To check the current product version/fix from the user menu (at the top right) select the "About" menu.

## Other optional commands

### Enable service for autostart

```
./enableService.sh -p ./ibm-bamoe-1shot-install.properties -c y
```

### Disable service for autostart

```
./disableService.sh -p ./ibm-bamoe-1shot-install.properties -c y
```

### Uninstal

Uninstall the product identied by properties file and force without asking confirmation (-c)
```
./uninstal-bamoe.sh -p ./ibm-bamoe-1shot-install.properties -c y
```


## Conclusion

You now have a basic environment for developing BPMN and DMN applications with IBM Business Automation Manager Open Editions.

## Useful links

JBoss patches

https://access.redhat.com/solutions/2898471

https://access.redhat.com/jbossnetwork/restricted/listSoftware.html?product=appplatform&downloadType=patches&version=7.4

https://access.redhat.com/solutions/625683
