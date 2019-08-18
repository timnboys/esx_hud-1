------------------------------------------------------------------
--                          Variables
------------------------------------------------------------------
local vehicles = {}
local showMenu = true
local toggleCoffre = 0
local toggleCapot = 0
local toggleLocked = 0
local playing_emote = false
local PlayerData, CurrentActionData, handcuffTimer, dragStatus, blipsCops, currentTask, spawnedVehicles = {}, {}, {}, {}, {}, {}, {}
local HasAlreadyEnteredMarker, isDead, IsHandcuffed, hasAlreadyJoined, playerInService, isInShopMenu = false, false, false, false, false, false
local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction, CurrentActionMsg
dragStatus.isDragged = false

------------------------------------------------------------------
--                          Functions
------------------------------------------------------------------

AddEventHandler("playerSpawned", function()
    TriggerServerEvent("ls:retrieveVehiclesOnconnect")
end)

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(1)
	end

	PlayerData = ESX.GetPlayerData()
end)


-- Show crosshair (circle) when player targets entities (vehicle, pedestrian…)
function Crosshair(enable)
  SendNUIMessage({
    crosshair = enable
  })
end

function closeMenu(menu)
	showMenu = menu
  SetNuiFocus(menu, menu)
end

-- Toggle focus (Example of Vehcile's menu)
RegisterNUICallback('disablenuifocus', function(data)
  showMenu = data.nuifocus
  SetNuiFocus(data.nuifocus, data.nuifocus)
end)

-- Toggle car trunk (Example of Vehcile's menu)
RegisterNUICallback('togglecoffre', function(data)
  if(toggleCoffre == 0)then
    SetVehicleDoorOpen(data.id, 5, false)
    toggleCoffre = 1
  else
    SetVehicleDoorShut(data.id, 5, false)
    toggleCoffre = 0
  end
end)

RegisterNUICallback('odholuj', function(data)
	if(PlayerData.job.name == 'police' or PlayerData.job.name == 'mechanic') then
		local playerPed = PlayerPedId()
		vehicle = ESX.Game.GetVehicleInDirection()
		TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TIME_OF_DEATH", 0, true)
		exports['progressBars']:startUI(14000, "Odholowanie...")
		showMenu = false
		SetNuiFocus(false, false)
		Citizen.Wait(5000)
		ClearPedTasks(playerPed)
		Citizen.Wait(9000)
		ESX.Game.DeleteVehicle(vehicle)
		ESX.ShowNotification('Samochód został odholowany')
	else
		ESX.ShowNotification('Nie jesteś upoważniony aby to zrobić')
	end
end)

RegisterNUICallback('odblokuj', function(data)
	if(PlayerData.job.name == 'police' or PlayerData.job.name == 'mechanic') then
		local playerPed = PlayerPedId()
		vehicle = ESX.Game.GetVehicleInDirection()
		TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
		exports['progressBars']:startUI(20000, "Otwieranie...")
		showMenu = false
		SetNuiFocus(false, false)
		Citizen.Wait(20000)
		ClearPedTasks(playerPed)
		SetVehicleDoorsLocked(vehicle, 1)
		SetVehicleDoorsLockedForAllPlayers(vehicle, false)
		ESX.ShowNotification('Auto zostało odblokowane')
	else
		ESX.ShowNotification('Nie jesteś upoważniony aby to zrobić')
	end
end)

RegisterNUICallback('napraw', function(data)
      	SetNuiFocus(false, false)
	if(PlayerData.job.name == 'mechanic') then
    local playerPed = PlayerPedId()
    local vehicle   = ESX.Game.GetVehicleInDirection()
    local coords    = GetEntityCoords(playerPed)

    if IsPedSittingInAnyVehicle(playerPed) then
      ESX.ShowNotification('Nie możesz być w środku pojazdu')
      return
    end

    if DoesEntityExist(vehicle) then
      TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
      Citizen.CreateThread(function()
        Citizen.Wait(20000)

        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true)
        ClearPedTasksImmediately(playerPed)

        ESX.ShowNotification('Pojazd naprawiony')
      end)
    else
      ESX.ShowNotification('Brak pojazdu w pobliżu')
    end
	else
		ESX.ShowNotification('Nie jesteś upoważniony aby to zrobić')
	end
end)

RegisterNUICallback('wyczysc', function(data)
  SetNuiFocus(false, false)
	if(PlayerData.job.name == 'mechanic') then
    local playerPed = PlayerPedId()
    local vehicle   = ESX.Game.GetVehicleInDirection()
    local coords    = GetEntityCoords(playerPed)

    if IsPedSittingInAnyVehicle(playerPed) then
      ESX.ShowNotification("Nie możesz iedzieć w pojeździe")
      return
    end

    if DoesEntityExist(vehicle) then
      TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
      Citizen.CreateThread(function()
        Citizen.Wait(10000)

        SetVehicleDirtLevel(vehicle, 0)
        ClearPedTasksImmediately(playerPed)

        ESX.ShowNotification("Pojazd wyczyszczony")
      end)
    else
      ESX.ShowNotification("Brak pojazd w pobliżu")
    end
	else
		ESX.ShowNotification('Nie jesteś upoważniony aby to zrobić')
	end
end)

RegisterNUICallback('faktura', function(data)
  SetNuiFocus(false, false)
	if(PlayerData.job.name == 'mechanic') then
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
      title = 'Kwota faktury'
    }, function(data, menu)
      local amount = tonumber(data.value)

      if amount == nil or amount < 0 then
        ESX.ShowNotification("Nieprawidłowa kwota")
      else
        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
        if closestPlayer == -1 or closestDistance > 3.0 then
          ESX.ShowNotification("Brak graczy w pobliżu")
        else
          menu.close()
          TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_mechanic', 'Mechanik', amount)
        end
      end
    end, function(data, menu)
      menu.close()
    end)
	else
		ESX.ShowNotification('Nie jesteś upoważniony aby to zrobić')
	end
end)

RegisterNUICallback('informacje', function(data)
	if(PlayerData.job.name == 'police' or PlayerData.job.name == 'mechanic') then

		vehicle = ESX.Game.GetVehicleInDirection()
		local vehicleData = ESX.Game.GetVehicleProperties(vehicle)

		ESX.TriggerServerCallback('esx_policejob:getVehicleInfos', function(retrivedInfo)
			local elements = {{label = 'Rejestracja:  ' .. retrivedInfo.plate}}

			if retrivedInfo.owner == nil then
				table.insert(elements, {label = 'Nieznany właściciel'})
			else
				table.insert(elements, {label = 'Właściciel:  ' .. retrivedInfo.owner})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'vehicle_infos', {
				title    = 'Informacje o aucie',
				align    = 'top-left',
				elements = elements
			}, nil, function(data, menu)
				menu.close()
			end)
		end, vehicleData.plate)
		showMenu = false
		SetNuiFocus(false, false)
	else
		ESX.ShowNotification('Nie jesteś upoważniony aby to zrobić')
	end
end)

RegisterNUICallback('togglecapot', function(data)
  if(toggleCapot == 0)then
    SetVehicleDoorOpen(data.id, 4, false)
    toggleCapot = 1
  else
    SetVehicleDoorShut(data.id, 4, false)
    toggleCapot = 0
  end
end)

-- Example of animation (Ped's menu)
RegisterNUICallback('cheer', function(data)
  playerPed = GetPlayerPed(-1);
		if(not IsPedInAnyVehicle(playerPed)) then
			if playerPed then
				if playing_emote == false then
					TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_CHEERING', 0, true);
					playing_emote = true
				end
			end
		end
end)

RegisterNUICallback('dowod', function(data)
	if(PlayerData.job.name == 'police') then
		local player, closestDistance = ESX.Game.GetClosestPlayer()
		if player ~= -1 and closestDistance <= 3.0 then
			ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
				local elements = {}
				local nameLabel = 'Imię:  ' .. data.name
				local jobLabel, sexLabel, dobLabel, heightLabel, idLabel

				if data.job.grade_label and  data.job.grade_label ~= '' then
					jobLabel = 'Praca:  ' .. data.job.label .. ' - ' .. data.job.grade_label
				else
					jobLabel = 'Praca:  ' .. data.job.label
				end

					nameLabel = 'Imię:  ' .. data.firstname .. ' ' .. data.lastname

					if data.sex then
						if string.lower(data.sex) == 'm' then
							sexLabel = 'Płeć:  Mężczyzna'
						else
							sexLabel = 'Płeć:  Kobieta'
						end
					else
						sexLabel = 'Płeć:  Nieznana'
					end

					if data.dob then
						dobLabel = 'Data urodzenia:  ' .. data.dob
					else
						dobLabel = 'Data urodzenia:  Nieznana'
					end

					if data.height then
						heightLabel = 'Wzrost:  ' .. data.height
					else
						heightLabel = 'Wzrost:  Nieznany'
					end

					if data.name then
						idLabel = 'ID:  ' .. data.name
					else
						idLabel = 'ID:  Nieznane'
					end

				local elements = {
					{label = nameLabel},
					{label = jobLabel}
				}

					table.insert(elements, {label = sexLabel})
					table.insert(elements, {label = dobLabel})
					table.insert(elements, {label = heightLabel})
					table.insert(elements, {label = idLabel})

				if data.drunk then
					table.insert(elements, {label = _U('bac', data.drunk)})
				end

				if data.licenses then
					table.insert(elements, {label = '--- Licencje ---'})

					for i=1, #data.licenses, 1 do
						table.insert(elements, {label = data.licenses[i].label})
					end
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
					title    = 'Dowód',
					align    = 'top-left',
					elements = elements
				}, nil, function(data, menu)
					menu.close()
				end)
			end, GetPlayerServerId(player))
		else
			ESX.ShowNotification('Nie ma żadnego gracza w pobliżu')
		end
			showMenu = false
			SetNuiFocus(false, false)
	else
		ESX.ShowNotification('Nie jesteś upoważniony aby to zrobić')
	end
end)

RegisterNUICallback('mandat', function(data)
	if(PlayerData.job.name == 'police') then
		local player, closestDistance = ESX.Game.GetClosestPlayer()
		if player ~= -1 and closestDistance <= 3.0 then
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine', {
			title    = 'Mandaty',
			align    = 'top-left',
			elements = {
				{label = 'Wykroczenia drogowe', value = 0},
				{label = 'Niewielkie wykroczenia',   value = 1},
				{label = 'Średnie wykroczenia', value = 2},
				{label = 'Poważne wykroczenia',   value = 3}
		}}, function(data, menu)
			OpenFineCategoryMenu(player, data.current.value)
		end, function(data, menu)
			menu.close()
		end)
		else
		ESX.ShowNotification('Nie ma żadnego gracza w pobliżu')
	end
	showMenu = false
	SetNuiFocus(false, false)
	else
		ESX.ShowNotification('Nie jesteś upoważniony aby to zrobić')
	end
end)

RegisterNUICallback('rachunki', function(data)
	if(PlayerData.job.name == 'police') then
		local player, closestDistance = ESX.Game.GetClosestPlayer()
		if player ~= -1 and closestDistance <= 3.0 then
			local elements = {}

			ESX.TriggerServerCallback('esx_billing:getTargetBills', function(bills)
				for k,bill in ipairs(bills) do
					table.insert(elements, {
						label = ('%s - <span style="color:red;">%s</span>'):format(bill.label, '$ ' .. ESX.Math.GroupDigits(bill.amount)),
						billId = bill.id
					})
				end

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing', {
					title    = 'Niezapłacone rachunki',
					align    = 'top-left',
					elements = elements
				}, nil, function(data, menu)
					menu.close()
				end)
			end, GetPlayerServerId(player))
		else
		ESX.ShowNotification('Nie ma żadnego gracza w pobliżu')
	end
	showMenu = false
	SetNuiFocus(false, false)
	else
		ESX.ShowNotification('Nie jesteś upoważniony aby to zrobić')
	end
end)


RegisterNUICallback('zakuj', function(data)
		local player, closestDistance = ESX.Game.GetClosestPlayer()
		if player ~= -1 and closestDistance <= 3.0 then
			TriggerServerEvent('esx_kajdanki:handcuff', GetPlayerServerId(player))
		else
		ESX.ShowNotification('Nie ma żadnego gracza w pobliżu')
	end
end)

RegisterNUICallback('przemiesc', function(data)
		local player, closestDistance = ESX.Game.GetClosestPlayer()
		if player ~= -1 and closestDistance <= 3.0 then
			TriggerServerEvent('esx_kajdanki:drag', GetPlayerServerId(closestPlayer))
		else
		ESX.ShowNotification('Nie ma żadnego gracza w pobliżu')
	end
	showMenu = false
	SetNuiFocus(false, false)
end)

RegisterNUICallback('przeszukaj', function(data)
		local player, closestDistance = ESX.Game.GetClosestPlayer()
		if player ~= -1 and closestDistance <= 3.0 then
			TriggerServerEvent('esx_policejob:message', GetPlayerServerId(player), "Jesteś przeszukiwany")
			OpenBodySearchMenu(player)
		else
		ESX.ShowNotification('Nie ma żadnego gracza w pobliżu')
	end
	showMenu = false
	SetNuiFocus(false, false)
end)

RegisterNUICallback('wloz', function(data)
		local player, closestDistance = ESX.Game.GetClosestPlayer()
		if player ~= -1 and closestDistance <= 3.0 then
			TriggerServerEvent('esx_policejob:putInVehicle', GetPlayerServerId(player))
		else
		ESX.ShowNotification('Nie ma żadnego gracza w pobliżu')
	end
	showMenu = false
	SetNuiFocus(false, false)
end)

RegisterNUICallback('wyciagnij', function(data)
		local player, closestDistance = ESX.Game.GetClosestPlayer()
		if player ~= -1 and closestDistance <= 3.0 then
			TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(player))
		else
		ESX.ShowNotification('Nie ma żadnego gracza w pobliżu')
	end
	showMenu = false
	SetNuiFocus(false, false)
end)




RegisterNetEvent('esx_kajdanki:handcuff')
AddEventHandler('esx_kajdanki:handcuff', function()
	IsHandcuffed    = not IsHandcuffed
	local playerPed = PlayerPedId()

	Citizen.CreateThread(function()
		if IsHandcuffed then
			IsHandcuffed = true

			RequestAnimDict('mp_arresting')
			while not HasAnimDictLoaded('mp_arresting') do
				Citizen.Wait(100)
			end

			TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, 2, 49, 0, 0, 0, 0)

			SetEnableHandcuffs(playerPed, true)
			DisablePlayerFiring(playerPed, true)
			SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
			SetPedCanPlayGestureAnims(playerPed, false)
			FreezeEntityPosition(playerPed, false)
			DisplayRadar(false)

		else
			ClearPedTasks(playerPed)
			ClearPedSecondaryTask(playerPed)
			SetEnableHandcuffs(playerPed, false)
			DisablePlayerFiring(playerPed, false)
			SetPedCanPlayGestureAnims(playerPed, true)
			FreezeEntityPosition(playerPed, false)
			DisplayRadar(true)
		end
	end)
end)

RegisterNetEvent('esx_kajdanki:unrestrain')
AddEventHandler('esx_kajdanki:unrestrain', function()
	if IsHandcuffed then
		local playerPed = PlayerPedId()
		IsHandcuffed = false

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)

		-- end timer
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)


RegisterNetEvent('esx_kajdanki:drag')
AddEventHandler('esx_kajdanki:drag', function(copId)
	if not IsHandcuffed then
		return
	end

	dragStatus.isDragged = not dragStatus.isDragged
	dragStatus.CopId = copId
end)

Citizen.CreateThread(function()
	local playerPed
	local targetPed

	while true do
		Citizen.Wait(1)

		if IsHandcuffed then
			playerPed = PlayerPedId()

			if dragStatus.isDragged then
				targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))

				-- undrag if target is in an vehicle
				if not IsPedSittingInAnyVehicle(targetPed) then
					AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, 160, false, false, false, 2, true)
				else
					dragStatus.isDragged = false
					DetachEntity(playerPed, true, false)
				end

				if IsPedDeadOrDying(targetPed, true) then
					dragStatus.isDragged = false
					DetachEntity(playerPed, true, false)
				end

			else
				DetachEntity(playerPed, true, false)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('esx_kajdanki:unrestrain')
AddEventHandler('esx_kajdanki:unrestrain', function()
	if IsHandcuffed then
		local playerPed = PlayerPedId()
		IsHandcuffed = false

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)

		-- end timer
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

RegisterNetEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	if not IsHandcuffed then
		return
	end

	if IsAnyVehicleNearPoint(coords, 5.0) then
		local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

		if DoesEntityExist(vehicle) then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				dragStatus.isDragged = false
			end
		end
	end
end)

RegisterNetEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function()
	local playerPed = PlayerPedId()

	if not IsPedSittingInAnyVehicle(playerPed) then
		return
	end

	local vehicle = GetVehiclePedIsIn(playerPed, false)
	TaskLeaveVehicle(playerPed, vehicle, 16)
end)


function OpenBodySearchMenu(player)
	ESX.ShowNotification('Cipka')
	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		ESX.ShowNotification('Chuj')
		local elements = {}

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
				table.insert(elements, {
					label    = 'Skonfiskuj brudne pieniądze: <span style="color:red;">$ '.. ESX.Math.Round(data.accounts[i].money) ..'</span>',
					value    = 'black_money',
					itemType = 'item_account',
					amount   = data.accounts[i].money
				})

				break
			end
		end

		table.insert(elements, {label = '--- Bronie ---'})

		for i=1, #data.weapons, 1 do
			table.insert(elements, {
				label    = 'Skonfiskuj ' .. ESX.GetWeaponLabel(data.weapons[i].name) .. ' z ' .. data.weapons[i].ammo .. ' kulami',
				value    = data.weapons[i].name,
				itemType = 'item_weapon',
				amount   = data.weapons[i].ammo
			})
		end

		table.insert(elements, {label = '--- Ekwipunek ---'})

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(elements, {
					label    = 'Skonfiskuj ' .. data.inventory[i].count .. ' x ' .. data.inventory[i].label,
					value    = data.inventory[i].name,
					itemType = 'item_standard',
					amount   = data.inventory[i].count
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
			title    = 'Przeszukaj',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value then
				TriggerServerEvent('esx_policejob:confiscatePlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
				OpenBodySearchMenu(player)
			end
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end



function OpenFineCategoryMenu(player, category)
	ESX.TriggerServerCallback('esx_policejob:getFineList', function(fines)
		local elements = {}

		for k,fine in ipairs(fines) do
			table.insert(elements, {
				label     = ('%s <span style="color:green;">%s</span>'):format(fine.label, '$' .. ESX.Math.GroupDigits(fine.amount)),
				value     = fine.id,
				amount    = fine.amount,
				fineLabel = fine.label
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine_category', {
			title    = 'Mandaty',
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			menu.close()

				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_police', _U('fine_total', data.current.fineLabel), data.current.amount)

			ESX.SetTimeout(300, function()
				OpenFineCategoryMenu(player, category)
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, category)
end

function GetCoordsFromCam(distance)
  local rot = GetGameplayCamRot(2)
  local coord = GetGameplayCamCoord()

  local tZ = rot.z * 0.0174532924
  local tX = rot.x * 0.0174532924
  local num = math.abs(math.cos(tX))

  newCoordX = coord.x + (-math.sin(tZ)) * (num + distance)
  newCoordY = coord.y + (math.cos(tZ)) * (num + distance)
  newCoordZ = coord.z + (math.sin(tX) * 8.0)
  return newCoordX, newCoordY, newCoordZ
end

-- Get entity's ID and coords from where player sis targeting
function Target(Distance, Ped)
  local Entity = nil
  local camCoords = GetGameplayCamCoord()
  local farCoordsX, farCoordsY, farCoordsZ = GetCoordsFromCam(Distance)
  local RayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, farCoordsX, farCoordsY, farCoordsZ, -1, Ped, 0)
  local A,B,C,D,Entity = GetRaycastResult(RayHandle)
  return Entity, farCoordsX, farCoordsY, farCoordsZ
end





------------------------------------------------------------------
--                          Citizen
------------------------------------------------------------------

Citizen.CreateThread(function()

	while true do
	--Citizen.Wait(0)
    local Ped = GetPlayerPed(-1)
    -- Get informations about what user is targeting
    -- /!\ If not working, check that you have added "target" folder to resources and server.cfg
    --local Entity, farCoordsX, farCoordsY, farCoordsZ = exports.target:Target(6.0, Ped)
	local Entity, farCoordsX, farCoordsY, farCoordsZ = Target(6.0, Ped)

	--local Entity, farCoordsX, farCoordsY, farCoordsZ = Target(6.0, Ped)
    local EntityType = GetEntityType(Entity)
    -- If EntityType is Vehicle
    if(EntityType == 2) then
      Crosshair(true)
      if IsControlJustReleased(1, 38) then -- E is pressed
        showMenu = true
        SetNuiFocus(true, true)
        SendNUIMessage({
          menu = 'vehicle',
          idEntity = Entity,
          praca = PlayerData.job.name
        })
      end
    -- If EntityType = User
    elseif(EntityType == 1) then
      Crosshair(true)

      if IsControlJustReleased(1, 38) then -- E is pressed1
        ESX.TriggerServerCallback('menu:inventory', function(qtty)
          showMenu = true
          SetNuiFocus(true, true)
          SendNUIMessage({
            menu = 'user',
            idEntity = Entity,
            praca = PlayerData.job.name,
            kajdanki = qtty
          })
        end, 'bread')
      end
    else
      Crosshair(false)
    end
    -- Stop emotes if user press E
    -- TODO: Stop emotes if user move
    if playing_emote == true then
      if IsControlPressed(1, 38) then
        ClearPedTasks(Ped)
        playing_emote = false
      end
    end

	if IsControlPressed(1, 38) then
        ClearPedTasks(Ped)
        playing_emote = false
		if showMenu == false then
			SetNuiFocus(false, false)
		end
    end
    Citizen.Wait(1)
	end
end)

Citizen.CreateThread(function()
  while true do
    while ESX == nil do
  		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
  		Citizen.Wait(0)
  	end

    local player, closestDistance = ESX.Game.GetClosestPlayer()
    if player ~= -1 and closestDistance <= 2.0 then
      Crosshair(true)
      if IsControlJustReleased(1, 38) then
        ESX.TriggerServerCallback('menu:inventory', function(qtty)
        showMenu = true
        SetNuiFocus(true, true)
        SendNUIMessage({
          menu = 'user',
          idEntity = Entity,
          praca = PlayerData.job.name,
          kajdanki = qtty
        })
            end, 'bread')
      end
    end
    Citizen.Wait(5)
  end
end)




Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()


		if IsHandcuffed then
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				end)
			end
		else
			Citizen.Wait(500)
		end
	end
end)
