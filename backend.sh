#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "$2 failure"
        exit 1
    else 
        echo "$2 success"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "error: user must have sudo access"
        exit 1
    fi
}

echo "script executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "disabling existing default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "enabling nodejs 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "installing nodejs"

useradd expense &>>$LOG_FILE_NAME
VALIDATE $? "adding expense user"

mkdir /app &>>$LOG_FILE_NAME
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "downloading backend"

cd /app

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip backend"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service


dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "installing mysql client"

mysql -h mysql.daws82s.sbs -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "setting up transaction scshema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "daemon reload"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "staring backend"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "enabling backend"