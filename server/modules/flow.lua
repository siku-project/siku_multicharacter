Flow = {}

local STAGE_EVENT <const> = 'siku_multicharacter:server:stage'
local SPAWNED_EVENT <const> = 'siku_multicharacter:server:spawned'
local STAGE_LOADING <const> = 'loading'
local STAGE_APPEARANCE <const> = 'appearance'
local STAGE_ENTERING <const> = 'entering'
local STAGE_PLAYING <const> = 'playing'
local CLIENT_STAGES <const> = { [STAGE_APPEARANCE] = true }

local sessions = {}

---@param sessionId number
---@return table state The flow state of the session, created on first touch.
local function stateOf(sessionId)
  local state = sessions[sessionId]

  if not state then
    state = { stage = STAGE_LOADING, since = GetGameTimer(), startedAt = GetGameTimer() }
    sessions[sessionId] = state
  end

  return state
end

---@param sessionId number
---@return string|nil stage The stage the session is in, nil when unknown.
---@return number seconds The seconds spent in that stage.
---@return number total The seconds since the session started loading.
function Flow.get(sessionId)
  local state <const> = sessions[sessionId]

  if not state then
    return nil, 0, 0
  end

  local now <const> = GetGameTimer()

  return state.stage, math.floor((now - state.since) / 1000), math.floor((now - state.startedAt) / 1000)
end

---@param sessionId number
---@param stage string The stage the session enters.
---@return string|nil previous The stage it leaves.
---@return number seconds The seconds spent in the previous stage.
function Flow.enter(sessionId, stage)
  local state <const> = stateOf(sessionId)
  local previous <const> = state.stage
  local seconds <const> = math.floor((GetGameTimer() - state.since) / 1000)

  state.stage = stage
  state.since = GetGameTimer()

  return previous, seconds
end

---@param sessionId number
---@param userId number
---@param name string
function Flow.identify(sessionId, userId, name)
  local state <const> = stateOf(sessionId)

  state.userId = userId
  state.name = name
end

---@param sessionId number
---@param characterId number
---@param created boolean Whether the character was just created.
function Flow.chose(sessionId, characterId, created)
  local state <const> = stateOf(sessionId)

  state.characterId = characterId
  state.created = created
end

---@param sessionId number
---@return table entities The player, and the user when known, for an event about this session.
function Flow.entities(sessionId)
  local state <const> = sessions[sessionId]
  local entities <const> = { { type = 'player', id = sessionId, role = 'actor', label = state and state.name or nil } }

  if state and state.userId then
    entities[#entities + 1] = { type = 'user', id = state.userId, role = 'actor', label = state.name, session = sessionId }
  end

  return entities
end

AddEventHandler('playerJoining', function()
  stateOf(source)
end)

RegisterNetEvent(STAGE_EVENT, function(stage)
  local sessionId <const> = source

  if not CLIENT_STAGES[stage] or not sessions[sessionId] then
    return
  end

  local previous <const>, seconds <const> = Flow.enter(sessionId, stage)

  Siku.log.debug('multicharacter.stage', ('%s: %s after %ds in %s'):format(sessions[sessionId].name or sessionId, stage, seconds, tostring(previous)), {
    stage = stage,
    previous = previous,
    seconds = seconds,
  }, { source = sessionId, entities = Flow.entities(sessionId) })
end)

RegisterNetEvent(SPAWNED_EVENT, function()
  local sessionId <const> = source
  local state <const> = sessions[sessionId]

  if not state or state.stage ~= STAGE_ENTERING then
    return
  end

  local previous <const>, seconds <const> = Flow.enter(sessionId, STAGE_PLAYING)
  local _, _, total <const> = Flow.get(sessionId)

  Siku.log.info('multicharacter.spawned', ('%s spawned%s after %ds, %ds since loading'):format(state.name or sessionId, state.created and ' with a new character' or '', seconds, total), {
    characterId = state.characterId,
    created = state.created == true,
    enteringSeconds = seconds,
    totalSeconds = total,
    previous = previous,
  }, { source = sessionId, entities = Flow.entities(sessionId) })
end)

AddEventHandler('playerDropped', function(reason, resourceName, dropReason)
  local sessionId <const> = source
  local state <const> = sessions[sessionId]

  if not state then
    return
  end

  local stage <const>, seconds <const>, total <const> = Flow.get(sessionId)

  sessions[sessionId] = nil

  if stage == STAGE_PLAYING then
    return
  end

  Siku.log.warn('multicharacter.abandoned', ('%s left during %s after %ds: %s'):format(state.name or sessionId, tostring(stage), seconds, tostring(reason)), {
    stage = stage,
    stageSeconds = seconds,
    totalSeconds = total,
    characterId = state.characterId,
    created = state.created == true,
    reason = tostring(reason),
    dropCode = tonumber(dropReason),
    byResource = type(resourceName) == 'string' and not resourceName:match('^__cfx_internal:') and resourceName or nil,
  }, { outcome = 'failure', source = sessionId, entities = Flow.entities(sessionId) })
end)
