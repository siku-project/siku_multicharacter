local OPEN_EVENT <const> = 'siku_multicharacter:client:open'

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
  local previous <const>, seconds <const> = Flow.enter(sessionId, 'account')

  Siku.log.debug('multicharacter.stage', ('%s: account after %ds in %s'):format(GetPlayerName(tostring(sessionId)) or sessionId, seconds, tostring(previous)), {
    stage = 'account',
    previous = previous,
    seconds = seconds,
  }, { source = sessionId, entities = Flow.entities(sessionId) })

  isolate(sessionId)

  if Siku.cache.hasPlayer(sessionId) then
    local cached <const> = Siku.cache.getPlayer(sessionId)

    Flow.identify(sessionId, cached.id, cached.name)
    Flow.enter(sessionId, 'selection')

    Siku.log.debug('multicharacter.stage', ('%s: selection, account already cached'):format(cached.name), {
      stage = 'selection',
      previous = 'account',
      seconds = 0,
    }, { source = sessionId, entities = Flow.entities(sessionId) })

    TriggerClientEvent(OPEN_EVENT, sessionId, 'selection')
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

  local screen <const> = fresh and 'creation' or 'selection'
  local stage <const> = fresh and 'identity' or 'selection'
  local accountSeconds <const> = select(2, Flow.enter(sessionId, stage))

  Flow.identify(sessionId, user.id, identifiers.name)

  Siku.log.debug('multicharacter.stage', ('%s: %s after %ds in account%s'):format(identifiers.name, stage, accountSeconds, fresh and ', new account' or ''), {
    stage = stage,
    previous = 'account',
    seconds = accountSeconds,
    newAccount = fresh,
  }, { source = sessionId, entities = Flow.entities(sessionId) })

  TriggerClientEvent(OPEN_EVENT, sessionId, screen)
end)
