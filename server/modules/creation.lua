local INTRO_RESOURCE <const> = 'siku_intro'
local DEFAULT_MODEL <const> = 'mp_m_freemode_01'
local OPEN_EVENT <const> = 'siku_multicharacter:client:open'

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
    Flow.enter(sessionId, 'selection')

    Siku.log.debug('multicharacter.stage', ('%s: selection, every slot is taken'):format(user.name), {
      stage = 'selection',
      previous = 'appearance',
      seconds = 0,
      slots = CharactersConfig.slots,
    }, { source = sessionId, entities = Flow.entities(sessionId) })

    TriggerClientEvent(OPEN_EVENT, sessionId, 'selection')
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
  local previous <const>, seconds <const> = Flow.enter(sessionId, 'entering')
  local _, _, total <const> = Flow.get(sessionId)

  Flow.chose(sessionId, row.id, true)
  Characters.enter(sessionId, row, handover)

  Siku.log.audit('multicharacter.character_created', {
    message = ('%s created %s %s, character %d of %d'):format(user.name, row.first_name, row.last_name, Characters.count(user.id), CharactersConfig.slots),
    source = sessionId,
    entities = { { type = 'player', id = sessionId, role = 'actor' } },
    data = {
      character = {
        id = row.id,
        firstName = row.first_name,
        lastName = row.last_name,
        dob = row.dob,
        gender = row.gender,
        height = row.height,
        nationality = row.nationality,
        birthplace = row.birthplace,
        pedModel = row.ped_model,
      },
      slot = Characters.count(user.id),
      slots = CharactersConfig.slots,
      intro = handover,
      creationSeconds = total,
      appearanceSeconds = seconds,
      previous = previous,
    },
  })

  if handover then
    exports[INTRO_RESOURCE]:Start(sessionId)
  end
end)
