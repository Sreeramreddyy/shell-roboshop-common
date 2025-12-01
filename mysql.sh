#!/bin/bash

source .common.sh

check_root

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL Server"
systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld  

VALIDATE $? "Enabling and starting MySQL Server"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Setting Root password to MySQL Server"

print_total_time