local SELECTION_MODEL <const> = 'mp_m_freemode_01'

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

--- Stages the player at the staging spot behind a black screen, then
--- shuts the loading screen down. The selection screen shows no scene,
--- so no camera is involved.
---@return nil
local function stageForSelection()
  DoScreenFadeOut(500)
  Siku.WaitFor(function()
    return IsScreenFadedOut() or nil
  end, T('error_screen_never_faded'), 2000)

  local staging <const> = SpawnConfig.characterSelectionSpawn
  local modelHash <const> = Siku.RequestModel(SELECTION_MODEL)

  SetPlayerModel(PlayerId(), modelHash)
  SetModelAsNoLongerNeeded(modelHash)

  local ped <const> = PlayerPedId()

  setDefaultClothes(ped)

  SetEntityCoords(ped, staging.x, staging.y, staging.z, false, false, false, true)
  SetEntityHeading(ped, staging.w)
  FreezeEntityPosition(ped, true)
  SetEntityVisible(ped, false, false)
  SetPlayerControl(PlayerId(), false, 0)

  ShutdownLoadingScreen()
  ShutdownLoadingScreenNui()
end

RegisterNetEvent('siku_multicharacter:client:prepareCharacterSelect', function()
  stageForSelection()

  local ok <const>, payload = Siku.TriggerServerCallback('siku_multicharacter:callback:getCharacters')

  if not ok then
    Siku.print.error(T('error_characters_fetch_failed', tostring(payload)))
    return
  end

  SendNUIMessage({
    action = 'siku_multicharacter:nui:setCharacters',
    characters = payload.characters or {},
    config = payload.config or {},
  })

  SetNuiFocus(true, true)
  SendNUIMessage({ action = 'siku_multicharacter:nui:setScreen', screen = 'selection' })

  Siku.print.debug(('Character selection opened with %d character(s)'):format(#(payload.characters or {})))
end)
