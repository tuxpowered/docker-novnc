FROM ubuntu:trusty
MAINTAINER Me <vwjettadude@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive \
    CRASHPLAN_VERSION=5.3.0 \
    CRASHPLAN_SERVICE=Code42CrashPlan \
    CRASHPLAN_INSTALLER=http://hosted.dfatech.ca:4280/client/installers/Code42CrashPlan_5.3.0_1452924000530_344_Linux.tgz \
    LC_ALL=C.UTF-8  \
    LANG=C.UTF-8    \
    LANGUAGE=C.UTF-8

ADD /files /

RUN apt-get update -y && \
    apt-get install -y git x11vnc wget python python-numpy unzip Xvfb firefox openbox geany menu \
        libnotify4 libgconf-2-4 libnss3 expect && \
    cd /root && git clone https://github.com/kanaka/noVNC.git && \
    cd noVNC/utils && git clone https://github.com/kanaka/websockify websockify && \
    cd /root && \
    chmod 0755 /start_novnc.sh && \
    chmod 0755 /entrypoint.sh && \
    chmod 0755 /crashplan.sh && \
    chmod 0755 /installcrashplan.sh && \
    
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

VOLUME [ "/var/crashplan", "/storage" ]

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/crashplan.sh"]

EXPOSE 6080 4243 4242
