# THIS BRANCH COMES WITH CUSTOM UI!
# esx_taximeter
ESX Taxi Meter is a plugin that adds a fare meter to your server. Great for those
who work as an Uber, Taxi, Limo, Tow, Aircraft Ferry or any other job that might
charge per mile of travel.

Right now it supports two types of fares. A "Flat Rate" fare which is simple
enough and a "distance" fare which shows a fare total based upon the distance
traveled. The driver is the "owner" of the meter and any passengers in the car
will be able to see the meter if it is active.

In the configuration file you can set restrictions on what vehicle and what ESX
jobs can use the meter. Currently supports both imperial and metric measurements.

The meter can be launched by using F6

# Requirements
ESX

# Installation
Run inside of your server-data/resources folder
Add to your server.cfg file
```
start esx_taximeter
```

# Known Issues
Nothing Special

# Settings
________________________Hotkey__________________________
If you want to change the key setting open client/main.lua and search for 170.
Replace it with one of those controls : https://docs.fivem.net/game-references/controls/

________________________Jobs__________________________
With my version its limited to the taxi job, you can add another if line if you want more jobs, I can do some examples later.
I might go back to getting it from the config but this was more functional for now.

________________________Config__________________________
I left in some config options, should be self explanatory.
You can still change mi to km and the restricted vehicle classes etc.

Enjoy!

