#! /bin/bash
echo -e "~~~ Salon Appointment Scheduler ~~~"
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU () {
  #error message
  if [[ ! -z $1 ]]
  then
    echo -e "\n$1"
  fi
    # echo -e "\nWelcome to My Salon, how can I help you?\n"
    SERVICES_RESULTS=$($PSQL "SELECT service_id, name from services ORDER BY service_id")
    echo "$SERVICES_RESULTS" | while read SERVICE_ID BAR NAME
    do 
      if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
      then
        echo -e "$SERVICE_ID) $NAME"
      fi
    done

  read SERVICE_ID_SELECTED
  #if input is not number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  fi
  #check if valid service id
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    #get name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo $CUSTOMER_NAME
    #if number not in db
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      #add user
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    #choose hour
    echo -e "\nWhat time would you like your cut, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME
    #get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #add apointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ('$CUSTOMER_ID', $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $INSERT_APPOINTMENT_RESULT != "INSERT 0 1" ]]
    then
      MAIN_MENU "Sorry, something went wrong. Please try again."
    else
      echo -e "I have put you down for a $(echo "$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME" | sed -r 's/ {2,}/ /g')."
    fi
  fi
  
}

echo -e "\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU
