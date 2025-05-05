# KLONDIKE SOLITAIRE

CMPM 121 Assignment 1\
Name: Kayla Nguyen\
Game Title: _Klondike Solitaire_

## IMPLEMENTATION

### PROGRAMMING PATTERNS

Some programming patterns that are being used are Commands, State, Flyweight, and Observer. I am using commands in the grabber.lua file to grab and release cards. I am managing the state of each card using state managers in card.lua. Flyweight is used for the card spritesheet to reduce the amount of files needed to render. I also applied Flyweight Patterns to my constants.lua and helper.lua files, which I reference in various files--these are constants that I use in multiple files, or multiple times and I do not want to change these values separately, or functions that I created to simplify the code in another file. I used this structure in various Javascript projects in CMPM 120, so this practice carried over to CMPM 121. Observer is used in my update functions of each file, where they check for state changes or conditions to be true. I am also using sequencing patterns, specifically in the update method when I program the game to update and draw cards as the user interacts with the objects.

### REFLECTION

I believe the card movement is one of my best features in this assignment. I learned how to use the update function for objects to create a drag when a player moves a mouse. As a result, the cards have a drag when a player uses their mouse to move a card. My goal was to mimic the implementation of Klondike Solitaire by Google. I also believe I did well on using a single spritesheet to create the whole card deck. This decreases the amount of files needed for the program to run. While programming Solitaire, I also learned about Z-indexes in Love2D, which applied similarly to Z-indices in Phaser (CMPM 120). My implementation for the grabber function was difficult to apply to card objects at first, but after rearranging my code and changing the card and grabber logic, I believe my grabber works as intended (most times). However, if I were to approach this project again, I would organize my code and create pseudo code before programming anything to make sure I fully understand where I want to implement specific functions. I went through several iterations of rearranging code to make the card pickup and dropping mechanics work, which I believe would be reduced if I decided beforehand where I would implement functions. I would also add music or SFX if I were to revisit this project. \

SOME NOTES: 
The logic to accept cards and invalid cards seems to have an issue accepting the mouse position. For this specific seed, if you click on the stock deck and place the Jack of Hearts on top of the Queen of Spades, the pile only accepts the card if the cursor is in the top right of the Queen card. I am still trying to fix this implementation for Project 2. \

### ASSETS

Sprites: Modified/scaled up spritesheet from https://emptysevenone.itch.io/playing-cards. \
Font: N/A
Music: N/A
Misc: Code snippets from CMPM 121 live coding examples used.
