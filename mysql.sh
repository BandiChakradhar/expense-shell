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

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "enabling mysql server"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "starting mysql server"



mysql -h mysql.daws82s.sbs -u root -pExpenseApp@1 -e 'show databases;'

if [ $? -ne 0 ]
then 
    echo "Mysql root password not setup" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting root password"
else
    echo "Mysql password already setup....skipping"
fi
