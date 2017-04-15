#!/bin/bash 
#
# Copyright (C) Rodrigo Villamil Perez 2016
# Fichero: functions-docker.sh
# Autor: Rodrigo Villamil Perez
# Fecha: 14/11/16
#
# Description: Common utilities
#

# ------------------------- Logger functions -----------------------------------
# We can set the Log file from external script
if [ -z "${LOG_FILE}" ];then
    LOG_FILE="default.log"
fi

echo -e "WARNING! The log file is ${LOG_FILE}"

log()
{
    echo "$(date +'%Y-%m-%d %H:%M:%S,%3N') ${1}" >> ${LOG_FILE} 
}
logInfo()
{
    log "[INFO]: ${1}"
}
logError()
{
    log "[ERROR]: ${1}"
}
message()
{
    echo -e "${1}"
}

# ----------------------------- Other functions --------------------------------
is_empty_dir()
{
    [ "$(ls -A ${1})" ] && return 1 || return 0
}

##
## copy-paste from https://gist.github.com/DinoChiesa/3e3c3866b51290f31243
##
parse_yaml2() {
    local prefix=$2
    local s
    local w
    local fs
    s='[[:space:]]*'
    w='[a-zA-Z0-9_]*'
    fs="$(echo @|tr @ '\034')"
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s[:-]$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$1" |
    awk -F"$fs" '{
      indent = length($1)/2;
      if (length($2) == 0) { conj[indent]="+";} else {conj[indent]="";}
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
              vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
              printf("%s%s%s%s=(\"%s\")\n", "'"$prefix"'",vn, $2, conj[indent-1],$3);
      }
    }' | sed 's/_=/+=/g'
}
# ---------------------------- Docker utilities --------------------------------
# Thank's to:
#  - https://twasink.net/2016/08/01/setting-up-a-jenkins-server-with-docker/
#  - https://goo.gl/YDJ088
#  - https://clusterhq.com/2016/08/15/jenkins-flocker-part1/
#
#  - http://www.tricksofthetrades.net/2016/03/14/docker-data-volumes/
#  - https://goo.gl/NMQZBq
up_all_compose_containers()
{
    message "Builds, (re)creates, starts, and attaches to containers for a service. (docker-compose up) ...."
    docker-compose up &> ${LOG_FILE} 
}

stop_all_compose_containers()
{
    message "Stop running containers without removing them (docker-compose stop) ..."
    docker-compose stop &> ${LOG_FILE} 
}

clean_all_dangling_volumes()
{
    message "Cleaning all dangling volumes .."
    docker volume rm $(docker volume ls -f dangling=true -q)
}

clean_all_stopped_containers()
{
    message "Cleaning all stopped containers...( docker rm $(docker ps -a -q) )"    
    docker rm $(docker ps -a -q)
}

clean_all_untagged_containers()
{
    message "Cleaning all untagged containers ..(<none>)"
    docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
}

clean_all_dangling_volumes_and_images()
{
    clean_all_dangling_volumes
    clean_all_untagged_containers
}

bash_in_container()
{
    message "Running bash over ${1}"
    docker exec -i -t ${1} /bin/bash
}

inspect_container()
{
    message "Inspecting ${1}"
    docker inspect ${1}
}


#
#  Backup data volume container
#  https://docs.docker.com/engine/tutorials/dockervolumes/#backup-restore-or-migrate-data-volumes
#
# ${1} : Data volume container name to backup
# ${2} : Backup directory in local host. Create it, if not exist  
# ${3} : Backup ".tar.gz" file name
# ${4} : Image base for creating the backup (debian, fedora, jenkins...)
# ${5} : Volume list to backup
#        e.g.: /var/jenkins_home /var/log/jenkins
#
backup_data_volume_container()
{
    data_container=${1}
    backup_directory=${2}
    backup_file_name=${3}
    image_base=${4}
    volumes_to_backup=${@:5}
    backup_file_full_path="${backup_directory}/${backup_file_name}"
   
    message "Volumes to backup '${volumes_to_backup}' from data container name as '${data_container}'"
    docker run --rm  -v ${backup_directory}:/backup --volumes-from ${data_container} ${image_base} tar -Pczvf /backup/${backup_file_name} ${volumes_to_backup}
    #
    # -P option evita el problema que me quita la / incial y luego no restaura bien el backup
    #
    if [ ${?} -eq 0 ];then
		message "New backup in '${backup_file_full_path}'"
		return 0
    else
		message "ERROR! creating Backup. Deleting file '${backup_file_full_path}'"
		rm -r "${backup_file_full_path}"
		return 1
    fi
}

#
#  Restore the backup data volume container
#  https://docs.docker.com/engine/tutorials/dockervolumes/#backup-restore-or-migrate-data-volumes
#
# ${1} : Data volume container name to restore
# ${2} : Backup directory in local host. 
# ${3} : Backup ".tar.gz" file name
# ${4} : Image base for creating the backup (debian, fedora, jenkins...)
# ${5} : Volume list to restore
#        e.g.: /var/jenkins_home /var/log/jenkins
#
restore_data_volume_container()
{
    data_container=${1}
    backup_directory=${2}
    backup_file_name=${3}
    image_base=${4}
    volumes_to_restore=${@:5}

    backup_file_full_path="${backup_directory}/${backup_file_name}"
   	 
	message "Restoring volumes '${volumes_to_restore}' from data container '${data_container}' with file '${backup_file_full_path}'"
    docker run --rm  -v ${backup_directory}:/backup --volumes-from ${data_container} ${image_base} tar -xzvf /backup/${backup_file_name} ${volumes_to_restore}
    
    if [ ${?} -eq 0 ];then
		message "Restore '${backup_file_full_path}' in ${data_container}"
		meesage "Testing the backup .."    
		docker run --rm  -v ${backup_directory}:/backup --volumes-from ${data_container} ${image_base} ls -lh ${volumes_to_restore}
		return 0
    else
		message "ERROR! restoring '${backup_file_full_path}'"
		return 1
    fi
}
