--- The look a freemode ped wears before the player touches anything: on
--- the selection scene for an empty slot, and as the starting point of the
--- appearance editor. One entry per freemode gender.
---
--- Head blend ids follow config/heritage.lua; weights are percentages;
--- face features run from -10 to 10; overlay opacities from 0 to 10;
--- a prop drawable of -1 means none.
DefaultLookConfig = {
  m = {
    mother = 21,
    father = 0,
    faceWeight = 50,
    skinWeight = 50,

    features = {},

    hair = { style = 0, texture = 0, color = 0, highlight = 0 },
    eyeColor = 0,

    components = {
      mask = { 0, 0 },
      torso = { 0, 0 },
      pants = { 0, 0 },
      bags = { 0, 0 },
      shoes = { 1, 0 },
      chain = { 0, 0 },
      tshirt = { 15, 0 },
      armour = { 0, 0 },
      decals = { 0, 0 },
      arms = { 0, 0 },
    },

    props = {
      hat = { -1, 0 },
      glasses = { -1, 0 },
      ears = { -1, 0 },
      watch = { -1, 0 },
      bracelet = { -1, 0 },
    },

    overlays = {},
  },

  f = {
    mother = 21,
    father = 0,
    faceWeight = 50,
    skinWeight = 50,

    features = {},

    hair = { style = 4, texture = 0, color = 1, highlight = 0 },
    eyeColor = 0,

    components = {
      mask = { 0, 0 },
      torso = { 15, 0 },
      pants = { 14, 0 },
      bags = { 0, 0 },
      shoes = { 5, 0 },
      chain = { 0, 0 },
      tshirt = { 14, 0 },
      armour = { 0, 0 },
      decals = { 0, 0 },
      arms = { 15, 0 },
    },

    props = {
      hat = { -1, 0 },
      glasses = { -1, 0 },
      ears = { -1, 0 },
      watch = { -1, 0 },
      bracelet = { -1, 0 },
    },

    overlays = {
      eyebrows = { style = 1, opacity = 10 },
    },
  },
}
