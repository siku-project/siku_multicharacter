local TIMESTAMP_PATTERN <const> = '(%d+)-(%d+)-(%d+)[T ](%d+):(%d+):(%d+)'

--- Converts a database timestamp into epoch milliseconds, the format the
--- interface reads.
---@param timestamp string|nil The database timestamp.
---@return number|nil epoch The timestamp in milliseconds, or nil.
local function toEpochMs(timestamp)
  if type(timestamp) ~= 'string' then
    return nil
  end

  local year <const>, month <const>, day <const>, hour <const>, minute <const>, second <const> =
    timestamp:match(TIMESTAMP_PATTERN)

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

--- Formats a character row into the payload the selection screen reads.
---@param row table The character row from the database.
---@param slot number The slot the character occupies on screen.
---@return table character The formatted character.
local function formatCharacter(row, slot)
  return {
    id = row.id,
    slot = slot,
    identity = {
      firstName = row.first_name,
      lastName = row.last_name,
      birthDate = type(row.dob) == 'string' and row.dob:sub(1, 10) or nil,
      height = row.height,
    },
    finances = {
      cash = 0,
      bank = 0,
    },
    playtime = math.floor((row.playtime or 0) / 60),
    lastPlayed = toEpochMs(row.last_played),
    createdAt = toEpochMs(row.created_at),
    pedModel = row.ped_model,
  }
end

Siku.registerCallback('siku_multicharacter:callback:getCharacters', function(sessionId)
  local user <const> = Siku.cache.getPlayer(sessionId)

  if not user then
    Siku.print.error(T('error_no_user_for_character', sessionId))
    return { characters = {}, config = {} }
  end

  local rows <const> = MySQL.query.await(
    'SELECT * FROM characters WHERE user_id = ? ORDER BY created_at ASC',
    { user.id }
  )

  local total <const> = rows and #rows or 0
  local slots <const> = SpawnConfig.characterSlots

  if total > slots then
    Siku.print.warn(T('warn_characters_over_slots', total, user.id, slots))
  end

  local characters <const> = {}

  for i = 1, math.min(total, slots) do
    characters[i] = formatCharacter(rows[i], i)
  end

  Siku.print.debug(('Returning %d character(s) for user %d (session %d)'):format(#characters, user.id, sessionId))

  return {
    characters = characters,
    config = {
      slots = SpawnConfig.characterSlots,
      allowCharacterDeletion = SpawnConfig.playerCanDeleteCharacter,
      showDirtyMoney = false,
    },
  }
end)
