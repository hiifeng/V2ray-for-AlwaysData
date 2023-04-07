#!/bin/bash
#############################################################
#
# V2ray for Alwaysdata.com
# Author: ifeng, <https://t.me/HiaiFeng>
# Web Site: https://www.hicairo.com
#
#############################################################

TMP_DIRECTORY=$(mktemp -d)

UUID=$(grep -o 'UUID=[^ ]*' $HOME/admin/config/apache/sites.conf | sed 's/UUID=//')
VMESS_WSPATH=$(grep -o 'VMESS_WSPATH=[^ ]*' $HOME/admin/config/apache/sites.conf | sed 's/VMESS_WSPATH=//')
VLESS_WSPATH=$(grep -o 'VLESS_WSPATH=[^ ]*' $HOME/admin/config/apache/sites.conf | sed 's/VLESS_WSPATH=//')

UUID=${UUID:-'de04add9-5c68-8bab-950c-08cd5320df18'}
VMESS_WSPATH=${VMESS_WSPATH:-'/vmess'}
VLESS_WSPATH=${VLESS_WSPATH:-'/vless'}
URL=${USER}.alwaysdata.net

wget -q -O $TMP_DIRECTORY/config.json https://raw.githubusercontent.com/hiifeng/V2ray-for-Doprax/main/config.json
wget -q -O $TMP_DIRECTORY/v2ray-linux-64.zip https://github.com/v2fly/v2ray-core/releases/download/v4.45.0/v2ray-linux-64.zip
unzip -oq -d $HOME $TMP_DIRECTORY/v2ray-linux-64.zip v2ray v2ctl geoip.dat geosite.dat geoip-only-cn-private.dat

sed -i "s#UUID#$UUID#g;s#VMESS_WSPATH#$VMESS_WSPATH#g;s#VLESS_WSPATH#$VLESS_WSPATH#g;s#10000#8300#g;s#20000#8400#g;s#127.0.0.1#0.0.0.0#g" $TMP_DIRECTORY/config.json
cp $TMP_DIRECTORY/config.json $HOME
rm -rf $HOME/admin/tmp/*.*

Advanced_Settings=$(cat <<-EOF
#UUID=${UUID}
#VMESS_WSPATH=${VMESS_WSPATH}
#VLESS_WSPATH=${VLESS_WSPATH}

ProxyRequests off
ProxyPreserveHost On
ProxyPass "${VMESS_WSPATH}" "ws://services-${USER}.alwaysdata.net:8300${VMESS_WSPATH}"
ProxyPassReverse "${VMESS_WSPATH}" "ws://services-${USER}.alwaysdata.net:8300${VMESS_WSPATH}"
ProxyPass "${VLESS_WSPATH}" "ws://services-${USER}.alwaysdata.net:8400${VLESS_WSPATH}"
ProxyPassReverse "${VLESS_WSPATH}" "ws://services-${USER}.alwaysdata.net:8400${VLESS_WSPATH}"
EOF
)

vmlink=vmess://$(echo -n "{\"v\":\"2\",\"ps\":\"hicairo.com\",\"add\":\"$URL\",\"port\":\"443\",\"id\":\"$UUID\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"$URL\",\"path\":\"$VMESS_WSPATH\",\"tls\":\"tls\"}" | base64 -w 0)
vllink="vless://"$UUID"@"$URL":443?encryption=none&security=tls&type=ws&host="$URL"&path="$VLESS_WSPATH"#hicairo.com"

qrencode -o $HOME/www/M$UUID.png $vmlink
qrencode -o $HOME/www/L$UUID.png $vllink

Author=$(cat <<-EOF
#############################################################
#
# V2ray for Alwaysdata.com
# Author: ifeng, <https://t.me/HiaiFeng>
# Web Site: https://www.hicairo.com
#
#############################################################
EOF
)

cat > $HOME/www/index.html<<-EOF
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Alwaysdata</title>
<style type="text/css">
body {
	  font-family: Geneva, Arial, Helvetica, san-serif;
    }
</style>
</head>
<body bgcolor="#FFFFFF" text="#000000">
<div align="center"><b>Hello World</b></div>
</body>
</html>
EOF

cat > $HOME/www/$UUID.html<<-EOF
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Alwaysdata</title>
<style type="text/css">
body {
	  font-family: Geneva, Arial, Helvetica, san-serif;
    }
div {
	  margin: 0 auto;
	  text-align: left;
      white-space: pre-wrap;
      word-break: break-all;
      max-width: 80%;
	  margin-bottom: 10px;
}
</style>
</head>
<body bgcolor="#FFFFFF" text="#000000">
<div><font color="#009900"><b>VMESS协议链接：</b></font></div>
<div>$vmlink</div>
<div><font color="#009900"><b>VMESS协议二维码：</b></font></div>
<div><img src="/M$UUID.png"></div>
<div><font color="#009900"><b>VLESS协议链接：</b></font></div>
<div>$vllink</div>
<div><font color="#009900"><b>VLESS协议二维码：</b></font></div>
<div><img src="/L$UUID.png"></div>
</body>
</html>
EOF

clear

echo -e "\e[32m$Author\e[0m"

echo -e "\n\e[33m请 COPY 以下绿色文字到 SERVICE Command* 中：\n\e[0m"
echo -e "\e[32m./v2ray -config config.json\e[0m"
echo -e "\n\e[33m请 COPY 以下绿色文字到 Advanced Settings 中：\n\e[0m"
echo -e "\e[32m$Advanced_Settings\e[0m"

echo -e "\n\e[33m点击以下链接获取节点信息：\n\e[0m"
echo -e "\e[32mhttps://$URL/$UUID.html\n\e[0m"

