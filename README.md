# drop_data.sh script
Wolfram Data Drop simple bash script for embedded data collection and sending to cloud

# Usage
send async data to local collector bin in form of:
```
drop_data.sh <DatabinID/name> key value <method> 
```
then send data to server:
```
drop_data.sh <DatabinID/name> --send 
```
method used in case of data collision:
  - max - send only greatest
  - min - send smallest value
  - avg - send average
  - no value: send latest value

add to crontab with this syntax: `* * * * * /path/to/drop_data.sh <DatabinID/name> --send`

# Config file
It is possible to use small config file at `/etc/drop_data.conf` which contains name of the bin in the form:
```
Name_Of_Bin 5g45h5f~
Other_bin 5dhsjll
```
so that name form instead of hash can be used as input

# Requirements

  - shell interpreter (busybox,ash,bash,dash)
  - wget (either SSL or noSSL version)
