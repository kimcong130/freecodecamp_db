#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then 
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
     #search by number
    ATOMIC=$($PSQL "SELECT elements.atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types on properties.type_id=types.type_id WHERE elements.atomic_number=$1")
  else
    #if not get for number, get by symbol or name
    ATOMIC=$($PSQL "SELECT elements.atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types on properties.type_id=types.type_id WHERE elements.symbol='$1'")
    if [[ -z $ATOMIC ]]
    then 
     ATOMIC=$($PSQL "SELECT elements.atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties ON elements.atomic_number=properties.atomic_number INNER JOIN types on properties.type_id=types.type_id WHERE elements.name='$1'") 
    fi
  fi

  if [[ -n $ATOMIC ]]
  then
    echo "$ATOMIC" | while IFS='|' read ATOMIC_NUMBER  SYMBOL  NAME  TYPE  MASS  MELTING_POINT  BOILING_POINT 
    do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  else
    echo "I could not find that element in the database."
  fi 
fi