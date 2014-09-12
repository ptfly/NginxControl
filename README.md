NginxControl
============

Menu bar application for easily start/stop/reload nginx server installed on your mac

<img src="https://github.com/ptfly/NginxControl/blob/master/screenshot.png" width="262">

Download compiled version: [NginxControll.app](https://github.com/ptfly/NginxControl/blob/master/NginxControl.zip)

## Note 
My nginx installation is done through brew, therefore all nginx paths required for NginxControl to work are hardcoded.
These are the paths used by the application and if you installed it with brew, this should work out-of-the-box on your setup:

> /usr/local/bin/nginx

> /usr/local/var/run/nginx.pid

> /usr/local/etc/nginx/nginx.conf

If yours are different, the application wont work, you should fix these paths in AppController.m and build it yourself.


