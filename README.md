# ci-tool-stack
Common 'Dockerized' tools for continuous integration: Jenkins &amp; SonarQube 

## Description
The stack contains both a "Dockerized" Jenkins and a SonarQube as well as data persistence based in "Docker" volume containers.
Also, a script is provided for simplificate the "Docker" containers management

Main characteristics:
- Jenkins 2.46.X LTS with pre-configured plugins and "Docker" volume data container for JENKIS_HOME.
- SonarQube 5.6.X with postgres database for data persistence. Both "Docker" containers.
- Maven 2.0.11 and Maven 3.3.9 deployed in jenkins container
- Java 1.7.79 and Java 1.8.111 deployed in jenkins container
- Docker 1.9.1 deployed in jenkins container. it doesn't use docker in docker! Requieres docker host running
- Shell script utility for simplificate "docker" management: Backups and restoring data volumes, can be made easily

## Usage
To run the stack, open your terminal a run the script and choose one option:

    $./tools.sh
    
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
	
	(x) Clean all Volumes and Dangling Images
	(z) SUBVERSION: Create subversion for testing pruposes in http://localhost:3343/csvn/long/auth
	
	(q) Quit
	  --------------------------------
	Choose one option:
	
* Jenkins runs at: http://localhost:8383
* SonarQube runs at: http://localhost:9000

Edit docker-compose.yml and change the ports and other options

## Twitter account
- Follow me on Twitter, [@rodrigovillamil](https://twitter.com/rodrigovillamil)
