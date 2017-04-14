#!/bin/bash
#
# Copyright (C) Rodrigo Villamil Perez 2016
# Fichero: tools.sh
# Autor: Rodrigo Villamil Perez
# Fecha: 05/11/2016
#
# Description: Utilities for C.I. tools maintenance
#

# Log File..
LOG_FILE="${0%.*}.log"
source ./utils/functions-docker.sh

# Images and containers name
JENKINS_IMAGE="citoolstack_img-jenkins-master"
JENKINS_MASTER_CONTAINER="cnt-jenkins-master"

JENKINS_DATA_IMAGE="citoolstack_img-jenkins-master-data"
JENKINS_DATA_CONTAINER="cnt-jenkins-master-data"

SONAR_IMAGE="citoolstack_img-sonarqube"
SONAR_CONTAINER="cnt-sonarqube"

POSTGRES_IMAGE="citoolstack_img-postgres"
POSTGRES_CONTAINER="cnt-postgres"

POSTGRES_DATA_IMAGE="citoolstack_img-postgres-data"
POSTGRES_DATA_CONTAINER="cnt-postgres-data"

# Images and containers list
APP_IMAGES="${JENKINS_IMAGE} ${SONAR_IMAGE} ${POSTGRES_IMAGE}"
APP_CONTAINERS="${JENKINS_MASTER_CONTAINER} ${SONAR_CONTAINER} ${POSTGRES_CONTAINER}"

DATA_IMAGES="${JENKINS_DATA_IMAGE} ${POSTGRES_DATA_IMAGE}"
DATA_CONTAINERS="${JENKINS_DATA_CONTAINER} ${POSTGRES_DATA_CONTAINER}"

ALL_IMAGES="${APP_IMAGES} ${DATA_IMAGES}"
ALL_CONTAINERS="${APP_CONTAINERS} ${DATA_CONTAINERS}"

JENKINS_HOME="/var/jenkins_home"
JENKINS_VOLUME_LOG="/var/log/jenkins"
BACKUP_JENKINS_DIRECTORY="$(pwd)/backup-data/cnt-jenkins-master-data"
BACKUP_POSTGRES_DIRECTORY="$(pwd)/backup-data/cnt-postgres-data"

PLUGINS_FILEPATH="$(pwd)/jenkins/jenkins-master/conf/plugins.txt"
POSTGRES_PGDATA="/var/lib/postgresql/data/pgdata"
DOCKER_COMPOSE_FILE="docker-compose.yml"
# ---------------------------- Docker utilities --------------------------------
run_all()
{
    docker-compose -f ${DOCKER_COMPOSE_FILE} up -d
    message "\n- C.I services running in background (-d) !! . You can see the compose file in '${DOCKER_COMPOSE_FILE}'"
    message "- Jenkins at: http://localhost:8383'"
    message "- SonarQube at: http://localhost:9000' (user:admin, password:admin)"
}

stop_all()
{
    docker-compose -f ${DOCKER_COMPOSE_FILE} stop
    message "\n- C.I services are being stopped.."
}
backup_jenkins_data_container()
{
    volumes_to_backup="${JENKINS_HOME} ${JENKINS_VOLUME_LOG}"
    backup_file_name="${JENKINS_DATA_CONTAINER}.tar.gz" 
    backup_file_full_path="${BACKUP_JENKINS_DIRECTORY}/${backup_file_name}"
    if [ -f ${backup_file_full_path} ];then
	message "ERROR! The backup file '${backup_file_full_path}' already exists!. Delete it before" 
	return 1
    fi
    # Tiramos los contenedores ...
    stop_all_compose_containers
    docker ps
    backup_data_volume_container ${JENKINS_DATA_CONTAINER} ${BACKUP_JENKINS_DIRECTORY} ${backup_file_name} ${JENKINS_DATA_IMAGE} ${volumes_to_backup}
    message "\nBackup ready! ${?}"
}

restore_jenkins_data_container()
{
    volumes_to_restore="${JENKINS_HOME} ${JENKINS_VOLUME_LOG}"
    backup_file_name="${JENKINS_DATA_CONTAINER}.tar.gz" 
    backup_file_full_path="${BACKUP_JENKINS_DIRECTORY}/${backup_file_name}"  
    if [ ! -f ${backup_file_full_path} ];then
	message "ERROR! The backup file to restore '${backup_file_full_path}' not exists!"
	return 1
    fi
    message "Re-creating data container ${JENKINS_DATA_CONTAINER} (if not exist)"
    docker-compose up "${JENKINS_DATA_IMAGE}" &> ${LOG_FILE} # De esta manera re-creamos el contenedor con la imagen si no existe
    stop_all_compose_containers
    docker ps
    restore_data_volume_container ${JENKINS_DATA_CONTAINER} ${BACKUP_JENKINS_DIRECTORY} ${backup_file_name} ${JENKINS_DATA_IMAGE} ${volumes_to_restore} &> ${LOG_FILE}
    message "\nRestore ready! ${?}"
} 

backup_postgres_data_container()
{
    volumes_to_backup="${POSTGRES_PGDATA}"
    backup_file_name="${POSTGRES_DATA_CONTAINER}.tar.gz" 
    backup_file_full_path="${BACKUP_POSTGRES_DIRECTORY}/${backup_file_name}"
    if [ -f ${backup_file_full_path} ];then
	message "ERROR! The backup file '${backup_file_full_path}' already exists!. Delete it before" 
	return 1
    fi
    stop_all_compose_containers
    docker ps
    backup_data_volume_container ${POSTGRES_DATA_CONTAINER} ${BACKUP_POSTGRES_DIRECTORY} ${backup_file_name} ${POSTGRES_DATA_IMAGE} ${volumes_to_backup}
    message "\nBackup ready! ${?}"
}

restore_postgres_data_container()
{
    volumes_to_restore="${POSTGRES_DATA}"
    backup_file_name="${POSTGRES_DATA_CONTAINER}.tar.gz" 
    backup_file_full_path="${BACKUP_POSTGRES_DIRECTORY}/${backup_file_name}"  
    if [ ! -f ${backup_file_full_path} ];then
	message "ERROR! The backup file to restore ${backup_file_full_path}! not exists!"
	return 1
    fi
    message "Re-creating data container ${JENKINS_DATA_CONTAINER} (if not exist)"
    docker-compose up "${POSTGRES_DATA_IMAGE}" &> ${LOG_FILE} # De esta manera creamos el contenedor con la imagen si no existe
    stop_all_compose_containers
    docker ps
    restore_data_volume_container ${POSTGRES_DATA_CONTAINER} ${BACKUP_POSTGRES_DIRECTORY} ${backup_file_name} ${POSTGRES_DATA_IMAGE} ${volumes_to_restore} &> ${LOG_FILE}
    message "\nRestore ready! ${?}"
}

bash_jenkins_master()
{
    bash_in_container ${JENKINS_MASTER_CONTAINER}
}

bash_sonarqube()
{
    bash_in_container ${SONAR_CONTAINER}
}   

inspect_jenkins_master()
{
    inspect_container ${JENKINS_MASTER_CONTAINER}
}

clean_all_ci_docker()
{
    message "Cleaning C.I IMAGES '${ALL_IMAGES}' and C.I CONTAINERS '${ALL_CONTAINERS}'"
    docker-compose down  &> ${LOG_FILE}
    docker rm ${ALL_CONTAINERS} &> ${LOG_FILE}
    docker rmi ${ALL_IMAGES}  &> ${LOG_FILE}
    clean_all_dangling_volumes_and_images  
    message "\nImage list .."    
    docker images
    message "\nContainer list .."    
    docker ps
}

get_plugins_from_jenkins()
{
    # install plugins; the plugins.txt file can be exported from Jenkins like this:
    # jenkins_host=username:password@myhost.com:port
    #echo "Not yet implemented.."
    #exit 1
    #message "Connecting to Jenkins Host..."
    #echo -e "Jenkins Username:"
    #read jenkins_username
    #echo -e "Password:"
    #read user_password
    #echo -e "Jenkins HOST (localhost, 192.168.99.199):"
    #read jenkins_host
    
    #jenkins_secret_key="/var/jenkins_home/secrets/initialAdminPassword"
    #admin_pass=$(docker exec ${JENKINS_MASTER_CONTAINER} cat ${jenkins_secret_key})
    #echo "admin:$admin_pass"
    #exit 0

    JENKINS_HOST_CONNECTION_STRING="user:password@192.168.99.100:8383"
    
    message "Getting 'plugins.txt' file from ${JENKINS_HOST_CONNECTION_STRING}"
    
    curl -sSL "${JENKINS_HOST_CONNECTION_STRING}/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g'|sed 's/ /:/' > /tmp/jenkis_plugins.list
    
    if [ -s /tmp/jenkis_plugins.list ];then # Si existe y no esta vacio
	cat /tmp/jenkis_plugins.list > ${PLUGINS_FILEPATH}
	num_plugins=$(cat ${PLUGINS_FILEPATH} | wc -l | tr -d '[:space:]')
	cat ${PLUGINS_FILEPATH} >> ${LOG_FILE}
	message "\n\nThe jenkins plugins file contains '$num_plugins' plugins"
	message "The file '${PLUGINS_FILEPATH}'has been updated"
    else
	message "ERROR! Jenkins '${JENKINS_HOST_CONNECTION_STRING}' is not running!"
	return 1
    fi    
}

get_log_file()
{
    docker exec ${JENKINS_MASTER_CONTAINER} cat ${JENKINS_VOLUME_LOG}/jenkins.log
}

show_jenkins_initial_admin_password()
{
    jenkins_secret_key="/var/jenkins_home/secrets/initialAdminPassword"
    message "Jenkins Secret Key from file ${jenkins_secret_key}"
    docker exec ${JENKINS_MASTER_CONTAINER} cat ${jenkins_secret_key}
}

run_svnserver()
{
    message "Running mamohr/subversion-edge ..."
    docker run -p 3343:3343 -p 4434:4434 -p 18080:18080  --name svn-server mamohr/subversion-edge --hostname subversion-server
    if [ ! $? -eq 0 ];then
	docker start svn-server
    fi
    message "\n Subversion from Collabnet initializing...(1 minute). The image is exposing the data dir of csvn as a volume under '/opt/csvn/data'"
    message "\n   * URL: http://localhost:3343/csvn/long/auth"
    message "\n   * Download TEST project 'svn co http://localhost:18080/svn/test test --username=admin'"
    message "\n   * The username is 'admin' and the Password is 'admin'"
}

# ----------------------------------------------------------------------
while :
do
    clear
    cat<<EOF
 ======================================
    	C.I Tool Stack Utilities
 ======================================

	(0) Run C.I. tool stack demonized (docker-compose up -d)
	(1) Stop C.I tool stack (docker-compose stop)
	(2) Remove all containers (volumes included) and images from C.I tool stack!
     
	(3) JENKINS : 'Backup' Jenkins volume data container (JENKINS_HOME and Log file)
	(4) JENKINS : 'Restore' Jenkins volume data container
	(5) JENKINS : Run 'bash' terminal
	(6) JENKINS : Inspect container
	(7) JENKINS : Update 'plugins.txt' file with current installed plugins
	(8) JENKINS : Get file '/var/log/jenkins/jenkins.log'
	(9) JENKINS : Show secret Jenkins instalation key
   
	(a) SONAR : 'Backup' Sonarqube volume data container (Postgres ddbb)
	(b) SONAR : 'Restore' Sonarqube volume data container (Postgres ddbb)
	(c) SONAR : Run 'bash' terminal

	(x) Clean all Volumes and Dangling Images
	(z) SUBVERSION: Create subversion for testing pruposes in http://localhost:3343/csvn/long/auth
     
	(q) Quit
  --------------------------------
EOF
    echo -n "Choose one option: "
    read -n1 -s
    echo ""
    case "$REPLY" in
	"0")  run_all; exit 0 ;;
	"1")  stop_all; exit 0 ;;
	"2")  clean_all_ci_docker; exit 0 ;;
   
	"3")  backup_jenkins_data_container ; exit 0 ;;
	"4")  restore_jenkins_data_container; exit 0 ;;
	"5")  bash_jenkins_master; exit 0 ;;
	"6")  inspect_jenkins_master; exit 0 ;;
	"7")  get_plugins_from_jenkins ; exit 0 ;;
	"8")  get_log_file jenkins.log ; exit 0 ;;
	"9")  show_jenkins_initial_admin_password ; exit 0 ;;
	
	"a"|"A")  backup_postgres_data_container ; exit 0 ;;
	"b"|"B")  restore_postgres_data_container; exit 0 ;;
	"c"|"C")  bash_sonarqube; exit 0 ;;
	
	"x"|"X")  clean_all_dangling_volumes_and_images ;;
	"z"|"Z")  run_svnserver; exit 0 ;;
	
	"q"|"Q")  exit 0 ;;
	* )  echo "Invalid option !!" ;;
    esac
    echo ""
    echo -n "Press enter key ..."
    read enter_key
done

