# I use the base Debian image because it matches the same base image
# the Cloudbees Jenkins image
FROM debian:jessie
MAINTAINER Rodrigo Villamil Perez

# Now create the Jenkins user in this container by adding.
# NOTE: we set the UID here to the same one the Cloudbees Jenkins image uses
# so we can match UIDs across containers, which is essential if you want to
# preserve file permissions between the containers. We also use the same home
# directory and bash settings.
RUN useradd -d "/var/jenkins_home" -u 1000 -m -s /bin/bash jenkins

# Create the folders and volume mount points
RUN mkdir -p /var/log/jenkins && \
    chown -R jenkins:jenkins /var/log/jenkins

VOLUME ["/var/log/jenkins", "/var/jenkins_home"]
USER jenkins

CMD ["echo", "Jenkins: Volume data container for Log and JENKINS_HOME ready!"]
