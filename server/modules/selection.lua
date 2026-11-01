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

---@param characterId number
---@return table jobs The memberships of the character, as the audit records them.
local function jobsOf(characterId)
  local memberships <const> = Siku.jobs.getMemberships(characterId)
  local jobs <const> = {}

  for i = 1, #memberships do
    local membership <const> = memberships[i]

    jobs[i] = { job = membership.job, label = membership.label, grade = membership.grade, gradeLabel = membership.gradeLabel, rank = membership.rank }
  end

  return jobs
end

---@param characterId number
---@return table accounts The accounts the character can use, as the audit records them.
local function accountsOf(characterId)
  local views <const> = Siku.accounts.getAccessible(characterId)
  local accounts <const> = {}

  for i = 1, #views do
    local view <const> = views[i]

    accounts[i] = { id = view.id, ownerType = view.ownerType, ownerId = view.ownerId, balance = view.balance, state = view.state }
  end

  return accounts
end

---@param characterId number
---@return table licenses The licenses the character holds, as the audit records them.
local function licensesOf(characterId)
  local holdings <const> = Siku.licenses.getHoldings(characterId)
  local licenses <const> = {}

  for i = 1, #holdings do
    local holding <const> = holdings[i]

    licenses[i] = { license = holding.license, state = holding.state, points = holding.points, maxPoints = holding.maxPoints, expiresAt = holding.expiresAt }
  end

  return licenses
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
    Flow.enter(sessionId, 'selection')

    Siku.log.debug('multicharacter.stage', ('%s: selection, character %d is not theirs'):format(user.name, characterId), {
      stage = 'selection',
      previous = 'selection',
      seconds = 0,
      characterId = characterId,
    }, { source = sessionId, entities = Flow.entities(sessionId) })

    TriggerClientEvent(OPEN_EVENT, sessionId, 'selection')
    return
  end

  local previous <const>, seconds <const> = Flow.enter(sessionId, 'entering')

  Flow.chose(sessionId, row.id, false)
  Characters.prepareEntry(row)
  Characters.enter(sessionId, row, false)

  Siku.log.audit('multicharacter.character_selected', {
    message = ('%s chose %s %s'):format(user.name, row.first_name, row.last_name),
    source = sessionId,
    entities = { { type = 'player', id = sessionId, role = 'actor' } },
    data = {
      character = {
        id = row.id,
        firstName = row.first_name,
        lastName = row.last_name,
        dob = row.dob,
        gender = row.gender,
        nationality = row.nationality,
        birthplace = row.birthplace,
        pedModel = row.ped_model,
        playtimeMinutes = math.floor((row.playtime or 0) / 60),
        lastPlayed = row.last_played,
        createdAt = row.created_at,
        dead = Characters.isDead(row),
        position = { x = row.x, y = row.y, z = row.z },
      },
      jobs = jobsOf(row.id),
      accounts = accountsOf(row.id),
      licenses = licensesOf(row.id),
      selectionSeconds = seconds,
      previous = previous,
    },
  })
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

  local deleted <const> = CharactersConfig.allowDeletion and Characters.delete(user.id, characterId)

  if deleted then
    Siku.cache.removeCharacter(sessionId, characterId)

    Siku.log.audit('multicharacter.character_deleted', {
      message = ('%s deleted character %d'):format(user.name, characterId),
      source = sessionId,
      entities = { { type = 'character', id = characterId, role = 'target' }, { type = 'player', id = sessionId, role = 'actor' } },
      data = { characterId = characterId, remaining = Characters.count(user.id) },
    })
  end

  local screen <const> = Characters.count(user.id) > 0 and 'selection' or 'creation'
  local stage <const> = screen == 'selection' and 'selection' or 'identity'

  Flow.enter(sessionId, stage)

  Siku.log.debug('multicharacter.stage', ('%s: %s after deleting character %d'):format(user.name, stage, characterId), {
    stage = stage,
    previous = 'selection',
    seconds = 0,
    deleted = deleted == true,
  }, { source = sessionId, entities = Flow.entities(sessionId) })

  TriggerClientEvent(OPEN_EVENT, sessionId, screen)
end)
