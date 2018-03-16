#!/bin/bash
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.2.2-x86_64.rpm
sudo rpm -vi filebeat-6.2.2-x86_64.rpm
sudo cp /tmp/filebeat.yml /etc/filebeat/filebeat.yml
sudo chkconfig --add filebeat
