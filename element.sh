#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

#Check if argument supplied with program and ask for one if not
CHECK_ARG () {

  #Check if the first argument passed to the function is Null
  if [[ -z "$1" ]] 
  then
    echo -e "Please provide an element as an argument."
    unset ELEMENT
  else
    ELEMENT=$1
  fi
}


#Decipher argument if its the element symbol or atomic number
DECIPHER_ARG () {

  #Check if Element only contains numbers thus is the Atomic Number
  if [[ "$ELEMENT" =~ ^[0-9]+$ ]]
  then
    IS_ATOMNUM=true

  #Check if Element only contains letters and has less than 3 characters thus is a element symbol
  elif [[ "$ELEMENT" =~ [a-zA-Z]+$ && ${#ELEMENT} < 3 ]]
  then
    IS_SYMBOL=true

  #Check if Element only contains letters and has  more than 3 characters thus is an element name
  elif [[ $ELEMENT =~ [a-zA-Z]+$ && ${#ELEMENT} > 3 ]]
  then
    IS_NAME=true
  fi
}


#Find atomic number from database depending on format
FIND_ATOMNUM () {
  #Get atom number when format is the atom number
  if [[ $IS_ATOMNUM == true ]] 
  then
    ATOMNUM=$ELEMENT

  #Get atom number when format is a symbol
  elif [[ $IS_SYMBOL == true ]]
  then
    ATOMNUM=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$ELEMENT'")

  #Get atom number when format is an element name
  elif [[ $IS_NAME == true ]]
  then
    ATOMNUM=$($PSQL "SELECT atomic_number FROM elements WHERE name='$ELEMENT'")
  else
    unset ATOMNUM
  fi
}


#------------------------------------ Program Begins ------------------------------------#
#If first argument blank ask for element
CHECK_ARG $1

IS_SYMBOL=false
IS_ATOMNUM=false
IS_NAME=false

#If element not supplied ignore and end program
if [[ -n $ELEMENT ]] 
then
  #Decipher argument format
  DECIPHER_ARG

  #Search for atomic number in database
  FIND_ATOMNUM

  #Output info to terminal
  if [[ -z $ATOMNUM ]] 
  then
    echo -e "I could not find that element in the database."
  else
    #Get remaining info
    ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number='$ATOMNUM'")
    ELEMENT_SYM=$($PSQL "SELECT symbol FROM elements WHERE atomic_number='$ATOMNUM'")
    ELEMENT_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number='$ATOMNUM'")
    ELEMENT_MELT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number='$ATOMNUM'")
    ELEMENT_BOIL=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number='$ATOMNUM'")
    ELEMENT_TYPE_ID=$($PSQL "SELECT type_id FROM properties WHERE atomic_number='$ATOMNUM'")
    ELEMENT_TYPE=$($PSQL "SELECT type FROM types WHERE type_id='$ELEMENT_TYPE_ID'")

    #Print out info
    echo -e "The element with atomic number $ATOMNUM is $ELEMENT_NAME ($ELEMENT_SYM). It's a $ELEMENT_TYPE, with a mass of $ELEMENT_MASS amu. $ELEMENT_NAME has a melting point of $ELEMENT_MELT celsius and a boiling point of $ELEMENT_BOIL celsius."
  fi
fi
