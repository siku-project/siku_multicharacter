local OPEN_EVENT <const> = 'siku_multicharacter:client:open'

---@param sessionId number
---@return table|nil user The cached account, or nil once the player was dropped.
local function requireUser(sessionId)
  local user <const> = Siku.cache.getPlayer(sessionId)

  if not user then
    DropPlayer(tostring(sessionId), T('drop_account_load_failed'))
  end

  return user
end

Siku.callback.register('siku_multicharacter:callback:characters', function(sessionId)
  local user <const> = requireUser(sessionId)

  if not user then
    return nil
  end

  local rows <const> = Characters.fetch(user.id)
  local characters <const> = {}
  local looks <const> = {}

  for slot = 1, math.min(#rows, CharactersConfig.slots) do
    characters[slot] = Characters.summarize(rows[slot], slot)
    looks[slot] = Characters.look(rows[slot])
  end

  return {
    characters = characters,
    looks = looks,
    config = {
      slots = CharactersConfig.slots,
      allowCharacterDeletion = CharactersConfig.allowDeletion,
      showDirtyMoney = false,
    },
  }
end)

RegisterNetEvent('siku_multicharacter:server:playCharacter', function(characterId)
  local sessionId <const> = source

  if type(characterId) ~= 'number' then
    return
  end

  local user <const> = requireUser(sessionId)

  if not user then
    return
  end

  local row <const> = Characters.find(user.id, characterId)

  if not row then
    TriggerClientEvent(OPEN_EVENT, sessionId, 'selection')
    return
  end

  Characters.prepareEntry(row)
  Characters.enter(sessionId, row, false)
end)

RegisterNetEvent('siku_multicharacter:server:deleteCharacter', function(characterId)
  local sessionId <const> = source

  if type(characterId) ~= 'number' then
    return
  end

  local user <const> = requireUser(sessionId)

  if not user then
    return
  end

  if CharactersConfig.allowDeletion and Characters.delete(user.id, characterId) then
    Siku.cache.removeCharacter(sessionId, characterId)
  end

  TriggerClientEvent(OPEN_EVENT, sessionId, Characters.count(user.id) > 0 and 'selection' or 'creation')
end)
