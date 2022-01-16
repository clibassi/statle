# Statle
### A quick helper for seeing all permutations of WORLD information you've received from initial guesses

Playing Wordle, my strategy has been: use one or two words that cover many of the most common letters appearing in English language words, then think through the remaining permutations based on the information I get from the initial guess or guesses. But then I got bored trying to work through all the permutations myself and figured writing a program might make my life easier. Plus, I need to practice writing Stata programs more often, so I figured this would be a good opportunity. 

The resulting program here (not an ado file, just some code you can run and then use the program yourself) takes two arguments, one is a string of all the letters you know, the second is a string of blanks and letters that specify any positions you know. The result is a list of possible combinations of the letters, given the known positions.

The syntax is: 

```
statle <known letters> <known positions>
```

Imagine the true 5 letter word is: INCUR. I guess TARES and find only that I know R is in the word. Then I guess CHINO and learn that C and I are in the word at position one (1-indexed). My input to the command would be: 

```
statle "R C I" "_ _ _ _ _" 
```

If instead on my second guess I had chosen to use INKED, I would input: 

```
statle "I N R" "I N _ _ _" 
```

Note that it is necessary to enclose the two strings in quotes if you put any spaces in your strings. The same code above would work without quotes only if there were no spaces. For example: 

```
statle INR IN___ 
```

