#!/bin/bash
c=1
while [ 1 ]
do
tail -11 ./demand.xml > tmp.xml
curl -d @./tmp.xml "http://pvoutput.org/service/r2/ravenpost.jsp?sid=putyoursidhere&key=putyourapikeyhere"
sleep 300
done
