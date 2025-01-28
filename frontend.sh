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

dnf install nginx -y 
VALIDATE $? "installing nginx server"

systemctl enable nginx
VALIDATE $? "enabling nginx server"

systemctl start nginx
VALIDATE $? "starting nginx server"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing existing version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "downloading latest code"

cd /usr/share/nginx/html
VALIDATE $? "moving to html directory"

unzip /tmp/frontend.zip
VALIDATE $? "unzipping frontend"

systemctl restart nginx
VALIDATE $? "restarting nginx server"


