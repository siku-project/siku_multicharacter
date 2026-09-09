local ANIM_DICT <const> = 'missminuteman_1ig_2'
local ANIM_NAME <const> = 'handsup_base'
local ANIM_FLAGS <const> = 50
local BLEND_SPEED <const> = 8.0
local LOOP_FOREVER <const> = -1

local handsUp = false

--- Raises the arms of the staged character. Player control comes back on
--- for the duration, because the game refuses scripted tasks on a ped
--- whose player has none; the ped stays frozen behind a focused interface,
--- so nothing else can move.
---@return nil
local function raiseHands()
  local ped <const> = PlayerPedId()

  Siku.streaming.requestAnimDict(ANIM_DICT)
  SetPlayerControl(PlayerId(), true, 0)
  TaskPlayAnim(ped, ANIM_DICT, ANIM_NAME, BLEND_SPEED, BLEND_SPEED, LOOP_FOREVER, ANIM_FLAGS, 0.0, false, false, false)
  RemoveAnimDict(ANIM_DICT)

  handsUp = true
end

--- Lowers the arms and takes player control away again, as the staging
--- left it.
---@return nil
local function lowerHands()
  StopAnimTask(PlayerPedId(), ANIM_DICT, ANIM_NAME, BLEND_SPEED)
  SetPlayerControl(PlayerId(), false, 0)

  handsUp = false
end

--- Forgets the pose when the character is restaged or leaves the creation,
--- so neither the animation nor the control state leaks past this screen.
---@return nil
function ResetCreationPose()
  if handsUp then
    lowerHands()
  end
end

RegisterNUICallback('siku_multicharacter:nui:toggleHandsUp', function(_, cb)
  cb({})

  CreateThread(function()
    if handsUp then
      lowerHands()
    else
      raiseHands()
    end
  end)
end)
