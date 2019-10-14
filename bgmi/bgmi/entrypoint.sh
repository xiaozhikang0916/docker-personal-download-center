#!/bin/sh

if [ $1 == "start_server" ];then
    exec bgmi_http
else
    exec bgmi $@
fi