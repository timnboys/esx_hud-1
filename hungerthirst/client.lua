ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)
    if IsPauseMenuActive() and not IsPaused then
	  IsPaused = true
    SendNUIMessage({action = "toggle", show = false})
    elseif not IsPauseMenuActive() and IsPaused then
    IsPaused = false
    SendNUIMessage({action = "toggle", show = true})
    end
  end
end)

AddEventHandler('ui:updateStatus', function(status)
  SendNUIMessage({action = "updateStatus", status = status})
  checkJob()
end)

function checkJob()
  praca = PlayerData.job.label .. ' - '..  PlayerData.job.grade_label
  SendNUIMessage({action = "praca", praca = praca})
end

function avatar()
  local mugshot, mugshotStr = ESX.Game.GetPedMugshot(GetPlayerPed(-1))
  ESX.ShowAdvancedNotification('Test', 'Testing!', 'Lool', mugshot, 1)
  print(mugshotStr)
  SendNUIMessage({action = "updateImage", mugshotStr = mugshotStr})
  UnregisterPedheadshot(mugshot)
end
