# PostgreSQL for BAM OE

## Installation

```
sudo su -

# install package
dnf install -y postgresql-server

# bin files in
ls -al /usr/bin/postgres*

# initialise db
postgresql-setup --initdb
```

set password for 'postgres' user
```
passwd postgres
```

## Configurations

### Password encription

set env var for 'postgresql.conf' file location
```
export PGCONF=/var/lib/pgsql/data/postgresql.conf
```

then run pgUpdateCfgs.sh in scripts/postgresql folder
```
sudo ./pgUpdateCfgs.sh ${PGCONF}
```

verify new configuration
```
sudo cat ${PGCONF} | grep encry
```

### Network client authentication

set env var for 'postgresql.conf' file location
```
export PGCLIENTAUTH=/var/lib/pgsql/data/pg_hba.conf
```

then run pgUpdateCNA.sh in scripts/postgresql folder
```
sudo ./pgUpdateCNA.sh ${PGCLIENTAUTH}
```

verify new configuration
```
sudo cat ${PGCLIENTAUTH} | grep scram-sha-256
```

### Start and enable service

```
sudo systemctl start postgresql.service
sudo systemctl enable postgresql.service
```

### Checks

```
su - postgres

# connection info
psql -c "\conninfo"

# list users
psql -c "\du+"
```

### Update password for 'postgres' user

change password (use your preferred)
```
psql -c "alter user postgres with password 'post01gres';"
```

### KieServer User

```
su - postgres

KIE_USER=kieserver
KIE_PWD=kie01server

# create user
psql -c "create user ${KIE_USER} with password '${KIE_PWD}' createrole createdb;"

# list users
psql -c "\du+"
```

test login
```
PGPASSWORD=${KIE_PWD} psql -U ${KIE_USER} -h 127.0.0.1 -d postgres
```

for db list type
```
\l+
```

to exit type
```
\q
```

### BAMOE db setup

create BAMOE db using kie server user name
```
KIE_USER=kieserver
KIE_PWD=kie01server
BAMOE_DB_NAME=kieserver01

PGPASSWORD=${KIE_PWD} psql -U ${KIE_USER} -h 127.0.0.1 -d postgres -c "create database ${BAMOE_DB_NAME};"

PGPASSWORD=${KIE_PWD} psql -U ${KIE_USER} -h 127.0.0.1 -d ${BAMOE_DB_NAME} -c "comment on database ${BAMOE_DB_NAME} is 'BAMOE Database';"

# list databases
PGPASSWORD=${KIE_PWD} psql -U ${KIE_USER} -h 127.0.0.1 -d ${BAMOE_DB_NAME} -c "\l+"
```

### Create schema and tables

Download and expand BAM OE Add-ons archive (eg. 'bamoe-8.0.1-add-ons.zip)

Then expand 'bamoe-8.x.y-migration-tool' zip file and copy file 'postgresql-jbpm-schema.sql' from folder 'bamoe-8.x.y-migration-tool/ddl-scripts/postgresql'

```
# load schema
SCHEMA_FILE_LOC=./postgresql-jbpm-schema.sql
PGPASSWORD=${KIE_PWD} psql -U ${KIE_USER} -h 127.0.0.1 -d ${BAMOE_DB_NAME} -a -f ${SCHEMA_FILE_LOC}

# list schema
PGPASSWORD=${KIE_PWD} psql -U ${KIE_USER} -h 127.0.0.1 -d ${BAMOE_DB_NAME} -c "\dn+;"

# list tables
PGPASSWORD=${KIE_PWD} psql -U ${KIE_USER} -h 127.0.0.1 -d ${BAMOE_DB_NAME} -c "\dt+;"
```

## KieServer configuration

### JDBC drivers

Download postgresql drivers

```
curl -LO https://jdbc.postgresql.org/download/postgresql-42.5.1.jar
```

use JBoss CLI to add jdbc driver

```
EAP_HOME=/home/marco/jboss-eap-7.4
JAR_PATH=/home/marco/Downloads/postgresql-42.5.1.jar

${EAP_HOME}/bin/jboss-cli.sh --commands="module add --name=com.postgresql --resources="${JAR_PATH}" --dependencies=javaee.api,sun.jdk,ibm.jdk,javax.api,javax.transaction.api"
```


### Datasource & Driver

Backup standalone.conf in 'jboss-eap-7.4/standalone/configuration'

Change update 'standalone.conf' file with the following sections:

In '<system-properties>' section set the datasource

```
    <!-- Data source properties. -->
    <property name="org.kie.server.persistence.ds" value="java:jboss/datasources/PostgresDS"/>
    <property name="org.kie.server.persistence.dialect" value="org.hibernate.dialect.PostgreSQLDialect"/>
```

In '<datasources>' section add datasource (connection url, credentials) and driver infos
  
```
    <datasource jndi-name="java:jboss/datasources/PostgresDS" pool-name="PostgresDS">
        <connection-url>jdbc:postgresql://localhost:5432/kieserver01</connection-url>
        <driver>postgresql</driver>
        <security>
            <user-name>kieserver</user-name>
            <password>kie01server</password>
        </security>
        <validation>
            <valid-connection-checker class-name="org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLValidConnectionChecker"/>
            <validate-on-match>true</validate-on-match>
            <background-validation>false</background-validation>
            <exception-sorter class-name="org.jboss.jca.adapters.jdbc.extensions.postgres.PostgreSQLExceptionSorter"/>
        </validation>
    </datasource>

    <drivers>
        <driver name="postgresql" module="com.postgresql">
            <xa-datasource-class>org.postgresql.xa.PGXADataSource</xa-datasource-class>
        </driver>
    </drivers>
```

Start BAMOE server
```
```


## TBD Quartz tables