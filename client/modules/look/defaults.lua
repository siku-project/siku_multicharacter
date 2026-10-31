Look = Look or {}

local FEATURES <const> = {
  'noseWidth', 'noseHeight', 'noseLength', 'noseBridgeHeight', 'noseTipHeight', 'noseBridgeTwist',
  'browHeight', 'browDepth',
  'cheekboneHeight', 'cheekboneWidth', 'cheekWidth',
  'eyesOpening', 'lipThickness',
  'jawWidth', 'jawLength',
  'chinPosition', 'chinLength', 'chinWidth', 'chinHollow',
  'neckThickness',
}

local COMPONENTS <const> = {
  mask = 1, torso = 3, pants = 4, bags = 5, shoes = 6, chain = 7, tshirt = 8, armour = 9, decals = 10, arms = 11,
}

local PROPS <const> = {
  hat = 0, glasses = 1, ears = 2, watch = 6, bracelet = 7,
}

local OVERLAYS <const> = {
  blemishes = { id = 0 },
  beard = { id = 1, colorType = 1 },
  eyebrows = { id = 2, colorType = 1 },
  ageing = { id = 3 },
  makeup = { id = 4, colorType = 2 },
  blush = { id = 5, colorType = 2 },
  complexion = { id = 6 },
  sunDamage = { id = 7 },
  lipstick = { id = 8, colorType = 2 },
  moles = { id = 9 },
  chestHair = { id = 10, colorType = 1 },
  bodyBlemishes = { id = 11 },
  addBodyBlemishes = { id = 12 },
}

---@param ped number The ped handle.
---@param gender 'm'|'f'
function Look.applyDefault(ped, gender)
  local look <const> = DefaultLookConfig[gender]

  if not look then
    return
  end

  SetPedHeadBlendData(
    ped,
    look.mother, look.father, 0,
    look.mother, look.father, 0,
    (look.faceWeight or 50) / 100.0, (look.skinWeight or 50) / 100.0, 0.0, false
  )

  for index = 1, #FEATURES do
    SetPedFaceFeature(ped, index - 1, ((look.features or {})[FEATURES[index]] or 0) / 10.0)
  end

  for name, component in pairs(COMPONENTS) do
    local entry <const> = (look.components or {})[name] or { 0, 0 }

    SetPedComponentVariation(ped, component, entry[1] or 0, entry[2] or 0, 0)
  end

  local hair <const> = look.hair or {}

  SetPedComponentVariation(ped, 2, hair.style or 0, hair.texture or 0, 0)
  SetPedHairTint(ped, hair.color or 0, hair.highlight or 0)
  SetPedEyeColor(ped, look.eyeColor or 0)

  for name, prop in pairs(PROPS) do
    local entry <const> = (look.props or {})[name] or { -1, 0 }

    if (entry[1] or -1) < 0 then
      ClearPedProp(ped, prop)
    else
      SetPedPropIndex(ped, prop, entry[1], entry[2] or 0, true)
    end
  end

  for name, overlay in pairs(OVERLAYS) do
    local entry <const> = (look.overlays or {})[name] or {}

    SetPedHeadOverlay(ped, overlay.id, entry.style or 0, (entry.opacity or 0) / 10.0)

    if overlay.colorType then
      SetPedHeadOverlayColor(ped, overlay.id, overlay.colorType, entry.color or 0, entry.highlight or 0)
    end
  end
end
