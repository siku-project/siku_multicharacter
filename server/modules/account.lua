local OPEN_EVENT <const> = 'siku_multicharacter:client:open'

---@param sessionId number
---@param screen 'selection'|'creation'
local function open(sessionId, screen)
  TriggerClientEvent(OPEN_EVENT, sessionId, screen)
end

---@param sessionId number
local function isolate(sessionId)
  if SpawnConfig.privateInstance and not Siku.bucket.isPlayerInstanced(sessionId) then
    Siku.bucket.createPlayerInstance(sessionId)
  end
end

---@param sessionId number
---@param identifiers table The player identifiers from the core.
---@return table|nil user The created account row, or nil once the player was dropped.
local function createUser(sessionId, identifiers)
  if not identifiers.ip then
    DropPlayer(tostring(sessionId), T('drop_no_identifier'))
    return nil
  end

  if not identifiers.discord then
    DropPlayer(tostring(sessionId), T('drop_discord_required'))
    return nil
  end

  local userId <const> = MySQL.insert.await(
    'INSERT INTO users (license, discord_id, ip) VALUES (?, ?, ?)',
    { identifiers.license, identifiers.discord, identifiers.ip }
  )

  if not userId then
    DropPlayer(tostring(sessionId), T('drop_account_create_failed'))
    return nil
  end

  return MySQL.single.await('SELECT * FROM users WHERE id = ?', { userId })
end

RegisterNetEvent('siku_multicharacter:server:playerReady', function()
  local sessionId <const> = source

  isolate(sessionId)

  if Siku.cache.hasPlayer(sessionId) then
    open(sessionId, 'selection')
    return
  end

  local identifiers <const> = Siku.player.getIdentifiers(sessionId)

  if not identifiers.license then
    DropPlayer(tostring(sessionId), T('drop_no_identifier'))
    return
  end

  local user = MySQL.single.await('SELECT * FROM users WHERE license = ?', { identifiers.license })
  local fresh <const> = user == nil

  if fresh then
    user = createUser(sessionId, identifiers)

    if not user then
      return
    end
  end

  TriggerEvent('siku:server:createUserInstance', sessionId, user)

  if not Siku.cache.hasPlayer(sessionId) then
    return
  end

  open(sessionId, fresh and 'creation' or 'selection')
end)
