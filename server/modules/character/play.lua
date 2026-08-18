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

  TriggerEvent('siku:server:createCharacterInstance', sessionId, row)

  if SpawnConfig.playerInstance then
    Siku.bucket.releasePlayerInstance(sessionId)
  end

  Siku.print.debug(('Character %d joined the city (session %d)'):format(characterId, sessionId))

  TriggerClientEvent('siku_multicharacter:client:spawnCharacter', sessionId, {
    position = { x = row.x, y = row.y, z = row.z, heading = row.heading },
    model = row.ped_model,
    appearance = DecodeCharacterAppearance(row.appearance),
  })
end)
