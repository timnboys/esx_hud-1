ESX = nil


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('menu:inventory', function(source, cb, item)
  local xPlayer = ESX.GetPlayerFromId(source)
	local qtty = xPlayer.getInventoryItem(item).count
	cb(qtty)
end)

RegisterServerEvent('esx_policejob:confiscatePlayerItem')
AddEventHandler('esx_policejob:confiscatePlayerItem', function(target, itemType, itemName, amount)
	local _source = source
	local sourceXPlayer = ESX.GetPlayerFromId(_source)
	local targetXPlayer = ESX.GetPlayerFromId(target)


	if itemType == 'item_standard' then
		local targetItem = targetXPlayer.getInventoryItem(itemName)
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)

		-- does the target player have enough in their inventory?
		if targetItem.count > 0 and targetItem.count <= amount then

			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + amount) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', _source, 'Nieprawidłowa ilość')
			else
				targetXPlayer.removeInventoryItem(itemName, amount)
				sourceXPlayer.addInventoryItem   (itemName, amount)
				TriggerClientEvent('esx:showNotification', _source, _U('you_confiscated', amount, sourceItem.label, targetXPlayer.name))
				TriggerClientEvent('esx:showNotification', target,  _U('got_confiscated', amount, sourceItem.label, sourceXPlayer.name))
			end
		else
			TriggerClientEvent('esx:showNotification', _source, 'Nieprawidłowa ilość')
		end

	elseif itemType == 'item_account' then
		targetXPlayer.removeAccountMoney(itemName, amount)
		sourceXPlayer.addAccountMoney   (itemName, amount)

		TriggerClientEvent('esx:showNotification', _source, 'Skonfiskowałeś ~g~' .. amount .. '~s~ (' .. itemName .. ') od ~b~' .. targetXPlayer.name .. '~s~')
		TriggerClientEvent('esx:showNotification', target, '~g~' .. amount .. '~s~ (' .. itemName .. ') zostały skonfiskowane przez ~y~' .. sourceXPlayer.name .. '~s~')

	elseif itemType == 'item_weapon' then
		if amount == nil then amount = 0 end
		targetXPlayer.removeWeapon(itemName, amount)
		sourceXPlayer.addWeapon   (itemName, amount)

		TriggerClientEvent('esx:showNotification', _source, 'Skonfiskowałeś ~b~' .. ESX.GetWeaponLabel(itemName) .. '~s~ od ~b~' .. targetXPlayer.name .. '~s~ z ~o~' .. amount .. '~s~ pociskami')
		TriggerClientEvent('esx:showNotification', target, 'Twój ~b~' .. ESX.GetWeaponLabel(itemName) .. '~s~ z ~o~' .. amount .. ')~s~ kulami został skonfiskowany przez ~y~' .. sourceXPlayer.name .. '~s~')
	end
end)


ESX.RegisterServerCallback('esx_policejob:getVehicleInfos', function(source, cb, plate)

	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)

		local retrivedInfo = {
			plate = plate
		}

		if result[1] then
			MySQL.Async.fetchAll('SELECT name, firstname, lastname FROM users WHERE identifier = @identifier',  {
				['@identifier'] = result[1].owner
			}, function(result2)

					retrivedInfo.owner = result2[1].firstname .. ' ' .. result2[1].lastname

				cb(retrivedInfo)
			end)
		else
			cb(retrivedInfo)
		end
	end)
end)



ESX.RegisterServerCallback('esx_policejob:getOtherPlayerData', function(source, cb, target)
		local xPlayer = ESX.GetPlayerFromId(target)
		local result = MySQL.Sync.fetchAll('SELECT firstname, lastname, sex, dateofbirth, height FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		})

		local firstname = result[1].firstname
		local lastname  = result[1].lastname
		local sex       = result[1].sex
		local dob       = result[1].dateofbirth
		local height    = result[1].height

		local data = {
			name      = GetPlayerName(target),
			job       = xPlayer.job,
			inventory = xPlayer.inventory,
			accounts  = xPlayer.accounts,
			weapons   = xPlayer.loadout,
			firstname = firstname,
			lastname  = lastname,
			sex       = sex,
			dob       = dob,
			height    = height
		}

		TriggerEvent('esx_status:getStatus', target, 'drunk', function(status)
			if status ~= nil then
				data.drunk = math.floor(status.percent)
			end
		end)

			TriggerEvent('esx_license:getLicenses', target, function(licenses)
				data.licenses = licenses
				cb(data)
			end)
end)

ESX.RegisterServerCallback('esx_policejob:getFineList', function(source, cb, category)
	MySQL.Async.fetchAll('SELECT * FROM fine_types WHERE category = @category', {
		['@category'] = category
	}, function(fines)
		cb(fines)
	end)
end)


RegisterServerEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
		TriggerClientEvent('esx_policejob:putInVehicle', target)
end)

RegisterServerEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
		TriggerClientEvent('esx_policejob:OutVehicle', target)
end)

RegisterServerEvent('esx_kajdanki:handcuff')
AddEventHandler('esx_kajdanki:handcuff', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

		TriggerClientEvent('esx_kajdanki:handcuff', target)
end)

RegisterServerEvent('esx_kajdanki:unrestrain')
AddEventHandler('esx_kajdanki:unrestrain', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

		TriggerClientEvent('esx_kajdanki:unrestrain', target)

end)

RegisterServerEvent('esx_kajdanki:drag')
AddEventHandler('esx_kajdanki:drag', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)

		TriggerClientEvent('esx_kajdanki:drag', target, source)

end)
