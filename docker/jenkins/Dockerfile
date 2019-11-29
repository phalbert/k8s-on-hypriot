FROM jenkins4eval/jenkins@sha256:5ba5d97b91646b79a0898fd7713700ffc33f73c9e8cf90162f4e647882bf4162
#FROM jenkins4eval/jenkins:2.206-slim

ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Dorg.jenkinsci.remoting.engine.JNLP3-connect.disabled=true -Dorg.jenkinsci.remoting.engine.JnlpProtocol2.disabled=true -Dorg.jenkinsci.remoting.engine.JnlpProtocol1.disabled=true"

USER root

RUN mkdir /var/log/jenkins  /usr/share/jenkins/ref/plugins

RUN chown -R root:root /var/log/jenkins \
    && chown -R root:root /usr/share/jenkins \
    && chown -R root:root /var/jenkins_home

RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

COPY plugins.txt /usr/share/jenkins/ref/

RUN /usr/local/bin/plugins.sh /usr/share/jenkins/ref/plugins.txt

COPY scripts/*.groovy /usr/share/jenkins/ref/init.groovy.d/

USER jenkins