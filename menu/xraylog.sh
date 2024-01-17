#!/bin/bash
read -rp "input: " keyword
tail -f /var/lib/marzban/access.log | grep $keyword