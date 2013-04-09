nagios-disable-host-notification
================================

Updated script for nagios disabled host notifications

Please refer to http://exchange.nagios.org/directory/Addons/Notifications/*-Notification-Managers/Disabled-host-and-service-notification-parser/details

I have updated this script into an all in one

/etc/crontab entry:

30 08,16 * * * root /usr/local/bin/nagios-disabled.sh >/dev/null 2>&1
