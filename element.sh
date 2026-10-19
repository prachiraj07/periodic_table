
#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument was provided
if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
  exit
fi

# Find the element by atomic number, symbol, or name
ELEMENT=$($PSQL "
SELECT elements.atomic_number, elements.name, elements.symbol,
       properties.atomic_mass, types.type,
       properties.melting_point_celsius, properties.boiling_point_celsius
FROM elements
JOIN properties USING (atomic_number)
JOIN types USING (type_id)
WHERE elements.atomic_number::TEXT = '$1'
   OR elements.symbol = '$1'
   OR elements.name = '$1';
")

# Handle an element that does not exist
if [[ -z "$ELEMENT" ]]; then
  echo "I could not find that element in the database."
  exit
fi

# Read the query results
IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL MASS TYPE MELTING BOILING <<< "$ELEMENT"

# Remove trailing zeros from atomic mass
MASS=$(echo "$MASS" | sed 's/0*$//; s/\.$//')

# Display element information
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
