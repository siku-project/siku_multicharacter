Hud = {}

local HUD_RESOURCE <const> = 'siku_hud'

local function available()
  return GetResourceState(HUD_RESOURCE) == 'started'
end

function Hud.hide()
  if available() then
    exports[HUD_RESOURCE]:HideHud()
  end
end

function Hud.show()
  if available() then
    exports[HUD_RESOURCE]:ShowHud()
  end
end
