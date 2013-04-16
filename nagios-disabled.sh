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

#NAGIOS_STATUS="/var/nagios/status.dat"
#NAGIOS_STATUS="/usr/local/nagios/var/status.dat"
NAGIOS_STATUS="/var/cache/nagios3/status.dat"
WORKING_DIR="/usr/local/bin"

SUBJECT="Disabled Nagios notifications on $(hostname -s) *** $DATE"
from="sender@domain.com"
SENDMAIL_FOLDER="$WORKING_DIR/sendmail"
RCPT="reciever@domain.com"


userpass="nagiosadmin:password"
nagios_server="nagios.server.yourdomain.com"


function run_awk() {
awk -v user=$userpass -v server=$nagios_server 'BEGIN { header1=0; header2=0; header3=0;  FS="="; }
/^[[:space:]]*info {[[:space:]]*$/ { codeblock="info"; }
/^[[:space:]]*program {[[:space:]]*$/ { codeblock="program"; }
/^[[:space:]]*hoststatus {[[:space:]]*$/ || /^[[:space:]]*host {[[:space:]]*$/ { codeblock="host";  host_name=""; host_notifications=""; host_active=""; }
/^[[:space:]]*servicestatus {[[:space:]]*$/ || /^[[:space:]]*service {[[:space:]]*$/ { codeblock="service";  service_description=""; service_notifications=""; service_active=""; }
/^[[:space:]]*servicedowntime {[[:space:]]*$/  { codeblock="servicedowntime";  down_start=""; down_end=""; down_comment=""; }
/^[[:space:]]*host_name=/ { host_name=$2; }
/^[[:space:]]*start_time=/ { if (codeblock=="servicedowntime")   { down_start=$2; dstart=strftime("%d-%m-%y %H-%M-%S",down_start);} }
/^[[:space:]]*end_time=/ { if (codeblock=="servicedowntime")   { down_end=$2;  dend=strftime("%d-%m-%y %H-%M-%S",down_end);} }
/^[[:space:]]*duration=/ { if (codeblock=="servicedowntime")   { down_period=$2;  dtime=(down_period / 60); } }
/^[[:space:]]*comment=/ { if (codeblock=="servicedowntime")   { down_comment=$2; } }
/^[[:space:]]*service_description=/ { if ( (codeblock=="service") || (codeblock=="servicedowntime"))  { service_description=$2;} }
/^[[:space:]]*notifications_enabled=/ { if (codeblock=="service") { service_notifications=$2;  } else if (codeblock=="host") { host_notifications=$2;} }
/^[[:space:]]*active_checks_enabled=/ { if (codeblock=="service") { service_active=$2;} else if (codeblock=="host") { host_active=$2;  } }

/^[[:space:]]*}[[:space:]]*$/ {
        if (codeblock=="host") {
                if (header1==0) {
                        print "<tr><td colspan=2 bgcolor=green><b><font color=white><b>The following hosts have Notifications/Active Checks disabled:</font></b></td></tr>";
                        header1=1;
                }
                if (host_notifications=="0") {
                        print "<tr bgcolor=#CCCCCC><td>"host_name"</td><td><a href=\"http://"user"@"server"/nagios/cgi-bin/cmd.cgi?cmd_typ=28&cmd_mod=2&host="host_name"&btnSubmit=Commit\">ENABLE NOTIFICATION on "host_name"</a></td></t>";
                }
                if (host_active=="0") {
                        print "<tr><td>"host_name"</td><td><a href=\"http://"user"@"server"/nagios/cgi-bin/cmd.cgi?cmd_typ=47&host="host_name"&btnSubmit=Commit\">ENABLE ACTIVE CHECK on "host_name"</a></td></t>\n";
                }
        }

        if (codeblock=="servicedowntime") {
                if (header2==0) {
                        print "<tr><td colspan=2 bgcolor=green><b><font color=white><b>The following hosts have been scheduled for downtime:</font></b></td></tr>";
                        header2=1;
                }
                print "<tr bgcolor=#CCFFCC><td>"host_name"</td><td>"service_description": "dstart " to " dend" [ ("dtime") minutes ] by:" down_comment"</td></tr>";
        }
        if (codeblock=="service") {
                if (header3==0) {
                        print "<tr><td colspan=2 bgcolor=red><b><font color=white>The following services have Notifications/Active checks turned off</font></b></td></tr>";
                        header3=1;
                }
                if (service_active=="0") {
                        print "<tr><td>"service_description " on " host_name"</td><td><a href=\"http://"user"@"server"/nagios/cgi-bin/cmd.cgi?cmd_typ=5&host="host_name"&service="service_description"&btnSubmit=Commit\">ENABLE ACTIVE CHECKS</a></td></tr>";
                }
                if (service_notifications=="0") {
                        print "<tr bgcolor=#CCCCCC><td>"service_description " on " host_name"</td><td><a href=\"http://"user"@"server"/nagios/cgi-bin/cmd.cgi?cmd_typ=22&cmd_mod=2&host="host_name"&service="service_description"&btnSubmit=Commit\">ENABLE SERVICE NOTIFICATION</a></td></tr>";
                }
        }

   }'
}



RESULT=$(/bin/cat $NAGIOS_STATUS| run_awk)
if [[ -n $RESULT ]]; then
  	cd $SENDMAIL_FOLDER;./sendmail.pl "$WORKING_DIR" "$from" "$RCPT" "$SUBJECT:" "<table>$RESULT</table>"
else
	echo "Nothing is disabled..."
fi 
