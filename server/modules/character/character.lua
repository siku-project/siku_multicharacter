local DEFAULT_PED <const> = 'mp_m_freemode_01'

--- Checks that an identity carries everything the characters table needs.
---@param identity table The identity submitted by the client.
---@return boolean valid Whether the identity is complete.
local function isIdentityValid(identity)
  if type(identity) ~= 'table' then
    return false
  end

  return type(identity.firstName) == 'string' and identity.firstName ~= ''
    and type(identity.lastName) == 'string' and identity.lastName ~= ''
    and type(identity.birthDay) == 'string' and identity.birthDay ~= ''
    and type(identity.birthMonth) == 'string' and identity.birthMonth ~= ''
    and type(identity.birthYear) == 'string' and identity.birthYear ~= ''
    and type(identity.birthPlace) == 'string' and identity.birthPlace ~= ''
    and type(identity.nationality) == 'string' and identity.nationality ~= ''
end

--- Formats the birth date of an identity for the DATE column.
---@param identity table The identity submitted by the client.
---@return string date The date as YYYY-MM-DD.
local function formatBirthDate(identity)
  return ('%04d-%02d-%02d'):format(
    tonumber(identity.birthYear) or 0,
    tonumber(identity.birthMonth) or 0,
    tonumber(identity.birthDay) or 0
  )
end

RegisterNetEvent('siku_multicharacter:server:createCharacter', function(data)
  local sessionId <const> = source

  if type(data) ~= 'table' or not isIdentityValid(data.identity) then
    Siku.print.error(T('error_invalid_character_payload', sessionId))
    return
  end

  local user <const> = Siku.cache.getPlayer(sessionId)

  if not user then
    Siku.print.error(T('error_no_user_for_character', sessionId))
    DropPlayer(tostring(sessionId), T('drop_account_load_failed'))
    return
  end

  local identity <const> = data.identity
  local spawn <const> = SpawnConfig.spawnPosition

  local characterId <const> = MySQL.insert.await(
    'INSERT INTO characters (user_id, first_name, last_name, dob, gender, height, nationality, birthplace, ped_model, appearance, x, y, z, heading) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    {
      user.id,
      identity.firstName,
      identity.lastName,
      formatBirthDate(identity),
      identity.gender or 'male',
      math.floor(tonumber(identity.height) or 175),
      identity.nationality,
      identity.birthPlace,
      data.pedModel ~= '' and data.pedModel or DEFAULT_PED,
      json.encode(data.appearance or {}),
      spawn.x, spawn.y, spawn.z, spawn.w,
    }
  )

  if not characterId then
    Siku.print.error(T('error_character_create_failed', identity.firstName, sessionId))
    DropPlayer(tostring(sessionId), T('drop_character_create_failed'))
    return
  end

  local characterData <const> = MySQL.single.await('SELECT * FROM characters WHERE id = ?', { characterId })

  if not characterData then
    Siku.print.error(T('error_character_load_failed', characterId, sessionId))
    DropPlayer(tostring(sessionId), T('drop_character_create_failed'))
    return
  end

  TriggerEvent('siku:server:createCharacterInstance', sessionId, characterData)

  if SpawnConfig.playerInstance then
    Siku.bucket.releasePlayerInstance(sessionId)
  end

  Siku.print.debug(('Character %d created for user %d (session %d)'):format(characterId, user.id, sessionId))

  TriggerClientEvent('siku_multicharacter:client:spawnCharacter', sessionId, {
    position = {
      x = characterData.x,
      y = characterData.y,
      z = characterData.z,
      heading = characterData.heading,
    },
  })
end)
