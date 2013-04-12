#!/bin/bash
##############################################################################
# Bash script written by Vahid Hedayati April 2013
##############################################################################
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
##############################################################################
DATE=$(date +%c)

NAGIOS_STATUS="/var/nagios/status.dat"
WORKING_DIR="/usr/local/bin"


SUBJECT="Disabled Nagios notifications on $(hostname -s) *** $DATE"
from="sender@domain.com"
SENDMAIL_FOLDER="$WORKING_DIR/sendmail"
RCPT="reciever@domain.com"
BODY="$HOST $SERVICE"

userpass="nagiosadmin:password"
nagios_server="nagios.server.yourdomain.com"


function host_status() { 
awk -v user=$userpass -v server=$nagios_server 'BEGIN { header=0; FS="="; } 
/^[[:space:]]*info {[[:space:]]*$/ { codeblock="info"; } 
/^[[:space:]]*program {[[:space:]]*$/ { codeblock="program"; } 
/^[[:space:]]*hoststatus {[[:space:]]*$/ || /^[[:space:]]*host {[[:space:]]*$/  { codeblock="host"; host_name=""; notifications_enabled=""; } 
/^[[:space:]]*service {[[:space:]]*$/ { codeblock="service"; }
/^[[:space:]]*host_name=/ { host_name=$2; } 
/^[[:space:]]*notifications_enabled=/ { notifications_enabled=$2; } 
/^[[:space:]]*}[[:space:]]*$/ { 
		if (codeblock=="host" && notifications_enabled=="0") { 
			if (header==0) { 
				print "<tr><td colspan=2 bgcolor=red><font color=white><b>The following hosts have notifications disabled:</font></b></td></tr>"; header=1; } 
				print "<tr><td>"host_name"</td><td><a href=\"http://"user"@"server"/nagios/cgi-bin/cmd.cgi?cmd_typ=28&cmd_mod=2&host="host_name"&btnSubmit=Commit\">ENABLE NOTIFICATION</a></td></t>"; 
		} 
	}' 

}


function service_status() { 
awk -v user=$userpass -v server=$nagios_server 'BEGIN { header=0; FS="="; } 
/^[[:space:]]*info {[[:space:]]*$/ { codeblock="info"; } 
/^[[:space:]]*program {[[:space:]]*$/ { codeblock="program"; } 
/^[[:space:]]*hoststatus {[[:space:]]*$/ { codeblock="host"; } 
/^[[:space:]]*servicestatus {[[:space:]]*$/ || /^[[:space:]]*service {[[:space:]]*$/ { codeblock="service"; host_name=""; service_description=""; notifications_enabled=""; } 
/^[[:space:]]*host_name=/ { host_name=$2; } 
/^[[:space:]]*service_description=/ { service_description=$2; } 
/^[[:space:]]*notifications_enabled=/ { notifications_enabled=$2; } 
/^[[:space:]]*}[[:space:]]*$/ { 
		if (codeblock=="service" && notifications_enabled=="0") { 
			if (header==0) { 
				print "<tr><td colspan=2 bgcolor=red><font color=white>The following services have notifications turned off</font></b></td></tr>"; header=1; } 
				print "<tr><td>"service_description " on " host_name"</td><td><a href=\"http://"user"@"server"/nagios/cgi-bin/cmd.cgi?cmd_typ=22&cmd_mod=2&host="host_name"&service="service_description"&btnSubmit=Commit\">ENABLE SERVICE NOTIFICATION</a></td></tr>"; 
		} 
	} '
}

function active_checks() { 
awk -v user=$userpass -v server=$nagios_server 'BEGIN { header=0; FS="="; } 
/^[[:space:]]*info {[[:space:]]*$/ { codeblock="info"; } 
/^[[:space:]]*program {[[:space:]]*$/ { codeblock="program"; } 
/^[[:space:]]*hoststatus {[[:space:]]*$/ { codeblock="host"; } 
/^[[:space:]]*servicestatus {[[:space:]]*$/ { codeblock="service"; host_name=""; service_description=""; notifications_enabled=""; activechecks="";} 
/^[[:space:]]*host_name=/ { host_name=$2; } 
/^[[:space:]]*service_description=/ { service_description=$2; } 
/^[[:space:]]*notifications_enabled=/ { notifications_enabled=$2; } 
/^[[:space:]]*active_checks_enabled=/ { activechecks=$2; }
/^[[:space:]]*}[[:space:]]*$/ { 
		if (codeblock=="service" && activechecks=="0") { 
			if (header==0) { 
 				print "<tr><td colspan=2 bgcolor=red><font color=white>The following services have Active checks turned off</font></b></td></tr>";  header=1; }
				print "<tr><td>"service_description " on " host_name"</td><td><a href=\"http://"user"@"server"/nagios/cgi-bin/cmd.cgi?cmd_typ=5&host="host_name"&service="service_description"&btnSubmit=Commit\">ENABLE ACTIVE CHECKS</a></td></tr>"; 
		}
 	}'
}




HOST=$(/bin/cat $NAGIOS_STATUS| host_status)
SERVICE=$(/bin/cat $NAGIOS_STATUS |service_status)
ACTIVE_CHECKS=$(/bin/cat $NAGIOS_STATUS |active_checks)

if [[ -n $HOST || -n $SERVICE || -n $ACTIVE_CHECKS ]]; then
 	cd $SENDMAIL_FOLDER;./sendmail.pl "$WORKING_DIR" "$from" "$RCPT" "$SUBJECT:" "<table>$SERVICE<br>$HOST<br>$ACTIVE_CHECKS</table>"
else
	echo "Nothing is disabled..."
fi 
