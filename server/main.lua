ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_taximeter:setAsPassenger')
AddEventHandler('esx_taximeter:setAsPassenger', function(targetID, oldClient, oldData)
	local _source 	 = ESX.GetPlayerFromId(targetID).source
  TriggerClientEvent('esx_taximeter:isPassenger', _source, oldClient, oldData)
end)

RegisterServerEvent('esx_taximeter:noLongerPassenger')
AddEventHandler('esx_taximeter:noLongerPassenger', function(targetID)
	local _source 	 = ESX.GetPlayerFromId(targetID).source
  TriggerClientEvent('esx_taximeter:noPassenger', _source)
end)

RegisterServerEvent('esx_taximeter:setComeBack')
AddEventHandler('esx_taximeter:setComeBack', function(targetID)
	local _source 	 = ESX.GetPlayerFromId(targetID).source
  TriggerClientEvent('esx_taximeter:notRestart', _source)
end)

RegisterServerEvent('esx_taximeter:setPause')
AddEventHandler('esx_taximeter:setPause', function(targetID, bool)
	local _source 	 = ESX.GetPlayerFromId(targetID).source
  TriggerClientEvent('esx_taximeter:pauseTaximeter', _source, bool)
end)