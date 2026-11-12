--- The photos of the catalogue: siku_studio photographs every item on
--- both freemode models and names each photo after what it shows
--- (`hair_12_0.webp`: hair drawable 12, texture 0), filed in one folder
--- per target with one folder per model inside (`hair/male/`). When
--- `images` is on, the appearance editor shows those photos as a grid
--- instead of a slider for the targets listed below; off, it keeps its
--- sliders.
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
  --- (the `name` of each target in its `catalog.targets`). Only the
  --- first texture of each drawable is shown: the editor picks the shape,
  --- the colour comes from the swatches.
  targets = {
    'hair',
  },
}
