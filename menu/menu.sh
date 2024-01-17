#!/bin/bash
echo -e [1] Show All Xray Log
echo -e [2] Show Xray Log User
read -p "Select Menu : "  opt
case $opt in
1) clear ; tail -f /var/lib/marzban/access.log ;;
2) clear ; xraylog ;;
esac
