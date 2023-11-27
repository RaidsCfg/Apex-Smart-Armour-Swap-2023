# Apex-Smart-Armour-Swap-2023

- [Watch Demo Video Here](https://www.youtube.com/watch?v=3bRq1fnAXR4)
- [Our Discord Group](https://discord.com/invite/F5k5Et3EzN)
## About
This script is designed in AHK to automatically swap to an armour within a deathbox ONLY if it has more health than your current shield. Everything is done externally so theoretically it is 100% safe to use. The script is pretty straight forward and easy to read, you can change your deathbox keybind at the bottom of the script and easily add support for your own resolutions.
Everything is done by the script without the need for extra hotkeys or button presses. Simply open a deathbox using E and the rest will be done for you.

## Features
- Sub 15ms Swaps (Using SendMode Input)
- Automatic Armour Swaps
- Lightweight
- Doesn't interrupt your gameplay

## Compatible with
- Resolution: 1920x1080, 1728x1080, 1680x1050
- AHK v1.1

## Installation
1. Download and extract the folder
2. Run 'Smart Armour Swap.ahk'
- As long as you have a supported resolution, the script will run otherwise it will not
- A text file in the folder explains how to add custom resolutions

## Known Issues and Fixes
Issue:
- SendMode Input can sometimes be too fast and causes your cursor to move to the shield but not click.

Fix:
- Comment out SendMode Input and replace "Click %X%, %Y%" with "MouseClick, Left, X, Y, , 0" 0 = speed. 0 is fastest 100 is slowest

## Color Detection
###
Good:
- Will work for 99% of people straight out the box
- Mostly works in colorblind mode, if it doesn't you'll need to increase tolerance for the color detection
- Changing the brightness/vibrance of your monitor through Nvidia Control Panel or directly through your monitors settings will work fine.
### 
Bad:
- You MUST NOT be using color filters that change the color of your desktop. Things like Nvidia geforce game filters (alt+f3) will interfere with the color detection.
