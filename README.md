nagios-disable-host-notification
================================

Updated script for nagios disabled host notifications

Please refer to http://exchange.nagios.org/directory/Addons/Notifications/*-Notification-Managers/Disabled-host-and-service-notification-parser/details


# WHAT WILL THIS SCRIPT DO? 
# nagios-host-service-dtime-notification-parses.sh will send an email alert if:
# 1. HOSTS: With Active or Notifications disabled
# 2. HOSTS: that have been scheduled for downtime
# 3. SERVICES: With Active or Notifications disabled
# 4. SERVICES: that have been scheduled for downtime

The email will be in HTML format and will contain links to evey disabled type of service/host with a clickable enable button next to the host or services. 
The HTML colours are questionable and ofcourse you can change it a better quality I prefer colourful output :)



# /etc/crontab entry:

30 08,16 * * * root /usr/local/bin/nagios-disabled.sh >/dev/null 2>&1

# Very recommended to go hand in hand with this project: https://github.com/vahidhedayati/nagalert  
