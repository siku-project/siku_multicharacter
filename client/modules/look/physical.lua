Look = Look or {}

local OVERLAYS <const> = {
  { id = 0, key = 'blemishes' },
  { id = 1, key = 'beard', colorType = 1 },
  { id = 2, key = 'eyebrows', colorType = 1 },
  { id = 3, key = 'ageing' },
  { id = 4, key = 'makeup', colorType = 2 },
  { id = 5, key = 'blush', colorType = 2 },
  { id = 7, key = 'sunDamage' },
  { id = 8, key = 'lipstick', colorType = 2 },
  { id = 9, key = 'moles' },
  { id = 10, key = 'chestHair', colorType = 1 },
}

local FEATURES <const> = {
  [0] = 'noseWidth', [1] = 'noseHeight', [2] = 'noseLength',
  [3] = 'noseBridgeHeight', [4] = 'noseTipHeight', [5] = 'noseBridgeTwist',
  [6] = 'browHeight', [7] = 'browDepth',
  [8] = 'cheekboneHeight', [9] = 'cheekboneWidth', [10] = 'cheekWidth',
  [11] = 'eyesOpening', [12] = 'lipThickness',
  [13] = 'jawWidth', [14] = 'jawLength',
  [15] = 'chinPosition', [16] = 'chinLength', [17] = 'chinWidth', [18] = 'chinHollow',
  [19] = 'neckThickness',
}

---@param ped number The ped handle.
---@param limits table Filled with what this server streams for each style.
---@return table limits
function Look.physicalLimits(ped, limits)
  limits.hairStyles = GetNumberOfPedDrawableVariations(ped, 2)
  limits.eyebrows = GetNumHeadOverlayValues(2)
  limits.beard = GetNumHeadOverlayValues(1)
  limits.chestHair = GetNumHeadOverlayValues(10)
  limits.ageing = GetNumHeadOverlayValues(3)
  limits.lipstick = GetNumHeadOverlayValues(8)
  limits.makeup = GetNumHeadOverlayValues(4)
  limits.blush = GetNumHeadOverlayValues(5)
  limits.sunDamage = GetNumHeadOverlayValues(7)
  limits.moles = GetNumHeadOverlayValues(9)
  limits.blemishes = GetNumHeadOverlayValues(0)

  return limits
end

---@param ped number The ped handle.
---@param data table|nil The physical payload { hair, eyeColor, overlays, features }.
function Look.applyPhysical(ped, data)
  if type(data) ~= 'table' then
    return
  end

  local hair <const> = data.hair or {}

  SetPedComponentVariation(ped, 2, (hair.style or 1) - 1, 0, 0)
  SetPedHairTint(ped, hair.color or 0, hair.highlight or 0)
  SetPedEyeColor(ped, data.eyeColor or 0)

  local overlays <const> = data.overlays or {}

  for i = 1, #OVERLAYS do
    local overlay <const> = OVERLAYS[i]
    local entry <const> = overlays[overlay.key]

    if entry then
      SetPedHeadOverlay(ped, overlay.id, (entry.style or 1) - 1, (entry.opacity or 0.5) + 0.0)

      if overlay.colorType then
        SetPedHeadOverlayColor(ped, overlay.id, overlay.colorType, entry.color or 0, entry.secondary or 0)
      end
    end
  end

  local features <const> = data.features or {}

  for index, key in pairs(FEATURES) do
    SetPedFaceFeature(ped, index, (features[key] or 0) + 0.0)
  end
end

Nui.on('physicalChanged', function(data)
  Look.applyPhysical(PlayerPedId(), data)
end)
