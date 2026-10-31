Pose = {}

local ANIM_DICT <const> = 'missminuteman_1ig_2'
local ANIM_NAME <const> = 'handsup_base'
local ANIM_FLAGS <const> = 50
local BLEND_SPEED <const> = 8.0

local handsUp = false

local function raise()
  local ped <const> = PlayerPedId()

  Siku.streaming.requestAnimDict(ANIM_DICT)
  SetPlayerControl(PlayerId(), true, 0)
  TaskPlayAnim(ped, ANIM_DICT, ANIM_NAME, BLEND_SPEED, BLEND_SPEED, -1, ANIM_FLAGS, 0.0, false, false, false)
  RemoveAnimDict(ANIM_DICT)

  handsUp = true
end

local function lower()
  StopAnimTask(PlayerPedId(), ANIM_DICT, ANIM_NAME, BLEND_SPEED)
  SetPlayerControl(PlayerId(), false, 0)

  handsUp = false
end

function Pose.reset()
  if handsUp then
    lower()
  end
end

Nui.on('toggleHandsUp', function()
  if handsUp then
    lower()
  else
    raise()
  end
end)
