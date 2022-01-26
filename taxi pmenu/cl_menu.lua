ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
	    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	    Citizen.Wait(0)
    end  
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
    Citizen.Wait(5000)
end)

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- FACTURE ----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

function OpenBillingMenu()
    ESX.UI.Menu.Open(
        'dialog', GetCurrentResourceName(), 'facture',
        {
            title = 'Donner une facture'
        },
        function(data, menu)

            local amount = tonumber(data.value)

            if amount == nil or amount <= 0 then
                ESX.ShowNotification('Montant invalide')
            else
                menu.close()

                local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                if closestPlayer == -1 or closestDistance > 3.0 then
                    ESX.ShowNotification('Pas de joueurs proche')
                else
                    local playerPed        = PlayerPedId()

                    Citizen.CreateThread(function()
                        TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
                        Citizen.Wait(5000)
                        ClearPedTasks(playerPed)
                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_taxi', 'LS Taxi', amount)
                        ESX.ShowNotification("~r~Vous avez bien envoyer la facture")
                    end)
                end
            end
        end,
        function(data, menu)
            menu.close()
    end)
end

local function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(10)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

-----------------------------------------------------------------------------------------------------------------
---------------------------------------------- Menu F6 ----------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local announce = {
    "Ouvert",
    "Fermer"
}

local menuf6 = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Color = {color_black}, HeaderColor = {255, 255, 255}, Title = "MENU INTERACTION" },
    Data = { currentMenu = "Liste des actions :", "Test"},
    Events = {
        onSelected = function(self, _, btn, PMenu, menuData, result)
            PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
			local slide = btn.slidenum
            local btn = btn.name
         
            if btn == "Facturation" then   
                OpenBillingMenu()
            elseif slide == 1 and btn == "Annonce" then
                TriggerServerEvent("taxi:ouvert")
            elseif slide == 2 and btn == "Annonce" then
                TriggerServerEvent("taxi:fermer")
            elseif btn == "Passer une annonce" then -- Marche si vous possèder le /twt
                CloseMenu()
                local msg = KeyboardInput("Ecrivez votre annonce", "", 100)
                ExecutCommand("twt " ..msg)
            end 
    end,
},
    Menu = {
        ["Liste des actions :"] = {
            b = {
                {name = "Annonce", slidemax = announce},
                {name = "Facturation", ask = '>>', askX = true},
                {name = "Passer une annonce", ask = '>>', askX = true},
            }
        }
    }
} 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		if IsControlJustPressed(0,167) and PlayerData.job and PlayerData.job.name == 'taxi' then
			CreateMenu(menuf6)
		end
	end
end)