--- Creates a new account, instantiates it in the core cache and routes the
--- client straight to the character creation screen.
---@param sessionId number The player server ID.
---@param license string The primary license.
---@param identifiers PlayerIdentifiers The player identifiers.
---@return nil
local function createUser(sessionId, license, identifiers)
  if not identifiers.ip then
    DropPlayer(tostring(sessionId), T('drop_no_identifier'))
    return
  end

  if not identifiers.discord then
    DropPlayer(tostring(sessionId), T('drop_discord_required'))
    return
  end

  local insertId <const> = MySQL.insert.await('INSERT INTO users (license, discord_id, ip) VALUES (?, ?, ?)', { license, identifiers.discord, identifiers.ip })

  if not insertId then
    Siku.print.error(T('error_account_create_failed', identifiers.name, sessionId))
    DropPlayer(tostring(sessionId), T('drop_account_create_failed'))
    return
  end

  TriggerEvent('siku:server:createUserInstance', sessionId, {
    id = insertId,
    license = license,
    discord_id = identifiers.discord,
  })
  TriggerClientEvent('siku_multicharacter:client:prepareCharacterCreation', sessionId)
end

--- Moves a ready player into their private instance when enabled.
---@param sessionId number The player server ID.
---@return nil
local function ensurePlayerInstance(sessionId)
  if not SpawnConfig.playerInstance then
    return
  end

  if Siku.bucket.isPlayerInstanced(sessionId) then
    return
  end

  Siku.bucket.createPlayerInstance(sessionId)
end

--- Routes a ready player to account retrieval or creation.
---@return nil
local function handlePlayerReady()
  local sessionId <const> = source

  ensurePlayerInstance(sessionId)

  if Siku.cache.hasPlayer(sessionId) then
    TriggerClientEvent('siku_multicharacter:client:prepareCharacterSelect', sessionId)
    return
  end

  local identifiers <const> = Siku.GetIdentifiers(sessionId)
  local license <const> = identifiers.license

  if not license then
    Siku.print.error(T('error_no_license', identifiers.name, sessionId))
    DropPlayer(tostring(sessionId), T('drop_no_identifier'))
    return
  end

  local userId <const> = MySQL.scalar.await('SELECT id FROM users WHERE license = ?', { license })

  if userId then
    retrieveUser(sessionId, userId) -- TODO
  else
    createUser(sessionId, license, identifiers)
  end
end

RegisterNetEvent('siku_multicharacter:server:playerReady', handlePlayerReady)
