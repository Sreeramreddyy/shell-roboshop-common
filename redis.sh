#!/bin/bash

source .common.sh
app_name=redis
check_root

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling default redis"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enable redis 7 version" &>>$LOG_FILE
dnf install redis -y  &>>$LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing Remote connections to Redis"
systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling redis Service"
systemctl start redis &>>$LOG_FILE
VALIDATE $? "Started redis service"

print_total_time