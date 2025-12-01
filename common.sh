USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-roboshop/
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.jashvika.online

mkdir -p $LOGS_FOLDER

echo "Script started executed at: $(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo "ERROR:: Please run this script with root privelege"
        exit 1 # failure is other than 0
    fi

}


VALIDATE(){
    if [ $1 -ne 0 ]; then 
        echo -e "$2 ...$R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi    
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "Disable NodeJS"
    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "Enabling NodeJS"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Install NodeJS"
    npm install &>>$LOG_FILE
    VALIDATE $? "Install dependencies"
}

app_setup(){
    id roboshop
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "Creating system user"
    else
        echo -e "User already exist ... $Y SKIPPING $N"   
    fi

    mkdir -p /app 
    VALIDATE $? "Creating App directory"
    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name application"
    cd /app 
    VALIDATE $? "Chaning to app directory"
    rm -rf /app/*
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "Unzip $app_name"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOG_FILE
    VALIDATE $? "Copy systemctl services"

    systemctl daemon-reload 
    VALIDATE $? "Daemon reload"
    systemctl enable $app_name &>>$LOG_FILE
    VALIDATE $? "Enable $app_name"
    systemctl start $app_name &>>$LOG_FILE
    VALIDATE $? "Start $app_name"
}

app_restart(){
    systemctl restart $app_name
    VALIDATE $? "Restarted $app_name"
}

print_total_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - START_TIME ))
    echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
}