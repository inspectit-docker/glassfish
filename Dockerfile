FROM glassfish:latest

ENV INSPECTIT_VERSION 1.6.6.76
ENV INSPECTIT_AGENT_HOME /opt/agent
ENV INSPECTIT_CONFIG_HOME /opt/agent/active-config

RUN wget https://github.com/inspectIT/inspectIT/releases/download/1.6.6.76/inspectit-agent-sun1.5.zip -q \
      && unzip inspectit-agent-sun1.5.zip -d /opt \
      && apt-get clean \
      && rm -rf /var/lib/apt \
      && rm -f inspectit-agent-sun1.5.zip

RUN ln -s /opt/agent/inspectit-agent.jar glassfish/domains/domain1/lib/ext/ \
 && ln -s /opt/agent/logging-config.xml glassfish/domains/domain1/lib/ext/

RUN sed -i "s#\(</java-config>\)#<jvm-options>-Xbootclasspath/p:\${com\.sun\.aas\.instanceRoot}/lib/ext/inspectit-agent\.jar</jvm-options>\1#" glassfish/domains/domain1/config/domain.xml \
	&& sed -i "s#\(</java-config>\)#<jvm-options>-javaagent:\${com\.sun\.aas\.instanceRoot}/lib/ext/inspectit-agent.jar</jvm-options>\1#" glassfish/domains/domain1/config/domain.xml \
	&& sed -i "s#\(</java-config>\)#<jvm-options>-Dinspectit.config=${INSPECTIT_CONFIG_HOME}</jvm-options>\1#" glassfish/domains/domain1/config/domain.xml \
        && sed -i "s/org\.netbeans\.lib\.profiler, org\.netbeans\.lib\.profiler.*/org\.netbeans\.lib\.profiler, org\.netbeans\.lib\.profiler\.\*, info\.novatec\.inspectit\.\*/" glassfish/config/osgi.properties

COPY run-with-inspectit.sh /run-with-inspectit.sh

VOLUME /opt/agent/active-config

CMD /run-with-inspectit.sh
