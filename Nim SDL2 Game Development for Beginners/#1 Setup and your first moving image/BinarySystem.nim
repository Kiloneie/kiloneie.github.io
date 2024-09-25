#In order to increase the value,
  #you must change a bit from a 0 to a 1, that adds 1
  #But if the the bit is already a 1 say the first one 8th one, 
  #then you check the next bit the 7th if it's a 0 
  #if it is a 0, then you set the 8th bit to a 0
  #and whenever you change a bit from a 1 to a 0 when adding
  #you must then carry over that 1 to the first non 1 bit

#ADDITION
#0000 = 0
#0001 = 1
#0010 = 2
#0011 = 3
#0100 = 4
#0101 = 5
#0110 = 6
#0111 = 7
#1000 = 8
#1001 = 9
#1010 = 10

#SUBTRACTION
#1010 = 10
#1001 = 9
#1000 = 8
#0111 = 7
#0110 = 6
#0101 = 5
#0100 = 4
#0011 = 3
#0010 = 2
#0001 = 1
#0000 = 0

#Setting a flag/bit to true/1
  #This adds the flags together JUST like in the SDL code
var flagHolder = 0b00000000 #Empty integer
var flag1 = 0b00000001
var flag2 = 0b00001000

import strutils

flagHolder = flag1 or flag2
echo flagHolder.toBin(4)

#Removing the second flag(flag2) must inverse the flag we are
  #ANDing to the flagHolder
echo ""

flagHolder = flagHolder and not flag2 #not -> to negate/invert
echo flagHolder.toBin(4)

flagHolder = flagHolder and not flag1
echo flagHolder.toBin(4)

#Checking if flags are set
  #First we are going to re-SET the flags, flag1, flag2
flagHolder = flag1 or flag2

#"and" keyword without a "not" keyword is used for checking bits

if (flagHolder and(flag1 or flag2)) > 0:
  echo "both flags are set"

#XOR - toggling/inverting a flag state/value
  #Checking the bit pattern
echo ""
echo flagHolder.toBin(4)

#Let's toggle/invert both flags(flag1, flag2)
flagHolder = flagHolder xor (flag1 or flag2)
echo flagHolder.toBin(4)

#Let's repeat the toggle if it actually keeps toggling
flagHolder = flagHolder xor (flag1 or flag2)
echo flagHolder.toBin(4)
