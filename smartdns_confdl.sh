#!/bin/bash

# Function to transform gfwlist and copy to smartdns domain sets
tr_gfwlist()
{
	base64 -d gfwlist.txt > gfwlist_decoded.txt
	grep -v "@@" ./gfwlist_decoded.txt | grep -E -o "(([a-z0-9A-Z])+(-)*([a-z0-9A-Z])+\.)+([a-zA-Z]){2,6}" | sed 's/^\.//' | sort | uniq -u > ./gfwlist_domains.txt
	echo "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] GFW domains saved to gfwlist_domains.txt." >> /var/log/smartdns/smartdns.log
	cp -rf ./gfwlist_domains.txt /etc/smartdns/domain-set/gfw.conf
	echo "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] GFW domains copied to domain sets. Cleaning up..." >> /var/log/smartdns/smartdns.log
	rm -f ./gfwlist.txt ./gfwlist_decoded.txt ./gfwlist_domains.txt
}

# Function to transform dnsmasq-china-conf and copy to smartdns domain sets
tr_chinalist()
{
	grep -E -o "(([a-z0-9A-Z])+(-)*([a-z0-9A-Z])+\.)+([a-zA-Z]){2,6}" ./chinalist.txt | sort | uniq -u > ./chinalist_domains.txt
	echo "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] China domains saved to chinalist_domains.txt." >> /var/log/smartdns/smartdns.log
	cp -rf ./chinalist_domains.txt /etc/smartdns/domain-set/china.conf
	echo "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] China domains copied to domain sets. Cleaning up..." >> /var/log/smartdns/smartdns.log
	rm -f ./chinalist.txt ./chinalist_domains.txt
}

# Download GFWList

wget --tries=2 -O gfwlist.txt https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt
if [ $? -ne 0 ]; then
        echo "[$(date "+%Y-%m-%d %H:%M:%S")][ERROR] download gfwlist from Github failed, retry other sources..."
	wget --tries=2 -O gfwlist.txt https://gitlab.com/gfwlist/gfwlist/raw/master/gfwlist.txt
 	if [ $? -ne 0 ]; then
		echo "[$(date "+%Y-%m-%d %H:%M:%S")][ERROR] download gfwlist from Gitlab failed, retry other sources..."
		wget --tries=2 -O gfwlist.txt https://bitbucket.org/gfwlist/gfwlist/raw/HEAD/gfwlist.txt
		if [ $? -ne 0 ]; then
			echo "[$(date "+%Y-%m-%d %H:%M:%S")][ERROR] All gfwlist sources failed." >> /var/log/smartdns/smartdns.log
		else
			echo "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] gfwlist downloaded. Extracting to domain sets..." >> /var/log/smartdns/smartdns.log
			tr_gfwlist
		fi
	else
		echo "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] gfwlist downloaded. Extracting to domain sets..." >> /var/log/smartdns/smartdns.log
		tr_gfwlist
	fi
else
	echo "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] gfwlist downloaded. Extracting to domain sets..." >> /var/log/smartdns/smartdns.log
	tr_gfwlist
fi


# Download China List
wget --tries=2 -O chinalist.txt https://github.com/felixonmars/dnsmasq-china-list/raw/master/accelerated-domains.china.conf
if [ $? -ne 0 ]; then
	echo "[$(date "+%Y-%m-%d %H:%M:%S")][ERROR] download chinalist from Github failed, retry other sources..."
	wget --tries=2 -O chinalist.txt https://gitee.com/felixonmars/dnsmasq-china-list/raw/master/accelerated-domains.china.conf
	if [ $? -ne 0 ]; then
		echo "[$(date "+%Y-%m-%d %H:%M:%S")][ERROR] All china list sources failed." >> /var/log/smartdns/smartdns.log
	else
		echo "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] chinalist downloaded. Extracting to domain sets..." >> /var/log/smartdns/smartdns.log
		tr_chinalist
	fi
else
	echo "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] chinalist downloaded. Extracting to domain sets..." >> /var/log/smartdns/smartdns.log
	tr_chinalist
fi
