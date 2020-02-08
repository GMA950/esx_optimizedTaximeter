local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


ESX = nil

local lastLocation = nil
local playerJobName = nil
local configOpen = false
local configOpenFirstTime = false
local playersInVehicle = {}
local firstConfigOpenInVehicle = false
local PlayerData = nil
local meterOwner = false
--local pause = false


local meterAttrs = {
  meterVisible = false,
  rateType = Config.RateType, --Config.RateType rateType = 'distance'
  rateAmount = Config.Rate, --rateAmount = nil,
  currencyPrefix = Config.CurrencyPrefix,
  rateSuffix = Config.RateSuffix,
  currentFare = Config.Base, --currentFare = 0,
  distanceTraveled = 0,
  fareOnStop = 0,
  meterPause = true,
  isMoving = false
}

local taxActive = false
local playersInTaxi = {}
local isInTaxi = false
local wasDriver = false
local habiaUnPasajero = false
local lastFares = {}


--===================================================================
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

  PlayerData = ESX.GetPlayerData()
  
  playerJobName = PlayerData.job.name

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
  playerJobName = PlayerData.job.name
end)
--===================================================================


Citizen.CreateThread(function() --DESACTIVA EL TAXIMETRO CUANDO SE BAJA DE UN TAXI (pasajero o conductor)
  while true do
    Citizen.Wait(500)
    local ped = GetPlayerPed(-1)

    if playerJobName == 'taxi' or isInTaxi then 
        if taxActive and not IsPedSittingInAnyVehicle(PlayerPedId()) then
          if wasDriver then --si el que se bajo era el conductor, desactiva todo para todos
            wasDriver = false
            TriggerEvent('esx_taximeter:toggleTaximeter', true)
          else
            setComeBack() --si el cliente se vuelve a subir al taxi y el taximetro sigue encendido, se sincroniza con la nueva info
            TriggerEvent('esx_taximeter:noPassenger')
          end
        end
    end
  end
end)

function setComeBack()
  local driverPed = GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), true), -1) --true porque se bajo del vehiculo
  if driverPed ~= 0 then
    for _, player in ipairs(GetActivePlayers()) do
      local ped = GetPlayerPed(player)
      if ped == driverPed then
        TriggerServerEvent('esx_taximeter:setComeBack', GetPlayerServerId(player))
      end
    end
  end
end

RegisterNetEvent("esx_taximeter:notRestart")
AddEventHandler("esx_taximeter:notRestart", function()
  habiaUnPasajero = true
  --lastFares = meterAttrs
end)


function resetTax()
  lastLocation = GetEntityCoords(GetPlayerPed(-1))
  meterAttrs = {
    meterVisible = false,
    rateType = Config.RateType, --Config.RateType rateType = 'distance'
    rateAmount = Config.Rate, --rateAmount = nil,
    currencyPrefix = Config.CurrencyPrefix,
    rateSuffix = Config.RateSuffix,
    currentFare = Config.Base, --currentFare = 0,
    distanceTraveled = 0,
    fareOnStop = 0,
    meterPause = true,
    isMoving = false
  }
  updateMeter()
end

RegisterNetEvent("esx_taximeter:toggleTaximeter")
AddEventHandler("esx_taximeter:toggleTaximeter", function(hotExit)
  if taxActive then
    resetTax()
    taxActive = false
    habiaUnPasajero = false
    --pause = false
    print("debug1")
    getPlayersinTaxi(GetVehiclePedIsIn(GetPlayerPed(-1), hotExit), taxActive) -- false/hotExit EL HOT EXIT ES PARA DESACTIVAR EL TAXIMETRO CUANDO EL CONDUCTOR SE BAJA A LOS PASAJEROS
  else
    if IsDriver() then
      meterAttrs['meterVisible'] = true
      taxActive = true
      wasDriver = true
      --pause = false
      lastLocation = GetEntityCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false))
      vehicleOnStop()
      --
      updateMeter()
      --
      print("debug2")
      getPlayersinTaxi(GetVehiclePedIsIn(GetPlayerPed(-1), hotExit), taxActive) --false/hotExit
    else
      ESX.ShowNotification('¡¡No estás conduciendo el ~y~Taxi~s~!!')
    end
  end
end)

function getPlayersinTaxi(taxi, on)
  --ped = PlayerPedId()
  --print(ped)
  for i=0, 2, 1 do
    local pobrewn = GetPedInVehicleSeat(taxi, i)
    if pobrewn ~= 0 then
      habiaUnPasajero = true
      --ACTIVAR TAXIMETRO Y SETEARLO COMO IN TAXI
        --print("vamos a colocar un debug aqui")
       -- print(pobrewn)
      --GetPlayerServerId(GetPlayerPed(pobrewn))
      --
      for _, player in ipairs(GetActivePlayers()) do --player es la id creo
        --print(player)
        local ped = GetPlayerPed(player)
        --print(ped..' '..pobrewn)
        if ped == pobrewn then
          if on then --ACTIVAMOS EL TAXIMETRO PARA LOS PASAJEROS TAMBIEN
            TriggerServerEvent('esx_taximeter:setAsPassenger', GetPlayerServerId(player), false, nil) --GetPlayerServerId(GetPlayerPed(pobrewn))
          else
            TriggerServerEvent('esx_taximeter:noLongerPassenger', GetPlayerServerId(player)) --GetPlayerServerId(GetPlayerPed(pobrewn))
          end
        end
      end
      --[[
      if on then --ACTIVAMOS EL TAXIMETRO PARA LOS PASAJEROS TAMBIEN
        TriggerServerEvent('esx_taximeter:setAsPassenger', GetPlayerServerId(pobrewn)) --GetPlayerServerId(GetPlayerPed(pobrewn))
      else
        TriggerServerEvent('esx_taximeter:noLongerPassenger', GetPlayerServerId(pobrewn)) --GetPlayerServerId(GetPlayerPed(pobrewn))
      end--]]
    end
  end 
end

RegisterNetEvent("esx_taximeter:isPassenger")
AddEventHandler("esx_taximeter:isPassenger", function(retake, data)
  if retake then
    isInTaxi = true
    taxActive = true
    meterAttrs = data
    lastLocation = GetEntityCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false))
    updateMeter()

  else
    isInTaxi = true
    taxActive = true
    meterAttrs['meterVisible'] = true
    lastLocation = GetEntityCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false))
    updateMeter()
  end
end)

RegisterNetEvent("esx_taximeter:noPassenger")
AddEventHandler("esx_taximeter:noPassenger", function()
  isInTaxi = false
  taxActive = false
  --meterAttrs['meterVisible'] = false
  resetTax()
end)

RegisterNetEvent("esx_taximeter:pauseTaximeter")
AddEventHandler("esx_taximeter:pauseTaximeter", function(pause)
  if IsDriver() then
    pauseForClient(GetVehiclePedIsIn(GetPlayerPed(-1), false), meterAttrs['meterPause'])
    if meterAttrs['meterPause'] then
      meterAttrs['meterPause'] = false
      lastLocation = GetEntityCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false))
      updateMeter()
    else
      meterAttrs['meterPause'] = true
      updateMeter()
    end
  else
    if pause then
      meterAttrs['meterPause'] = false
      lastLocation = GetEntityCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false))
      updateMeter()
    else
      meterAttrs['meterPause'] = true
      updateMeter()
    end
  end
end)

function pauseForClient(vehicle, pause)
  for i=0, 2, 1 do
    local client = GetPedInVehicleSeat(vehicle, i)
    if client ~= 0 then
      for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == client then
          TriggerServerEvent('esx_taximeter:setPause', GetPlayerServerId(player), pause)
        end
      end
    end
  end
end


Citizen.CreateThread(function()
  while true do
    if taxActive then
      --updatePassengerMeters()
      --lastLocation = GetEntityCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false))
      vehicleOnStop()
      if not meterAttrs['meterPause'] then
        --vehicleOnStop()
        calculateFareAmount()
      end
      updateMeter()
    end
    Citizen.Wait(2000)
  end
end)

Citizen.CreateThread(function()
  while true do
    if habiaUnPasajero and taxActive then
      searchForTheClient(GetVehiclePedIsIn(GetPlayerPed(-1), false))
    end
    Citizen.Wait(1000)
  end
end)

function searchForTheClient(vehicle)
  for i=0, 2, 1 do
    local oldClient = GetPedInVehicleSeat(vehicle, i)
    if oldClient ~= 0 then
      habiaUnPasajero = false
      lastFares = meterAttrs
      for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if ped == oldClient then
          TriggerServerEvent('esx_taximeter:setAsPassenger', GetPlayerServerId(player), true, lastFares)
        end
      end
    end
  end
end

function vehicleOnStop()
  if GetEntitySpeed( GetVehiclePedIsIn(PlayerPedId())) < 0.1 then
    if not meterAttrs['meterPause'] then
      meterAttrs['fareOnStop'] = meterAttrs['fareOnStop'] + Config.OnStop
    end
    meterAttrs['isMoving'] = false
  else
    meterAttrs['isMoving'] = true
  end
end

--[[
  Sends an update ping to display script
]]
function updateMeter() --IMPORTANTE
  SendNUIMessage({type = 'update_meter', attributes = meterAttrs})
end

--[[
  Determines if the ped is the driver of the vehicle

  Returns
    boolean
]]
function IsDriver ()
  return GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1)
end

--[[
  Calculates the fare amount and updates the meter
]]
function calculateFareAmount() --IMPORTANTE
  if (meterAttrs['meterVisible']) and (meterAttrs['rateType'] == 'distance') and not (meterAttrs['rateAmount'] == nil)  then
    start = lastLocation

    if start then
      current = GetEntityCoords(GetVehiclePedIsIn(GetPlayerPed(-1), false)) --GetEntityCoords(GetPlayerPed(-1))
      distance = CalculateTravelDistanceBetweenPoints(start, current)
      lastLocation = current
      meterAttrs['distanceTraveled'] = meterAttrs['distanceTraveled'] + distance

      if Config.DistanceMeasurement == 'mi' then --AUTOMATICAMENTE CONVIERTE STRING TO FLOAT QUE MARAVILLA AAAAAAA
        fare_amount = Config.Base + meterAttrs['fareOnStop'] + (meterAttrs['distanceTraveled'] / 1609.34) * meterAttrs['rateAmount']
      else
        fare_amount = Config.Base + meterAttrs['fareOnStop'] + (meterAttrs['distanceTraveled'] / 1000.00) * meterAttrs['rateAmount']
      end
      
      if fare_amount < 10 then
        meterAttrs['currentFare'] = '00'..string.format("%.2f", fare_amount)
      elseif fare_amount < 100 then
        meterAttrs['currentFare'] = '0'..string.format("%.2f", fare_amount)
      end
    end
  end
end