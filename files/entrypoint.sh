#!/bin/bash

_link() {
  if [[ -L ${2} && $(readlink ${2}) == ${1} ]]; then
    return 0
  fi
  if [[ ! -e ${1} ]]; then
    if [[ -d ${2} ]]; then
      mkdir -p "${1}"
      pushd ${2} &>/dev/null
      find . -type f -exec cp --parents '{}' "${1}/" \;
      popd &>/dev/null
    elif [[ -f ${2} ]]; then
      if [[ ! -d $(dirname ${1}) ]]; then
        mkdir -p $(dirname ${1})
      fi
      cp -f "${2}" "${1}"
    else
      mkdir -p "${1}"
    fi
  fi
  if [[ -d ${2} ]]; then
    rm -rf "${2}"
  elif [[ -f ${2} || -L ${2} ]]; then
    rm -f "${2}"
  fi
  if [[ ! -d $(dirname ${2}) ]]; then
    mkdir -p $(dirname ${2})
  fi
  ln -sf ${1} ${2}
}

# Update the timezone
[[ -n "$TZ" ]] && echo "$TZ" > /etc/timezone

# move binaries and lang files out of container so crashplan can be upgrade automaticaly
_link /var/crashplan/lib  /usr/local/crashplan/lib
_link /var/crashplan/lang /usr/local/crashplan/lang

# move identity out of container, this prevent having to adopt account every time you rebuild the Docker
_link /var/crashplan/id /var/lib/crashplan

# move cache directory out of container, this prevents re-synchronization every time you rebuild the Docker
_link /var/crashplan/cache /usr/local/crashplan/cache

# move log directory out of container
_link /var/crashplan/log /usr/local/crashplan/log

# move conf directory out of container
if [[ ! -f /var/crashplan/conf/default.service.xml ]]; then
    rm -rf /var/crashplan/conf
fi
_link /var/crashplan/conf /usr/local/crashplan/conf

# move run.conf out of container
# adjust RAM as described here: http://support.code42.com/CrashPlan/Latest/Troubleshooting/CrashPlan_Runs_Out_Of_Memory_And_Crashes
_link /var/crashplan/bin/run.conf /usr/local/crashplan/bin/run.conf

TARGETDIR=/usr/local/crashplan

if [[ -z "$PUBLIC_IP" || -z "$PUBLIC_PORT" ]]; then
    # Default values :(
    PUBLIC_IP=0.0.0.0
    PUBLIC_PORT=4242
fi
# Change the public ip/port dynamicaly
if [[ -f "$TARGETDIR"/conf/my.service.xml ]]; then
    echo "Configuring CrashPlan to listen on public interface $PUBLIC_IP:$PUBLIC_PORT"
    sed -i -r "s/<location>[^<]+/<location>$PUBLIC_IP:$PUBLIC_PORT/g" "$TARGETDIR"/conf/my.service.xml
fi

exec "$@"
