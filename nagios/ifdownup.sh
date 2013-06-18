#!/bin/bash 
# dmjp: http://nagios.sourceforge.net/docs/nagioscore/3/en/eventhandlers.html

# functions
kick_it() {
   LOCK=/etc/nagios/kick_it.$1.lock

   if [[ -e $LOCK ]]; then
      echo "$LOCK exists, so not kicking $1"
   else
      echo "locking $LOCK for $1 kick-off"
      ( /bin/touch $LOCK ; 
        /sbin/dhclient -r -v $1 ; \
        /usr/sbin/ifdown $1 ; \
        /usr/sbin/ifup $1 ; \
        /usr/sbin/iwconfig $1 power off ; \
        /usr/bin/systemctl restart openvpn@client.service ; \
        /bin/rm -fv $LOCK ) &
   fi
}

# What is the state?
case "$1" in
OK)
	# The service just came back up, so don't do anything...
	;;
WARNING)
	# We don't really care about warning states, since the service is probably still running...
	;;

UNKNOWN)
	# We don't know what might be causing an unknown error, so don't do anything...
	;;
CRITICAL)
	# Aha!
	echo -n "Restarting $4..."
        kick_it $4
	;;
esac

exit 0

