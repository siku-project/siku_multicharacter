--- Resets every ped clothing component and prop to its default.
---@param ped number The ped handle.
---@return nil
local function setDefaultClothes(ped)
  for i = 0, 11 do
    SetPedComponentVariation(ped, i, 0, 0, 4)
  end

  for i = 0, 7 do
    ClearPedProp(ped, i)
  end
end

--- Stages the player at the staging spot as a fresh freemode ped behind
--- a black screen, then shuts the loading screen down.
---@return nil
local function stagePlayer()
  DoScreenFadeOut(500)
  Siku.waitFor(function()
    return IsScreenFadedOut() or nil
  end, T('error_screen_never_faded'), 2000)

  local staging <const> = SpawnConfig.characterSelectionSpawn
  local modelHash <const> = Siku.streaming.requestModel('mp_m_freemode_01')

  SetPlayerModel(PlayerId(), modelHash)
  SetModelAsNoLongerNeeded(modelHash)

  local playerPed <const> = PlayerPedId()

  setDefaultClothes(playerPed)

  SetEntityCoords(playerPed, staging.x, staging.y, staging.z, false, false, false, true)
  SetEntityHeading(playerPed, staging.w)
  FreezeEntityPosition(playerPed, true)
  SetPlayerControl(PlayerId(), false, 0)

  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()
end

RegisterNetEvent('siku_multicharacter:client:prepareCharacterCreation', function()
  stagePlayer()
  SetNuiFocus(true, true)
  SendNUIMessage({ action = 'siku_multicharacter:nui:setScreen', screen = 'creation' })
  Siku.print.debug('Routing to character creation')
end)
