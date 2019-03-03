FROM jboss/base-jdk:8

ENV GODESYS ERP 5.6.6 TRUNK

ENV JBOSS_HOME /opt/jboss/keycloak-quickstart
ENV MAVEN_VERSION 3.6.0
# Enables signals getting passed from startup script to JVM
# ensuring clean shutdown when container is stopped.
ENV LAUNCH_JBOSS_IN_BACKGROUND 1

USER root

# Install MAVEN 
## load and unpack last ERP version
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

## Rerplace Settings.xml
ADD /home/webalexx/Prj/SAMPLE_WORKSPACE/keycloak-quickstarts/maven-settings.xml usr/bin/mvn

## Set MAVEN_HOME
ENV MAVEN_HOME /usr/share/maven


USER jboss

# Install Keycloak 
ADD /home/webalexx/Prj/SAMPLE_WORKSPACE/keycloak-quickstarts/ /opt/jboss/

RUN $JBOSS_HOME/bin/add-user.sh admin admin123! --silent


#RUN cd /opt/jboss && curl -s http://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-demo-$KEYCLOAK_VERSION.zip -o tmp.zip && unzip tmp.zip -d . && mv /opt/jboss/keycloak-demo-$KEYCLOAK_VERSION /opt/jboss/keycloak-demo

RUN mvn package -f /opt/jboss/keycloak-quickstarts/pom.xml && rm -rf ~/.m2/repository 
#RUN cd /opt/jboss/keycloak-demo/examples/preconfigured-demo && find -name *.war | grep -v ear | xargs -I {} cp {} /opt/jboss/keycloak-demo/keycloak/standalone/deployments/ && cp /opt/jboss/keycloak-demo/examples/preconfigured-demo/testrealm.json /opt/jboss/keycloak-demo/keycloak/

ADD docker-entrypoint.sh /opt/jboss/

EXPOSE 8080

ENTRYPOINT ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0", "-c", "standalone-apiman.xml"]
#ENTRYPOINT [ "/opt/jboss/docker-entrypoint.sh" ]
