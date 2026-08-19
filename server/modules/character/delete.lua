--- Routes a player back to the screen matching what is left of their
--- roster: selection when at least one character remains, creation when
--- the account is empty.
---@param sessionId number The player server ID.
---@param userId number The account ID.
---@return nil
local function routeAfterDeletion(sessionId, userId)
  local remaining <const> = MySQL.scalar.await(
    'SELECT COUNT(*) FROM characters WHERE user_id = ?',
    { userId }
  )

  if (remaining or 0) > 0 then
    TriggerClientEvent('siku_multicharacter:client:prepareCharacterSelect', sessionId)
    return
  end

  TriggerClientEvent('siku_multicharacter:client:prepareCharacterCreation', sessionId)
end

RegisterNetEvent('siku_multicharacter:server:deleteCharacter', function(characterId)
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

  if not SpawnConfig.playerCanDeleteCharacter then
    Siku.print.warn(T('warn_delete_not_allowed', characterId, sessionId))
    routeAfterDeletion(sessionId, user.id)
    return
  end

  local deleted <const> = MySQL.update.await(
    'DELETE FROM characters WHERE id = ? AND user_id = ?',
    { characterId, user.id }
  )

  if (deleted or 0) == 0 then
    Siku.print.warn(T('warn_character_not_owned', characterId, user.id, sessionId))
    routeAfterDeletion(sessionId, user.id)
    return
  end

  MySQL.update.await(
    'UPDATE users SET last_played_character = NULL WHERE id = ? AND last_played_character = ?',
    { user.id, characterId }
  )

  user:removeCharacter(characterId)

  Siku.print.info(T('info_character_deleted', characterId, user.id, sessionId))

  routeAfterDeletion(sessionId, user.id)
end)
