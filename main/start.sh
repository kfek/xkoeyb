#!/bin/sh
UUID="d3a5f719-54ff-40a7-b0c3-15d194d6ae84"
CADDYIndexPage="https://www.free-css.com/assets/files/free-css-templates/download/page9/fleur-2.zip"
export PORT=${PORT-8080}
export PATH_vless=${PATH_vless-/$UUID-vless}
export PATH_trojan=${PATH_trojan-/$UUID-trojan}
export PATH_vmess=${PATH_vmess-/$UUID-vmess}


#CADDYIndexPage-configs
wget $CADDYIndexPage -O /main/index.html && unzip -qo /main/index.html -d /main/page/ && mv /main/page/*/* /main/page/

tar -xzvf caddy.tar.gz
rm -f caddy.tar.gz

chmod +x ./caddy
./caddy start


echo '
 {
    "log": {"loglevel": "warning"},
    "inbounds": [
        {
            "port": 4000,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "'$UUID'"
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "path": "'${PATH_vless}'",
                        "dest": 4001
                    },{
                        "path": "'${PATH_trojan}'",
                        "dest": 4002
                    },{
                        "path": "'${PATH_vmess}'",
                        "dest": 4003
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp"
            }
        },{
            "port": 4001,
            "listen": "127.0.0.1",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "'$UUID'"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "'${PATH_vless}'"
                }
            }
        },{
            "port": 4002,
            "listen": "127.0.0.1",
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "'$UUID'"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "'${PATH_trojan}'"
                }
            }
        },{
            "port": 4003,
            "listen": "127.0.0.1",
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "'$UUID'"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "path": "'${PATH_vmess}'"
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
' > conf.json
chmod +x ./Web
./Web -config=conf.json
