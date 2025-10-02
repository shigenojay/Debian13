#!/bin/bash

clear
GROUPNAME=nogroup
VERSION_ID=$(cat /etc/os-release | grep "VERSION_ID")
CHECKSYSTEM=$(tail -n +2 /etc/openvpn/server.conf | grep "^username-as-common-name")
# IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
# if [[ "$IP" = "" ]]; thenN
IP=$(wget -4qO- "http://whatismyip.akamai.com/")
#

# Color
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Menu
	clear
	echo ""
	echo ""
	echo -e "${GREEN}Script By :${NC}"
	echo "___________      .__       .__  __           "
		echo "\__    ___/______|__| ____ |__|/  |_ ___.__. "
		echo "  |    |  \_  __ \  |/    \|  \   __<   |  | "
		echo "  |    |   |  | \/  |   |  \  ||  |  \___  | "
		echo "  |____|   |__|  |__|___|  /__||__|  / ____| "
		echo "                         \/          \/      "
	echo "" 
	echo ""
	echo -e "	${BLUE}-=[ LISTS OF COMMAND ]=-${NC}"
	echo ""
	echo -e "${BLUE}01]${NC} Create New Account"
	echo -e "${BLUE}02]${NC} Remove Account"
	echo -e "${BLUE}03]${NC} Change Account Password"
	echo -e "${BLUE}04]${NC} Check Lists & Online Account"
	echo -e "${BLUE}05]${NC} Renew Expire Date Of Account"
	if [[ $CHECKSYSTEM ]]; then
		echo -e "${BLUE}06]${NC} Lock & Unlock Account"
	else
		echo -e "${BLUE}06]${NC} Lock & Unlock Account ${BLUE}Not available with current server.${NC}"
	fi
	echo -e "${BLUE}07]${NC} Check Data Usage Per User"
	echo -e "${BLUE}08]${NC} Check Server Bandwidth"
	echo -e "${BLUE}09]${NC} Restart OpenVPN & Squid Proxy"
	echo -e "${BLUE}10]${NC} Set Auto-Reboot"
	echo -e "${BLUE}11]${NC} Reboot VPS"
	echo -e "${BLUE}12]${NC} System Information & Benchmark"
	echo -e "${BLUE}13]${NC} Speedtest"
	echo ""
	echo -e "${BLUE}>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<< ${NC}"
	
	
# vnstat meter
if [[ -e /etc/vnstat.conf ]]; then
	INTERFACE=`vnstat -m | head -n2 | awk '{print $1}'`
	TOTALBW=$(vnstat -i $INTERFACE --nick local | grep "total:" | awk '{print $8" "substr ($9, 1, 1)}')
fi

ON=0
OFF=0
while read ONOFF
do
	ACCOUNT="$(echo $ONOFF | cut -d: -f1)"
	ID="$(echo $ONOFF | grep -v nobody | cut -d: -f3)"
	ONLINE="$(cat /etc/openvpn/openvpn-status.log | grep -Eom 1 $ACCOUNT | grep -Eom 1 $ACCOUNT)"
	if [[ $ID -ge 1000 ]]; then
		if [[ -z $ONLINE ]]; then
			OFF=$((OFF+1))
		else
			ON=$((ON+1))
		fi
		fi
done < /etc/passwd

echo -e "TOTAL BANDWIDTH ${CYAN}$TOTALBW${NC}${CYAN}B${NC}"
echo -e "ONLINE CLIENT/S ${GREEN}$ON${NC}"

echo ""
echo -e "${BLUE}>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<< ${NC}"
	read -p "Select Menu From [01-13] : " MENU

# Menu Lists

case $MENU in

	01) # ==================================================================================================================

	clear
	echo ""
	echo ""
	echo -e "${GREEN}Script By :${NC}"
	echo "___________      .__       .__  __           "
		echo "\__    ___/______|__| ____ |__|/  |_ ___.__. "
		echo "  |    |  \_  __ \  |/    \|  \   __<   |  | "
		echo "  |    |   |  | \/  |   |  \  ||  |  \___  | "
		echo "  |____|   |__|  |__|___|  /__||__|  / ____| "
		echo "                         \/          \/      "
	echo ""
	echo ""
	read -p "	Username : " -e CLIENT

	if [ $? -eq 0 ]; then
		read -p "	Password : " -e PASSWORD
		read -p "	Active Days? : " -e TimeActive
		
		useradd -e `date -d "$TimeActive days" +"%Y-%m-%d"` -s /bin/false -M $CLIENT
		EXP="$(chage -l $CLIENT | grep "Account expires" | awk -F": " '{print $2}')"
		echo -e "$PASSWORD\n$PASSWORD\n"|passwd $CLIENT &> /dev/null
		
		clear
	echo ""
	echo ""
	echo -e "${GREEN}Script By :${NC}"
	echo "___________      .__       .__  __           "
		echo "\__    ___/______|__| ____ |__|/  |_ ___.__. "
		echo "  |    |  \_  __ \  |/    \|  \   __<   |  | "
		echo "  |    |   |  | \/  |   |  \  ||  |  \___  | "
		echo "  |____|   |__|  |__|___|  /__||__|  / ____| "
		echo "                         \/          \/      "
	echo ""
	echo ""
		echo "---------------------------------------"
		echo "            ACCOUNT DETAILS            "
		echo "---------------------------------------" 
		echo "	Server IP : $IP"
		echo "	Username  : $CLIENT"
		echo "	Password  : $PASSWORD"
		echo "	Date Expired : $EXP"
		echo "---------------------------------------"
		echo ""
		exit
	else
		echo ""
		echo -e "${RED}Username Already Exists!${NC}"
		echo ""
		read -p "Back To Menu (Y or N) : " -e -i Y TOMENU

		if [[ "$TOMENU" = 'Y' ]]; then
			menu
			exit
		elif [[ "$TOMENU" = 'N' ]]; then
			exit
		fi
	fi

	
	;;

	02) # ==================================================================================================================
	
	clear
	echo ""
	echo ""
	echo -e "${GREEN}Script By :${NC}"
	echo "___________      .__       .__  __           "
		echo "\__    ___/______|__| ____ |__|/  |_ ___.__. "
		echo "  |    |  \_  __ \  |/    \|  \   __<   |  | "
		echo "  |    |   |  | \/  |   |  \  ||  |  \___  | "
		echo "  |____|   |__|  |__|___|  /__||__|  / ____| "
		echo "                         \/          \/      "
	echo ""
	echo ""
	echo ""
	read -p "Delete Username Account : " CLIENT
	
egrep "^$CLIENT" /etc/passwd >/dev/null

if [ $? -eq 0 ]; then
	if [[ $CHECKSYSTEM ]]; then
		echo ""
		userdel -f $CLIENT
		echo ""
		echo -e "Username ${BLUE}$CLIENT${NC} Successfully Removed!"
		echo ""
		exit
	else
		echo ""
		userdel -f $CLIENT
		cd /etc/openvpn/easy-rsa/
		./easyrsa --batch revoke $CLIENT
		EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
		rm -rf pki/reqs/$CLIENT.req
		rm -rf pki/private/$CLIENT.key
		rm -rf pki/issued/$CLIENT.crt
		rm -rf /etc/openvpn/crl.pem
		cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/crl.pem
		chown nobody:$GROUPNAME /etc/openvpn/crl.pem
		echo ""
		echo -e "Username ${BLUE}$CLIENT${NC} Successfully Removed!"
		echo ""
		exit
	fi
else
	echo ""
	echo "Account Name Doesn't Exits"
	echo ""
	exit
fi

	;;

	03) # ==================================================================================================================
	
	clear
	echo ""
	echo ""
	echo -e "${GREEN}Script By :${NC}"
	echo "___________      .__       .__  __           "
		echo "\__    ___/______|__| ____ |__|/  |_ ___.__. "
		echo "  |    |  \_  __ \  |/    \|  \   __<   |  | "
		echo "  |    |   |  | \/  |   |  \  ||  |  \___  | "
		echo "  |____|   |__|  |__|___|  /__||__|  / ____| "
		echo "                         \/          \/      "
	echo ""
	echo ""
	echo ""
	read -p "Username To Change Password : " CLIENTNAME
	egrep "^$CLIENTNAME" /etc/passwd >/dev/null

	if [ $? -eq 0 ]; then
		echo ""
		read -p "New Password : " NEWPASSWORD
		read -p "Retype Password : " RETYPEPASSWORD

		if [[ $NEWPASSWORD = $RETYPEPASSWORD ]]; then
    		echo ""
   		 echo ""
			echo "Password Successfully Changed!"
			echo ""
			echo "Username : $CLIENTNAME"
			echo "New Password : $NEWPASSWORD"
			echo ""
			echo ""
			exit
		else
			echo ""
			echo "Password Change Failed."
			echo "Confirming Passwords Does Not Match."
			echo ""
			exit
		fi
	else

		echo ""
		echo "No Account Specified In The System."
		echo ""
		read -p "Back To Menu  (Y or N) : " -e -i Y TOMENU

		if [[ "$TOMENU" = 'Y' ]]; then
			menu
			exit
		elif [[ "$TOMENU" = 'N' ]]; then
			exit
		fi
	fi

	;;

	04) # ==================================================================================================================

clear
echo ""
echo ""
echo ""
echo "ID  |  Username   |    Status     |    Expiry Date"
echo ""
C=1
ON=0
OFF=0
while read ONOFF
do
	CLIENTOFFLINE=$(echo -e "${RED}OFFLINE${NC}")
	CLIENTONLINE=$(echo -e "${GREEN}ONLINE${NC}")
	ACCOUNT="$(echo $ONOFF | cut -d: -f1)"
	ID="$(echo $ONOFF | grep -v nobody | cut -d: -f3)"
	EXP="$(chage -l $ACCOUNT | grep "Account expires" | awk -F": " '{print $2}')"
	ONLINE="$(cat /etc/openvpn/openvpn-status.log | grep -Eom 1 $ACCOUNT | grep -Eom 1 $ACCOUNT)"
	if [[ $ID -ge 1000 ]]; then
		if [[ -z $ONLINE ]]; then
			printf "%-6s %-15s %-20s %-3s\n" "$C" "$ACCOUNT" "$CLIENTOFFLINE" "$EXP"
			OFF=$((OFF+1))
		else
			printf "%-6s %-15s %-20s %-3s\n" "$C" "$ACCOUNT" "$CLIENTONLINE" "$EXP"
			ON=$((ON+1))
		fi
			C=$((C+1))
        fi
done < /etc/passwd
TOTAL="$(awk -F: '$3 >= '1000' && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo ""
echo ""
echo -e "ONLINE ${GREEN}$ON${NC}  |  OFFLINE ${RED}$OFF${NC}  |  Total Accounts ${CYAN}$TOTAL${NC}"
echo ""
exit

	;;

	05) # ==================================================================================================================

	clear
	echo ""
	echo ""
	echo -e "${GREEN}Script By :${NC}"
	echo "___________      .__       .__  __           "
		echo "\__    ___/______|__| ____ |__|/  |_ ___.__. "
		echo "  |    |  \_  __ \  |/    \|  \   __<   |  | "
		echo "  |    |   |  | \/  |   |  \  ||  |  \___  | "
		echo "  |____|   |__|  |__|___|  /__||__|  / ____| "
		echo "                         \/          \/      "
	echo ""
	echo ""
	read -p "Username to change the expiration date : " -e CLIENT

if [ $? -eq 0 ]; then
	EXP="$(chage -l $CLIENT | grep "Account expires" | awk -F": " '{print $2}')"
	echo ""
	echo -e "This account expires on ${BLUE}$EXP${NC}"
	echo ""
	read -p "	Active Days? : " -e TimeActive
	userdel $CLIENT
	useradd -e `date -d "$TimeActive days" +"%Y-%m-%d"` -s /bin/false -M $CLIENT
	EXP="$(chage -l $CLIENT | grep "Account expires" | awk -F": " '{print $2}')"
	echo -e "$CLIENT\n$CLIENT\n"|passwd $CLIENT &> /dev/null
    clear
	echo ""
	echo ""
	echo -e "${GREEN}Script By :${NC}"
	echo "___________      .__       .__  __           "
		echo "\__    ___/______|__| ____ |__|/  |_ ___.__. "
		echo "  |    |  \_  __ \  |/    \|  \   __<   |  | "
		echo "  |    |   |  | \/  |   |  \  ||  |  \___  | "
		echo "  |____|   |__|  |__|___|  /__||__|  / ____| "
		echo "                         \/          \/      "
	echo ""
	echo ""
    echo ""
	echo "	Account Name : $CLIENT"
	echo "	Date Expired : $EXP"
	echo ""
	echo ""
	exit

else

	echo ""
	echo "No Account Specified In The System."
	echo ""
	read -p "Back To Menu (Y or N) : " -e -i Y TOMENU

	if [[ "$TOMENU" = 'Y' ]]; then
		menu
		exit
	elif [[ "$TOMENU" = 'N' ]]; then
		exit
	fi
fi


	;;

	06) # ==================================================================================================================

	if [[ ! $CHECKSYSTEM ]]; then
	echo ""
	echo "Not available with current system"
	echo ""
	exit
fi

	clear
	echo ""
	echo ""
	echo -e "${GREEN}Script By :${NC}"
	echo "___________      .__       .__  __           "
		echo "\__    ___/______|__| ____ |__|/  |_ ___.__. "
		echo "  |    |  \_  __ \  |/    \|  \   __<   |  | "
		echo "  |    |   |  | \/  |   |  \  ||  |  \___  | "
		echo "  |____|   |__|  |__|___|  /__||__|  / ____| "
		echo "                         \/          \/      "
	echo ""
    echo ""
echo -e "${BLUE}Lock and Unlock User Accounts${NC} "
echo ""
echo -e "${BLUE}1]${NC} Lock User Account"
echo -e "${BLUE}2]${NC} Unlock User Account"
echo ""
read -p "Select [1 - 2] : " BandUB

case $BandUB in

	1)

echo ""
read -p "	Lock Username : " CLIENT

egrep "^$CLIENT" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
	echo "V=$CLIENT" >> /usr/local/bin/Ban-Unban
	passwd -l $CLIENT
	clear
	echo ""
	echo "Username $CLIENT Has Been Successfully LOCKED!"
	echo ""
	exit
elif [ $? -eq 1 ]; then
	clear
	echo ""
	echo "No account specified in the system"
	echo ""
	read -p "Back To Menu (Y or N) : " -e -i Y TOMENU

	if [[ "$TOMENU" = 'Y' ]]; then
		menu
		exit
	elif [[ "$TOMENU" = 'N' ]]; then
		exit
	fi
fi

	;;

	2)

echo ""
read -p "	Unlock Username : " CLIENT

egrep "^$CLIENT" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
	sed -i 's/V=$CLIENT/R=$CLIENT/g' /usr/local/bin/Ban-Unban
	passwd -u $CLIENT
	clear
	echo ""
	echo "Username $CLIENT Has Been Successfully UNLOCKED!"
	echo ""
	exit

elif [ $? -eq 1 ]; then
	clear
	echo ""
	echo "No account specified in the system"
	echo ""
	read -p "Back To Menu (Y or N) : " -e -i Y TOMENU

	if [[ "$TOMENU" = 'Y' ]]; then
		menu
		exit
	elif [[ "$TOMENU" = 'N' ]]; then
		exit
	fi
fi

	;;

esac 

	;;

	07) # ==================================================================================================================

	if [[ ! -e /usr/local/bin/Banwidth-Per-Client ]]; then
	apt-get install python
	wget -O /usr/local/bin/Banwidth-Per-Client "http://128.199.215.79/Banwidth-Per-Client"
	chmod +x /usr/local/bin/Banwidth-Per-Client
	clear
	echo ""
	Banwidth-Per-Client
	echo ""
else
	clear
	echo ""
	Banwidth-Per-Client
	echo ""
fi
	
	;;

	08) # ==================================================================================================================

INTERFACE=`ifconfig | head -n1 | awk '{print $1}' | cut -d ':' -f 1`
TODAY=$(vnstat -i $INTERFACE | grep "today" | awk '{print $8" "substr ($9, 1, 1)}')
YESTERDAY=$(vnstat -i $INTERFACE | grep "yesterday" | awk '{print $8" "substr ($9, 1, 1)}')
WEEK=$(vnstat -i $INTERFACE -w | grep "current week" | awk '{print $9" "substr ($10, 1, 1)}')
RXWEEK=$(vnstat -i $INTERFACE -w | grep "current week" | awk '{print $3" "substr ($10, 1, 1)}')
TXWEEK=$(vnstat -i $INTERFACE -w | grep "current week" | awk '{print $6" "substr ($10, 1, 1)}')
MOUNT=$(vnstat -i $INTERFACE | grep "`date +"%b '%y"`" | awk '{print $9" "substr ($10, 1, 1)}')
RXMOUNT=$(vnstat -i $INTERFACE | grep "`date +"%b '%y"`" | awk '{print $3" "substr ($10, 1, 1)}')
TXMOUNT=$(vnstat -i $INTERFACE | grep "`date +"%b '%y"`" | awk '{print $6" "substr ($10, 1, 1)}')
TOTAL=$(vnstat -i $INTERFACE | grep "total:" | awk '{print $8" "substr ($9, 1, 1)}')
RXTOTAL=$(vnstat -i $INTERFACE | grep "rx:" | awk '{print $2" "substr ($9, 1, 1)}')
TXTOTAL=$(vnstat -i $INTERFACE | grep "tx:" | awk '{print $5" "substr ($9, 1, 1)}')

	clear
	echo ""
	echo ""
	echo -e "${GREEN}Script By :${NC}"
	echo "___________      .__       .__  __           "
		echo "\__    ___/______|__| ____ |__|/  |_ ___.__. "
		echo "  |    |  \_  __ \  |/    \|  \   __<   |  | "
		echo "  |    |   |  | \/  |   |  \  ||  |  \___  | "
		echo "  |____|   |__|  |__|___|  /__||__|  / ____| "
		echo "                         \/          \/      "
	echo ""
    echo ""
	echo -e "	${BLUE}-=[ DATA USAGE DETAILS ]=-${NC}"
	echo ""
	echo ""
	echo -e "Today ${GREEN}$TODAY${NC}"
	echo -e "Yesterday ${BLUE}$YESTERDAY${NC}"
	echo ""
	echo "DATA USAGE PER WEEK"
	echo -e "Recieved ${BLUE}$RXWEEK${NC} | Transmit ${BLUE}$TXWEEK${NC}"
	echo -e "This Week ${CYAN}$WEEK${NC}"
	echo ""
	echo "DATA USAGE PER MONTH"
	echo -e "Recieved ${BLUE}$RXMOUNT${NC} | Transmit ${BLUE}$TXMOUNT${NC}"
	echo -e "This Month ${CYAN}$MOUNT${NC}"
	echo ""
	echo "TOTAL DATA USAGE"
	echo -e "Recieved ${BLUE}$RXTOTAL${NC} | Transmit ${BLUE}$TXTOTAL${NC}"
	echo -e "Total Data Usage ${CYAN}$TOTAL${NC}"
	echo ""
	exit

	;;

	09) # ==================================================================================================================

	/etc/init.d/openvpn restart
	/etc/init.d/squid restart

	;;

	10) # ==================================================================================================================

if [ ! -e /usr/local/bin/auto_reboot ]; then
echo '#!/bin/bash' > /usr/local/bin/auto_reboot 
echo 'tanggal=$(date +"%m-%d-%Y")' >> /usr/local/bin/auto_reboot 
echo 'waktu=$(date +"%T")' >> /usr/local/bin/auto_reboot 
echo 'echo "Server successfully rebooted on $tanggal hit $waktu." >> /root/log-reboot.txt' >> /usr/local/bin/auto_reboot 
echo '/sbin/shutdown -r now' >> /usr/local/bin/auto_reboot 
chmod +x /usr/local/bin/auto_reboot
fi
	clear
	echo ""
	echo ""
	echo -e "${GREEN}Script By :${NC}"
	echo "___________      .__       .__  __           "
		echo "\__    ___/______|__| ____ |__|/  |_ ___.__. "
		echo "  |    |  \_  __ \  |/    \|  \   __<   |  | "
		echo "  |    |   |  | \/  |   |  \  ||  |  \___  | "
		echo "  |____|   |__|  |__|___|  /__||__|  / ____| "
		echo "                         \/          \/      "
	echo ""
	echo ""
echo ""
echo -e "	${BLUE}-=[System Auto Reboot Menu]=-${NC}"
echo ""
echo -e "${BLUE}1]${NC} Set Auto-Reboot Every 1 Hour"
echo -e "${BLUE}2]${NC} Set Auto-Reboot Every 6 Hours"
echo -e "${BLUE}3]${NC} Set Auto-Reboot Every 12 Hours"
echo -e "${BLUE}4]${NC} Set Auto-Reboot Once a Day"
echo -e "${BLUE}5]${NC} Set Auto-Reboot Once a Week"
echo -e "${BLUE}6]${NC} Set Auto-Reboot Once a Month"
echo -e "${BLUE}7]${NC} Turn off Auto-Reboot"
echo -e "${BLUE}8]${NC} View reboot log"
echo -e "${BLUE}9]${NC} Remove reboot log"
echo "-------------------------------------------"
read -p "Select Options From (1-9): " x

if test $x -eq 1; then
echo "10 * * * * root /usr/local/bin/auto_reboot" > /etc/cron.d/auto_reboot
echo "Auto-Reboot has been set every an hour."
elif test $x -eq 2; then
echo "10 */6 * * * root /usr/local/bin/auto_reboot" > /etc/cron.d/auto_reboot
echo "Auto-Reboot has been successfully set every 6 hours."
elif test $x -eq 3; then
echo "10 */12 * * * root /usr/local/bin/auto_reboot" > /etc/cron.d/auto_reboot
echo "Auto-Reboot has been successfully set every 12 hours."
elif test $x -eq 4; then
echo "10 0 * * * root /usr/local/bin/auto_reboot" > /etc/cron.d/auto_reboot
echo "Auto-Reboot has been successfully set once a day."
elif test $x -eq 5; then
echo "10 0 */7 * * root /usr/local/bin/auto_reboot" > /etc/cron.d/auto_reboot
echo "Auto-Reboot has been successfully set once a week."
elif test $x -eq 6; then
echo "10 0 1 * * root /usr/local/bin/auto_reboot" > /etc/cron.d/auto_reboot
echo "Auto-Reboot has been successfully set once a month."
elif test $x -eq 7; then
rm -f /etc/cron.d/auto_reboot
echo "Auto-Reboot successfully TURNED OFF."
elif test $x -eq 8; then
if [ ! -e /root/log-reboot.txt ]; then
	echo "No reboot activity found"
	else 
	echo 'LOG REBOOT'
	echo "-------"
	cat /root/log-reboot.txt
fi
elif test $x -eq 9; then
echo "" > /root/log-reboot.txt
echo "Auto Reboot Log successfully deleted!"
else
echo "Options Not Found In Menu"
exit
fi
	
	;;
	
	
	11) # ==================================================================================================================

	reboot
	
	;;

	12) # ==================================================================================================================

	wget -qO- bench.sh | bash
	
	;;

	13) # ==================================================================================================================

	speedtest --share
	
	;;
	
esac
