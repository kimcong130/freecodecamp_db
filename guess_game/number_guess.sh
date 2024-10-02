#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


SECRET_NUMBER=$(($RANDOM % 1000 + 1))

echo -e "\nEnter your username:"
read USER_NAME
#search username in database to get the user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")
#if username not exist
if [[ -z $USER_ID ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
else
  #else 
  GAME_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id='$USER_ID'")
  BEST_GAME=$($PSQL "SELECT MAX(number_guess) FROM games WHERE user_id='$USER_ID'")
echo "Welcome back, $USER_NAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
fi


echo -e "\nGuess the secret number between 1 and 1000:"
COUNTER=0
while read GUESS_NUMBER
do
  (( COUNTER++ ))
  # not a Integer
  if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  else
    if (( GUESS_NUMBER < SECRET_NUMBER ))
    then
      echo -e "\nIt's lower than that, guess again:" 
    elif (( GUESS_NUMBER > SECRET_NUMBER ))
    then
      echo -e "\nIt's higher than that, guess again:"
    else
      echo "You guessed it in $COUNTER tries. The secret number was $SECRET_NUMBER. Nice job!"
      INSERT_RESULT=$($PSQL "INSERT INTO games(user_id, number_guess, secret_number) VALUES($USER_ID, $COUNTER, $SECRET_NUMBER)")
      break
    fi
  fi
  # 
done
