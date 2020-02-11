ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_taximeter:updatePassenger')
AddEventHandler('esx_taximeter:updatePassenger', function(targetID, data, now)
	local _source 	 = ESX.GetPlayerFromId(targetID).source
  TriggerClientEvent('esx_taximeter:newValue', _source, data, now)
end)