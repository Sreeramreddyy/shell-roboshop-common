#!/bin/bash

source .common.sh

check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "Install Rabbitmq"
systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "Enabling Rabbit server"
systemctl start rabbitmq-server &>>$LOG_FILE

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "Creating User permission for the Application"

print_total_time