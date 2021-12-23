Config = {}

Config.ServiceExtensionOnEscape		= 3
Config.ServiceLocation 				= {x =  170.43, y = -990.7, z = 30.09}

Config.ServiceLocations = {
	{ type = "cleaning", coords = vector3(170.0, -1006.0, 29.34) },
	{ type = "cleaning", coords = vector3(177.0, -1007.94, 29.33) },
	{ type = "cleaning", coords = vector3(181.58, -1009.46, 29.34) },
	{ type = "cleaning", coords = vector3(189.33, -1009.48, 29.34) },
	{ type = "cleaning", coords = vector3(195.31, -1016.0, 29.34) },
	{ type = "cleaning", coords = vector3(169.97, -1001.29, 29.34) },
	{ type = "cleaning", coords = vector3(164.74, -1008.0, 29.43) },
	{ type = "cleaning", coords = vector3(163.28, -1000.55, 29.35) },
	{ type = "gardening", coords = vector3(181.38, -1000.05, 29.29) },
	{ type = "gardening", coords = vector3(188.43, -1000.38, 29.29) },
	{ type = "gardening", coords = vector3(194.81, -1002.0, 29.29) },
	{ type = "gardening", coords = vector3(198.97, -1006.85, 29.29) },
	{ type = "gardening", coords = vector3(201.47, -1004.37, 29.29) }
}



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
  
  INPUT_CONTEXT = 51
  
  local isSentenced = false
  local communityServiceFinished = false
  local actionsRemaining = 0
  local availableActions = {}
  local disable_actions = false
  
  local vassoumodel = "prop_tool_broom"
  local vassour_net = nil
  
  local spatulamodel = "bkr_prop_coke_spatula_04"
  local spatula_net = nil
  

    
 Citizen.CreateThread(function()
      Citizen.Wait(2000) --Wait for mysql-async
      TriggerServerEvent('zaza_sweepthefloor:checkIfSentenced')
  end)
  
  
  function FillActionTable(last_action)
  
      while #availableActions < 5 do
  
          local service_does_not_exist = true
  
          local random_selection = Config.ServiceLocations[math.random(1,#Config.ServiceLocations)]
  
          for i = 1, #availableActions do
              if random_selection.coords.x == availableActions[i].coords.x and random_selection.coords.y == availableActions[i].coords.y and random_selection.coords.z == availableActions[i].coords.z then
  
                  service_does_not_exist = false
  
              end
          end
  
          if last_action ~= nil and random_selection.coords.x == last_action.coords.x and random_selection.coords.y == last_action.coords.y and random_selection.coords.z == last_action.coords.z then
              service_does_not_exist = false
          end
  
          if service_does_not_exist then
              table.insert(availableActions, random_selection)
          end
  
      end
  
  end
  
  
  RegisterNetEvent('zaza_sweepthefloor:inCommunityService')
  AddEventHandler('zaza_sweepthefloor:inCommunityService', function(actions_remaining)
      local playerPed = PlayerPedId()
  
      if isSentenced then
          return
      end
  
      actionsRemaining = actions_remaining
  
      FillActionTable()
      print(":: Available Actions: " .. #availableActions)
  
      local ped = PlayerPedId()
  
      SetEntityCoords(ped, 170.43, -990.7, 30.09) -- this is the service location, sends them to where they get served. (set to legion rn)
      isSentenced = true
      communityServiceFinished = false
  
      while actionsRemaining > 0 and communityServiceFinished ~= true do
  
  
          if IsPedInAnyVehicle(playerPed, false) then
              ClearPedTasksImmediately(playerPed)
          end
  
          Citizen.Wait(20000)
  
          if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.ServiceLocation.x, Config.ServiceLocation.y, Config.ServiceLocation.z) > 45 then
              SetEntityCoords(ped, 170.43, -990.7, 30.09)
                  TriggerServerEvent('zaza_sweepthefloor:extendService')
                  actionsRemaining = actionsRemaining + 8
          end
  
      end
  
      TriggerServerEvent('zaza_sweepthefloor:finishCommunityService', -1)
      SetEntityCoords(playerPed, 427.33, -979.51, 30.2)
      isSentenced = false
  end)
  
  
  
  RegisterNetEvent('zaza_sweepthefloor:finishCommunityService')
  AddEventHandler('zaza_sweepthefloor:finishCommunityService', function(source)
      communityServiceFinished = true
      isSentenced = false
      actionsRemaining = 0
  end)
  
  
  
  Citizen.CreateThread(function()
      while true do
          :: start_over ::
          Citizen.Wait(2)
  
           if actionsRemaining > 0 or actionsRemaining > 1 and isSentenced then
        if isSentenced then
            --   draw2dText( _U('remaining_msg', Math.Round(actionsRemaining)), { 0.175, 0.955 } )
            --  draw2dText("Remaining.. " ..math.round(actionsRemaining).. 0.175, 0.955)

            draw2dText("Remaining Actions.. ~r~ ".. actionsRemaining.. "", 0.496, 0.1000)
            --   print("Remaining... " )
              DrawAvailableActions()
              DisableViolentActions()
  
              local pCoords    = GetEntityCoords(PlayerPedId())
  
              for i = 1, #availableActions do
                  local distance = GetDistanceBetweenCoords(pCoords, availableActions[i].coords, true)
  
                  if distance < 1.5 then
                      DisplayHelpText("Press [~r~E~w~] ~w~To Clean")
  
  
                      if(IsControlJustReleased(1, 38))then
                          tmp_action = availableActions[i]
                          RemoveAction(tmp_action)
                          FillActionTable(tmp_action)
                          disable_actions = true
  
                          TriggerServerEvent('zaza_sweepthefloor:completeService')
                          actionsRemaining = actionsRemaining - 1
  
                          if (tmp_action.type == "cleaning") then
                              local cSCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
                              local vassouspawn = CreateObject(GetHashKey(vassoumodel), cSCoords.x, cSCoords.y, cSCoords.z, 1, 1, 1)
                              local netid = ObjToNet(vassouspawn)
  
                            --   RequestAnimDict("amb@world_human_janitor@male@idle_a", function()
                            --           TaskPlayAnim(PlayerPedId(), "amb@world_human_janitor@male@idle_a", "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false)
                            Config.AnimCurr  = 'WORLD_HUMAN_JANITOR'
                            local ped = PlayerPedId()

                            TaskStartScenarioInPlace(ped, Config.AnimCurr, 0, true);
                                      AttachEntityToEntity(vassouspawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
                                      DisplayHelpText("Cleaning This Shit..")
                                      vassour_net = netid
                                
  
                                  Citizen.SetTimeout(10000, function()
                                      disable_actions = false
                                      DetachEntity(NetToObj(vassour_net), 1, 1)
                                      DeleteEntity(NetToObj(vassour_net))
                                      vassour_net = nil
                                      ClearPedTasks(PlayerPedId())
                                  end)
  
                          end
  
                          if (tmp_action.type == "gardening") then
                              local cSCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
                              local spatulaspawn = CreateObject(GetHashKey(spatulamodel), cSCoords.x, cSCoords.y, cSCoords.z, 1, 1, 1)
                              local netid = ObjToNet(spatulaspawn)
  
                              TaskStartScenarioInPlace(PlayerPedId(), "world_human_gardener_plant", 0, false)
                              AttachEntityToEntity(spatulaspawn,GetPlayerPed(PlayerId()),GetPedBoneIndex(GetPlayerPed(PlayerId()), 28422),-0.005,0.0,0.0,190.0,190.0,-50.0,1,1,0,1,0,1)
                              spatula_net = netid
  
                              Citizen.SetTimeout(14000, function()
                                  disable_actions = false
                                  DetachEntity(NetToObj(spatula_net), 1, 1)
                                  DeleteEntity(NetToObj(spatula_net))
                                  spatula_net = nil
                                  ClearPedTasks(PlayerPedId())
                              end)
                          end
  
                          goto start_over
                      end
                  end
              end
          else
              Citizen.Wait(1000)
          end
      end
    end
  end)
  
  
  function RemoveAction(action)
  
      local action_pos = -1
  
      for i=1, #availableActions do
          if action.coords.x == availableActions[i].coords.x and action.coords.y == availableActions[i].coords.y and action.coords.z == availableActions[i].coords.z then
              action_pos = i
          end
      end
  
      if action_pos ~= -1 then
          table.remove(availableActions, action_pos)
      else
          print("User tried to remove an unavailable action")
      end
  
  end
  
  
  
  
  
  
  
  function DisplayHelpText(str)
      SetTextComponentFormat("STRING")
      AddTextComponentString(str)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)
  end
  
  
  function DrawAvailableActions()
      for i = 1, #availableActions do
          DrawMarker(21, availableActions[i].coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 50, 50, 204, 100, false, true, 2, true, false, false, false)
      end
  
  end
  
  
  
  
  
  
  function DisableViolentActions()
  
      local playerPed = PlayerPedId()
  
      if disable_actions == true then
          DisableAllControlActions(0)
      end
  
      RemoveAllPedWeapons(playerPed, true)
  
      DisableControlAction(2, 37, true) -- disable weapon wheel (Tab)
      DisablePlayerFiring(playerPed,true) -- Disables firing all together if they somehow bypass inzone Mouse Disable
      DisableControlAction(0, 106, true) -- Disable in-game mouse controls
      DisableControlAction(0, 140, true)
      DisableControlAction(0, 141, true)
      DisableControlAction(0, 142, true)
  
      if IsDisabledControlJustPressed(2, 37) then --if Tab is pressed, send error message
          SetCurrentPedWeapon(playerPed,GetHashKey("WEAPON_UNARMED"),true) -- if tab is pressed it will set them to unarmed (this is to cover the vehicle glitch until I sort that all out)
      end
  
      if IsDisabledControlJustPressed(0, 106) then --if LeftClick is pressed, send error message
          SetCurrentPedWeapon(playerPed,GetHashKey("WEAPON_UNARMED"),true) -- If they click it will set them to unarmed
      end
  
  end
  
  
  
  function draw2dText(text, pos)
      SetTextFont(4)
      SetTextProportional(1)
      SetTextScale(0.47, 0.47)
      SetTextColour(255, 255, 255, 255)
      SetTextDropShadow(0, 0, 0, 0, 255)
      SetTextEdge(1, 0, 0, 0, 255)
      SetTextDropShadow()
      SetTextOutline()
  
      BeginTextCommandDisplayText('STRING')
      AddTextComponentSubstringPlayerName(text)
    --   EndTextCommandDisplayText(table.unpack(pos))
    EndTextCommandDisplayText((pos))
  end
  