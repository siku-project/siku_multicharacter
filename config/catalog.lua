--- The photos of the catalogue: siku_studio photographs every item on
--- both freemode models and names each photo after what it shows
--- (`top_12_3.webp`: top drawable 12, texture 3), filed in one folder
--- per target with one folder per model inside (`top/male/`). When
--- `images` is on, the appearance editor shows those photos as a grid
--- instead of a slider for the targets listed below, and the textures
--- of the chosen clothing or accessory as a second grid beside the
--- panel when it has more than one; off, it keeps its sliders.
CatalogConfig = {
  --- Whether the editor shows photos at all.
  ---
  --- Default: true
  images = true,

  --- Where the photos are read from when `images` is on.
  ---
  --- 'cdn': the server lists each folder on the Siku CDN with the key
  --- below and hands the interface the link of every photo.
  --- 'files': the photos ship with the interface, under `web/dist`, in
  --- the folder named in `files.folder` with the same layout as the CDN
  --- (`web/dist/images/catalog/hair/male/hair_12_0.webp`). Put them in
  --- `web/public/images/catalog/` so the build ships them, or copy them
  --- straight into `web/dist/images/catalog/` on the server. A missing
  --- photo shows as a bare number.
  ---
  --- Default: 'cdn'
  source = 'cdn',

  cdn = {
    --- The Siku CDN the photos are read from.
    url = 'https://cdn.heliony.com',

    --- Path of the CDN folder under which siku_studio filed the catalogue
    --- (its `cdn.folder`), '' for the root of the CDN.
    folder = '',

    --- Convar holding an API key with the read permission on that folder,
    --- set in server.cfg (`set siku_multicharacter_cdn_key "cdn_…"`),
    --- never written in this file. Without a key the editor keeps its
    --- sliders.
    keyConvar = 'siku_multicharacter_cdn_key',

    --- Longest wait (ms) for the CDN to list one folder.
    timeoutMs = 10000,
  },

  files = {
    --- Folder of the photos, relative to `web/dist`.
    folder = 'images/catalog',
  },

  --- The model folders, as siku_studio names them (`catalog.folders`).
  folders = {
    mp_m_freemode_01 = 'male',
    mp_f_freemode_01 = 'female',
  },

  --- The targets shown as photos, by the name siku_studio gives them
  --- (the `name` of each target in its `catalog.targets`) with their
  --- kind, which names the photos: a component or prop photo is
  --- `top_12_3.webp` (drawable 12, texture 3; the grid shows the first
  --- texture of each drawable, the variants grid every texture of the
  --- chosen one, and the hair only its first texture since its colour
  --- comes from the swatches), an overlay photo is `beard_7.webp`
  --- (overlay value 7). The first slot of a prop stands for none.
  targets = {
    hair = 'component',
    eyebrows = 'overlay',
    beard = 'overlay',
    chest_hair = 'overlay',
    lipstick = 'overlay',
    makeup = 'overlay',
    blush = 'overlay',
    top = 'component',
    undershirt = 'component',
    arms = 'component',
    pants = 'component',
    shoes = 'component',
    mask = 'component',
    bag = 'component',
    neck = 'component',
    hat = 'prop',
    glasses = 'prop',
    earrings = 'prop',
    watch = 'prop',
    bracelet = 'prop',
  },
}
