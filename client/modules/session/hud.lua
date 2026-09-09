local HUD_RESOURCE <const> = 'siku_hud'
local STARTED <const> = 'started'

--- Whether the HUD resource is around to be asked.
---@return boolean available Whether siku_hud is started.
local function isHudAvailable()
  return GetResourceState(HUD_RESOURCE) == STARTED
end

--- Hides the HUD and the minimap for the duration of a screen.
---@return nil
function HideGameInterface()
  if isHudAvailable() then
    exports[HUD_RESOURCE]:HideHud()
  end
end

--- Brings the HUD and the minimap back once the character is in the world.
---@return nil
function ShowGameInterface()
  if isHudAvailable() then
    exports[HUD_RESOURCE]:ShowHud()
  end
end
