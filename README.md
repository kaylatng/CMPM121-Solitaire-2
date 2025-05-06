# KLONDIKE SOLITAIRE

CMPM 121 Assignment 2\
Name: Kayla Nguyen\
Game Title: _Klondike Solitaire, But Better_

## IMPLEMENTATION

### PROGRAMMING PATTERNS

COMMANDS\
I am using commands in the grabber.lua file to grab and release cards.

STATE\
I am managing the state of each card using state managers in card.lua.

FLYWEIGHT\
Flyweight is used for the card spritesheet to reduce the amount of files needed to render. I also applied Flyweight Patterns to my constants.lua and helper.lua files, which I reference in various files--these are constants that I use in multiple files, or multiple times and I do not want to change these values separately, or functions that I created to simplify the code in another file. I used this structure in various Javascript projects in CMPM 120, so this practice carried over to CMPM 121.

OBSERVER\
Observer is used in my update functions of each file, where they check for state changes or conditions to be true.

SEQUENCING\
I am also using sequencing patterns, specifically in the update method when I program the game to update and draw cards as the user interacts with the objects.

### FEEDBACK
Reviewer 1: Maddison Lobo \
Comments: comment here. \
Reviewer 2: \
Comments: comment here. \
Reviewer 3: \
Comments: comment here.

### POSTMORTEM

A postmortem on where you assess the key pain points of your Solitaire project (the missing features and less than ideal code), how you planned on addressing them, and how successful those refactoring efforts were.

### ASSETS

Sprites: Modified/scaled up spritesheet from https://emptysevenone.itch.io/playing-cards. \
Font: N/A \
Music: N/A \
Misc: Code snippets from CMPM 121 live coding examples used. \
I didn’t make any of the assets in this project.
