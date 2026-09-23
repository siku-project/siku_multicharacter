--- Whether a character row carries the dead flag, whatever the driver
--- hands back for the column.
---@param row table The character row.
---@return boolean dead The flag.
local function isRowDead(row)
  return row.is_dead == true or row.is_dead == 1
end

--- Clears the dead flag of a character entering the world when death is
--- not meant to survive a disconnect, before the core builds the
--- character from the row, so nothing downstream ever sees it dead.
---@param row table The character row, updated in place.
---@return nil
local function clearDeathWhenNotPersisted(row)
  if SpawnConfig.deathPersistence or not isRowDead(row) then
    return
  end

  MySQL.update.await('UPDATE characters SET is_dead = 0 WHERE id = ?', { row.id })
  row.is_dead = 0
end

RegisterNetEvent('siku_multicharacter:server:playCharacter', function(characterId)
  local sessionId <const> = source

  if type(characterId) ~= 'number' then
    Siku.print.error(T('error_invalid_character_payload', sessionId))
    return
  end

  local user <const> = Siku.cache.getPlayer(sessionId)

  if not user then
    Siku.print.error(T('error_no_user_for_character', sessionId))
    DropPlayer(tostring(sessionId), T('drop_account_load_failed'))
    return
  end

  local row <const> = MySQL.single.await(
    'SELECT * FROM characters WHERE id = ? AND user_id = ?',
    { characterId, user.id }
  )

  if not row then
    Siku.print.warn(T('warn_character_not_owned', characterId, user.id, sessionId))
    return
  end

  MySQL.update.await('UPDATE characters SET last_played = CURRENT_TIMESTAMP WHERE id = ?', { characterId })
  clearDeathWhenNotPersisted(row)

  TriggerEvent('siku:server:createCharacterInstance', sessionId, row)

  if SpawnConfig.playerInstance then
    Siku.bucket.releasePlayerInstance(sessionId)
  end

  Siku.print.debug(('Character %d joined the city (session %d)'):format(characterId, sessionId))

  TriggerClientEvent('siku_multicharacter:client:spawnCharacter', sessionId, {
    position = { x = row.x, y = row.y, z = row.z, heading = row.heading },
    model = row.ped_model,
    appearance = DecodeCharacterAppearance(row.appearance),
    dead = isRowDead(row),
  })
end)
