#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  echo -e "Welcome to My Salon, how can I help you?\n"
  SERVICE_LIST=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
   # Solicitar al usuario que elija un servicio
  echo -e "\nPlease select a service by number:"
  read SERVICE_ID_SELECTED
  # Verificar si la entrada es válida (un número entre 0 y 3)
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3]+$ ]]
  then
    MAIN_MENU "Invalid option. Please choose a service."
  else
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo "Please enter your phone for the appointment." 
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
        echo "I dont´have a record for that phone number. What´s your name?"
        read CUSTOMER_NAME
        # insert new customer
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        echo $CUSTOMER_ID
        echo "What time you would like your $(echo $SERVICE | sed -E 's/ *$\^ *//g'), $(echo $CUSTOMER_NAME | sed -E 's/ *$\^ *//g')?"
        read SERVICE_TIME
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
        echo "I have put you down for a $(echo $SERVICE | sed -E 's/ *$\^ *//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/ *$|^ *//g')."
    else
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      echo "What time you would like your $(echo $SERVICE | sed -E 's/ *$\^ *//g'), $(echo $CUSTOMER_NAME | sed -E 's/ *$\^ *//g')?"
      read SERVICE_TIME
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      echo "I have put you down for a $(echo $SERVICE | sed -E 's/ *$\^ *//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/ *$|^ *//g')."
    fi    
  fi  
}
MAIN_MENU