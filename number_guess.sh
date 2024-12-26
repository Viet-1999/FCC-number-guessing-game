#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo -e "Enter your username:"
read USERNAME

# Check if user exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]; then
  # Insert new user
  INSERTED_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # Fetch stats for returning user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

TRIES=0
GUESS=0

# Guessing function
echo -e "\nGuess the secret number between 1 and 1000:"
while true; do
  read GUESS

  # Validate input
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo -e "That is not an integer, guess again:"
    continue
  fi

  TRIES=$((TRIES + 1))

  # Check guess
  if [[ $GUESS -eq $SECRET_NUMBER ]]; then
    echo -e "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo -e "It's lower than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo -e "It's higher than that, guess again:"
  fi
done

# Insert game data
INSERTED_GAME=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $TRIES)")