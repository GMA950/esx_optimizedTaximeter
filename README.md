# esx_OptimizedTaximeter

This ESX Taxi Meter is a plugin that adds a fare meter to your server. Great for those
who work as an Uber, Taxi, Limo, Tow, Aircraft Ferry or any other job that might
charge per mile of travel.

Right now it supports two types of fares. A "Flat Rate" fare which is simple
enough and a "distance" fare which shows a fare total based upon the distance
traveled. The driver is the "owner" of the meter and any passengers in the car
will be able to see the meter if it is active.

In the configuration file you can set restrictions, type of fares, fare rate, a base fare amount, etc.

The meter needs to be launched using F6 menu of the esx_taxijob 

# Screenshots

![screenshot](https://i.imgur.com/zyRvjDC.jpg)

# Requirements
- ESX
- esx_taxijob
- Replace OpenMobileTaxiActionsMenu() in the client script of esx_taxijob

# OpenMobileTaxiActionsMenu()

## Replace your OpenMobileTaxiActionsMenu() in your esx_taxijob/client/main.lua with this one

```lua
function OpenMobileTaxiActionsMenu()
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'mobile_taxi_actions',
	{
		title    = 'Taxi',
		align    = 'top-left',
		elements = {
			{ label = _U('billing'),   value = 'billing' },
			{ label = _U('taximeter'), value = 'taximeter' },
			{ label = _U('taximeter_pause'), value = 'taximeterPause' },
			{ label = _U('start_job'), value = 'start_job' }
		}
	}, function(data, menu)
		if data.current.value == 'billing' then

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
				title = _U('invoice_amount')
			}, function(data, menu)

				local amount = tonumber(data.value)
				if amount == nil then
					ESX.ShowNotification(_U('amount_invalid'))
				else
					menu.close()
					local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
					if closestPlayer == -1 or closestDistance > 3.0 then
						ESX.ShowNotification(_U('no_players_near'))
					else
						TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_taxi', 'Taxi', amount)
						ESX.ShowNotification(_U('billing_sent'))
					end

				end

			end, function(data, menu)
				menu.close()
			end)
		elseif data.current.value == 'taximeter' then
			if IsInAuthorizedVehicle() then
				TriggerEvent('esx_taximeter:toggleTaximeter', false)
			else
				ESX.ShowNotification(_U('not_taxi'))
			end
		elseif data.current.value == 'taximeterPause' then
			if IsInAuthorizedVehicle() then
				TriggerEvent('esx_taximeter:pauseTaximeter')
			else
				ESX.ShowNotification(_U('not_taxi'))
			end
		elseif data.current.value == 'start_job' then
			if OnJob then
				StopTaxiJob()
			else
				if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'taxi' then
					local playerPed = PlayerPedId()
					local vehicle   = GetVehiclePedIsIn(playerPed, false)

					if IsPedInAnyVehicle(playerPed, false) and GetPedInVehicleSeat(vehicle, -1) == playerPed then
						if tonumber(ESX.PlayerData.job.grade) >= 3 then
							StartTaxiJob()
						else
							if IsInAuthorizedVehicle() then
								StartTaxiJob()
							else
								ESX.ShowNotification(_U('must_in_taxi')) --ADD THIS TRANSLATION IN YOUR LOCAL
							end
						end
					else
						if tonumber(ESX.PlayerData.job.grade) >= 3 then
							ESX.ShowNotification(_U('must_in_vehicle')) --ADD THIS TRANSLATION IN YOUR LOCAL
						else
							ESX.ShowNotification(_U('must_in_taxi')) --ADD THIS TRANSLATION IN YOUR LOCAL
						end
					end
				end
			end
		end
	end, function(data, menu)
		menu.close()
	end)
end
```

# Installation
Run inside of your server-data/resources folder
Add to your server.cfg file
```
start esx_taximeter
```

# Known Issues
When a new passenger gets in the vehicle, the driver will need to toggle the radar to
make it appear.

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

ORIGINAL SCRIPT https://github.com/Dexterin0/esx_taximeter/tree/withui

Enjoy!

