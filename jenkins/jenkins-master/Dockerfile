# Jenkins LTS
FROM jenkins:2.32.3
MAINTAINER Rodrigo Villamil Perez

# Root user
USER root
# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update &&  \
    apt-get install -y wget
#
# Maven and java directories
#
RUN mkdir -p /opt/maven && \
    mkdir -p /opt/java
#
# MAVEN 2
#
ENV MAVEN2_VERSION=2.0.11
RUN wget --no-verbose -O /tmp/apache-maven-$MAVEN2_VERSION-bin.tar.gz http://archive.apache.org/dist/maven/maven-2/$MAVEN2_VERSION/binaries/apache-maven-$MAVEN2_VERSION-bin.tar.gz
RUN echo "c87c4caae590d48f90e02fc7e254dabe /tmp/apache-maven-$MAVEN2_VERSION-bin.tar.gz" | md5sum -c
RUN tar xzf /tmp/apache-maven-$MAVEN2_VERSION-bin.tar.gz -C /opt/maven/

#
# MAVEN 3
#
ENV MAVEN3_VERSION=3.3.9
RUN wget --no-verbose -O /tmp/apache-maven-$MAVEN3_VERSION-bin.tar.gz http://archive.apache.org/dist/maven/maven-3/$MAVEN3_VERSION/binaries/apache-maven-$MAVEN3_VERSION-bin.tar.gz
RUN echo "516923b3955b6035ba6b0a5b031fbd8b /tmp/apache-maven-$MAVEN3_VERSION-bin.tar.gz" | md5sum -c
RUN tar xzf /tmp/apache-maven-$MAVEN3_VERSION-bin.tar.gz -C /opt/maven/

#
# JDK 1.8: http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-linux-x64.tar.gz
#
# set shell variables for java installation
ENV JAVA8_VERSION=1.8
ENV JAVA8_FILENAME=jdk-8u111-linux-x64.tar.gz
ENV JAVA8_DOWNLOADLINK=http://download.oracle.com/otn-pub/java/jdk/8u111-b14/$JAVA8_FILENAME
# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$JAVA8_FILENAME $JAVA8_DOWNLOADLINK
# unpack java
RUN mkdir -p /opt/java/ && tar -zxf /tmp/$JAVA8_FILENAME -C /opt/java/

#
# JDK 1.7 : http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz
#
ENV JAVA7_VERSION=1.7
ENV JAVA7_FILENAME=jdk-7u79-linux-x64.tar.gz
ENV JAVA7_DOWNLOADLINK=http://download.oracle.com/otn-pub/java/jdk/7u79-b15/$JAVA7_FILENAME

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$JAVA7_FILENAME $JAVA7_DOWNLOADLINK

# unpack java
RUN mkdir -p /opt/java/ && tar -zxf /tmp/$JAVA7_FILENAME -C /opt/java/

#
# Fin de las instalaciones: remove download archive files
#
RUN apt-get clean

#
# 'Jenkins home directory is a volume, so configuration and build history 
# can be persisted and survive image upgrades: VOLUME /var/jenkins_home'
#
RUN mkdir /var/log/jenkins &&  \
    mkdir /var/cache/jenkins &&  \
    chown -R jenkins:jenkins /var/log/jenkins &&  \
    chown -R jenkins:jenkins /var/cache/jenkins

USER jenkins

#
# Set list of plugins to download / update in plugins.txt like this
# pluginID:version
# credentials:1.18
# maven-plugin:2.7.1
# ...
# NOTE : Just set pluginID to download latest version of plugin.
# NOTE : All plugins need to be listed as there is no transitive dependency resolution.
#
# install plugins; the plugins.txt file can be exported from Jenkins like this:
# JENKINS_HOST=username:password@myhost.com:port
# curl -sSL "http://$JENKINS_HOST/pluginManager/api/xml?depth=1&xpath=/*/*/shortName|/*/*/version&wrapper=plugins" | perl -pe 's/.*?<shortName>([\w-]+).*?<version>([^<]+)()(<\/\w+>)+/\1 \2\n/g'|sed 's/ /:/' > jenkins-master/conf/plugins.txt
#COPY conf/plugins.txt /var/jenkins_home/plugins.txt
#RUN /usr/local/bin/plugins.sh /var/jenkins_home/plugins.txt

#
# Adding default Jenkins Jobs
#
# COPY jobs/example-job.xml /usr/share/jenkins/ref/jobs/example-job/config.xml

#
# tell Jenkins that no banner prompt for pipeline plugins is needed
#
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

#
# Set the log file and and move jenkins.war to cache directory, out of the 
# jenkins home
#
ENV JENKINS_OPTS="--logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war"


