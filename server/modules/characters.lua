Characters = {}

local TIMESTAMP_PATTERN <const> = '(%d+)-(%d+)-(%d+)[T ](%d+):(%d+):(%d+)'
local DATE_PATTERN <const> = '^(%d%d%d%d)-(%d%d)-(%d%d)$'
local CLIENT_SPAWN_EVENT <const> = 'siku_multicharacter:client:spawn'

---@param value number|string|nil A DATE or TIMESTAMP value as oxmysql hands it over.
---@return number|nil epoch Milliseconds since the epoch, or nil.
local function toEpochMs(value)
  if type(value) == 'number' then
    return math.floor(value)
  end

  if type(value) ~= 'string' then
    return nil
  end

  local year <const>, month <const>, day <const>, hour <const>, minute <const>, second <const> =
    value:match(TIMESTAMP_PATTERN)

  if not year then
    return nil
  end

  return os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = tonumber(hour),
    min = tonumber(minute),
    sec = tonumber(second),
  }) * 1000
end

---@param value number|string|nil A DATE value as oxmysql hands it over.
---@return string|nil date The date as YYYY-MM-DD, or nil.
local function toDateString(value)
  if type(value) == 'string' then
    local date <const> = value:match('^(%d%d%d%d%-%d%d%-%d%d)')

    if date then
      return date
    end
  end

  local epoch <const> = toEpochMs(value)

  return epoch and os.date('!%Y-%m-%d', epoch // 1000) or nil
end

---@param characterId number
---@return table|nil occupation The active job of the character, as the interface shows it.
local function occupationOf(characterId)
  local memberships <const> = Siku.jobs.getMemberships(characterId)

  for i = 1, #memberships do
    local membership <const> = memberships[i]

    if membership.active then
      return { name = membership.label, grade = membership.gradeLabel }
    end
  end

  return nil
end

---@param userId number
---@return table rows The characters of the account, oldest first.
function Characters.fetch(userId)
  return MySQL.query.await('SELECT * FROM characters WHERE user_id = ? ORDER BY created_at ASC', { userId }) or {}
end

---@param userId number
---@param characterId number
---@return table|nil row The character when the account owns it.
function Characters.find(userId, characterId)
  return MySQL.single.await('SELECT * FROM characters WHERE id = ? AND user_id = ?', { characterId, userId })
end

---@param userId number
---@return number count
function Characters.count(userId)
  return MySQL.scalar.await('SELECT COUNT(*) FROM characters WHERE user_id = ?', { userId }) or 0
end

---@param encoded string|nil The appearance column.
---@return table|nil appearance The decoded appearance, or nil when absent or unreadable.
function Characters.decodeAppearance(encoded)
  if type(encoded) ~= 'string' or encoded == '' then
    return nil
  end

  local ok <const>, decoded = pcall(json.decode, encoded)

  return ok and type(decoded) == 'table' and decoded or nil
end

---@param row table
---@return boolean dead
function Characters.isDead(row)
  return row.is_dead == true or row.is_dead == 1
end

---@param row table The character row.
---@param slot number The slot the character occupies on screen.
---@return table summary What the selection screen shows for the character.
function Characters.summarize(row, slot)
  return {
    id = row.id,
    slot = slot,
    identity = {
      firstName = row.first_name,
      lastName = row.last_name,
      birthDate = toDateString(row.dob),
      height = row.height,
    },
    occupation = occupationOf(row.id),
    playtime = math.floor((row.playtime or 0) / 60),
    lastPlayed = toEpochMs(row.last_played),
    createdAt = toEpochMs(row.created_at) or 0,
    pedModel = row.ped_model,
  }
end

---@param row table The character row.
---@return table look What the staged ped wears for the character.
function Characters.look(row)
  return { model = row.ped_model, appearance = Characters.decodeAppearance(row.appearance) }
end

---@param identity table A validated identity.
---@return boolean valid
function Characters.isValidIdentity(identity)
  if type(identity) ~= 'table' then
    return false
  end

  local year <const>, month <const>, day <const> = tostring(identity.birthDate):match(DATE_PATTERN)

  if not year then
    return false
  end

  local birth <const> = os.time({ year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = 12 })
  local now <const> = os.date('*t')
  local age <const> = now.year - tonumber(year)
    - ((now.month < tonumber(month) or (now.month == tonumber(month) and now.day < tonumber(day))) and 1 or 0)
  local height <const> = tonumber(identity.height)

  return os.date('%Y-%m-%d', birth) == identity.birthDate
    and age >= CharactersConfig.minAge and age <= CharactersConfig.maxAge
    and type(identity.firstName) == 'string' and #identity.firstName > 0 and #identity.firstName <= 50
    and type(identity.lastName) == 'string' and #identity.lastName > 0 and #identity.lastName <= 50
    and (identity.gender == 'male' or identity.gender == 'female')
    and type(identity.nationality) == 'string' and #identity.nationality == 2
    and type(identity.birthPlace) == 'string' and #identity.birthPlace <= 100
    and height ~= nil and height >= CharactersConfig.minHeight and height <= CharactersConfig.maxHeight
end

---@param userId number
---@param identity table A validated identity.
---@param pedModel string
---@param appearance table|nil
---@return number|nil characterId
function Characters.insert(userId, identity, pedModel, appearance)
  local spawn <const> = SpawnConfig.firstSpawn

  return MySQL.insert.await(
    'INSERT INTO characters (user_id, first_name, last_name, dob, gender, height, nationality, birthplace, ped_model, appearance, x, y, z, heading) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    {
      userId,
      identity.firstName,
      identity.lastName,
      identity.birthDate,
      identity.gender,
      math.floor(tonumber(identity.height)),
      identity.nationality:upper(),
      identity.birthPlace,
      pedModel,
      json.encode(appearance or {}),
      spawn.x, spawn.y, spawn.z, spawn.w,
    }
  )
end

---@param userId number
---@param characterId number
---@return boolean deleted Whether a character owned by the account was removed.
function Characters.delete(userId, characterId)
  local deleted <const> = MySQL.update.await('DELETE FROM characters WHERE id = ? AND user_id = ?', { characterId, userId })

  if (deleted or 0) == 0 then
    return false
  end

  MySQL.update.await(
    'UPDATE users SET last_played_character = NULL WHERE id = ? AND last_played_character = ?',
    { userId, characterId }
  )

  return true
end

---@param row table The character row, updated in place.
---@return nil
function Characters.prepareEntry(row)
  MySQL.update.await('UPDATE characters SET last_played = CURRENT_TIMESTAMP WHERE id = ?', { row.id })

  if Characters.isDead(row) and not CharactersConfig.deathPersistence then
    MySQL.update.await('UPDATE characters SET is_dead = 0 WHERE id = ?', { row.id })
    row.is_dead = 0
  end
end

---@param sessionId number
---@param row table The character row.
---@param handover boolean Whether the introduction takes over after the spawn.
---@return nil
function Characters.enter(sessionId, row, handover)
  if Siku.cache.getCurrentCharacterId(sessionId) then
    Siku.persistence.savePlayer(sessionId)
  end

  Siku.cache.removeCharacter(sessionId, row.id)

  TriggerEvent('siku:server:createCharacterInstance', sessionId, row)

  if SpawnConfig.privateInstance and not handover then
    Siku.bucket.releasePlayerInstance(sessionId)
  end

  TriggerClientEvent(CLIENT_SPAWN_EVENT, sessionId, {
    position = { x = row.x, y = row.y, z = row.z, heading = row.heading },
    model = row.ped_model,
    appearance = Characters.decodeAppearance(row.appearance),
    dead = Characters.isDead(row),
    handover = handover,
  })
end
