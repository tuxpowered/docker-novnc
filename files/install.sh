#!/bin/sh
set -e

# Determine Crashplan Service Level to install (home or business)
if [ "$CRASHPLAN_SERVICE" = "PRO" ]; then
    SVC_LEVEL="CrashPlanPRO"
else
    SVC_LEVEL="CrashPlan"
fi

mkdir /tmp/crashplan
if [ -n "${CRASHPLAN_INSTALLER}" ]; then
    wget -O- ${CRASHPLAN_INSTALLER} | tar -xz --strip-components=1 -C /tmp/crashplan
else
    wget -O- http://download.code42.com/installs/linux/install/${SVC_LEVEL}/${SVC_LEVEL}_${CRASHPLAN_VERSION}_Linux.tgz \
    | tar -xz --strip-components=1 -C /tmp/crashplan
fi

mkdir -p /usr/share/applications

cd /tmp/crashplan && mv /crashplan.exp /tmp/crashplan && sync && /tmp/crashplan/crashplan.exp || exit $?
rm -rf /usr/share/applications

# Bind the UI port 4243 to the container ip
sed -i "s|</servicePeerConfig>|</servicePeerConfig>\n\t<serviceUIConfig>\n\t\t\
<serviceHost>0.0.0.0</serviceHost>\n\t\t<servicePort>4243</servicePort>\n\t\t\
<connectCheck>0</connectCheck>\n\t\t<showFullFilePath>false</showFullFilePath>\n\t\
</serviceUIConfig>|g" /usr/local/crashplan/conf/default.service.xml

# Remove unneccessary files and directories
rm -rf /usr/local/crashplan/jre/lib/plugin.jar \
   /usr/local/crashplan/jre/lib/ext/jfxrt.jar \
   /usr/local/crashplan/jre/bin/javaws \
   /usr/local/crashplan/jre/lib/javaws.jar \
   /usr/local/crashplan/jre/lib/desktop \
   /usr/local/crashplan/jre/plugin \
   /usr/local/crashplan/jre/lib/deploy* \
   /usr/local/crashplan/jre/lib/*javafx* \
   /usr/local/crashplan/jre/lib/*jfx* \
   /usr/local/crashplan/jre/lib/amd64/libdecora_sse.so \
   /usr/local/crashplan/jre/lib/amd64/libprism_*.so \
   /usr/local/crashplan/jre/lib/amd64/libfxplugins.so \
   /usr/local/crashplan/jre/lib/amd64/libglass.so \
   /usr/local/crashplan/jre/lib/amd64/libgstreamer-lite.so \
   /usr/local/crashplan/jre/lib/amd64/libjavafx*.so \
   /usr/local/crashplan/jre/lib/amd64/libjfx*.so

# rm -rf /boot /lost+found /media /mnt /run /srv
rm -rf /usr/local/crashplan/log
rm -rf /var/lib/apt/lists/*
