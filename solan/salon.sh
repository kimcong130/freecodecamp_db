#!/bin/bash

PSQL="psql -t -z --username=freecodecamp --dbname=salon -c"
echo -e "\n~~~~~ MY SALON ~~~~~~\n"


SEARCH_SERVICE() {
  read SERVICE_ID_SELECTED 
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  #if not find
  if [[ -z $SERVICE_NAME ]]
  then 
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # read phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # search phone number
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    #if not find
    if [[ -z $CUSTOMER_NAME ]] 
    then
      # read name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi 
    #ask time
    echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
    read SERVICE_TIME
    #creata appoinment
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    # respond and end 
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  fi
}

MAIN_MENU() {
  if [[ -n $1 ]]  
  then 
    echo "$1"
  fi
  # show service choice
  # get service
  SERVICES=$($PSQL "SELECT * FROM services")
  # show
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
      echo -e "$SERVICE_ID) $SERVICE_NAME"
  done 
  SEARCH_SERVICE
}




MAIN_MENU "Welcome to My Salon, how can I help you?"