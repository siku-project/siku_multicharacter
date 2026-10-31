local INTRO_RESOURCE <const> = 'siku_intro'
local DEFAULT_MODEL <const> = 'mp_m_freemode_01'

---@param model unknown The model the client picked.
---@return string|nil model The model when the configuration offers it.
local function allowedModel(model)
  if type(model) ~= 'string' or model == '' then
    return nil
  end

  if Siku.table.contains(PedsConfig.basics, model) then
    return model
  end

  if PedsConfig.allowAll and Siku.table.contains(PedsConfig.peds, model) then
    return model
  end

  return nil
end

---@return boolean handover Whether the introduction takes the fresh character.
local function introAvailable()
  return SpawnConfig.introOnCreation and GetResourceState(INTRO_RESOURCE) == 'started'
end

RegisterNetEvent('siku_multicharacter:server:createCharacter', function(data)
  local sessionId <const> = source

  if type(data) ~= 'table' or not Characters.isValidIdentity(data.identity) then
    return
  end

  local user <const> = Siku.cache.getPlayer(sessionId)

  if not user then
    DropPlayer(tostring(sessionId), T('drop_account_load_failed'))
    return
  end

  if Characters.count(user.id) >= CharactersConfig.slots then
    TriggerClientEvent('siku_multicharacter:client:open', sessionId, 'selection')
    return
  end

  local model <const> = allowedModel(data.pedModel) or DEFAULT_MODEL
  local appearance <const> = type(data.appearance) == 'table' and data.appearance or nil
  local characterId <const> = Characters.insert(user.id, data.identity, model, appearance)
  local row <const> = characterId and MySQL.single.await('SELECT * FROM characters WHERE id = ?', { characterId })

  if not row then
    DropPlayer(tostring(sessionId), T('drop_character_create_failed'))
    return
  end

  local handover <const> = introAvailable()

  Characters.enter(sessionId, row, handover)

  if handover then
    exports[INTRO_RESOURCE]:Start(sessionId)
  end
end)
