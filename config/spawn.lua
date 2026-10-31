SpawnConfig = {
  --- Where the player ped is staged while the selection and creation
  --- screens are open (x, y, z, heading).
  ---
  --- The spot is only a backdrop for the character scene.
  staging = vector4(925.45, 11.70, 112.55, 301.35),

  --- Whether each player goes through selection and creation inside a
  --- private routing bucket.
  ---
  --- Isolated, players staged at the same spot never see each other;
  --- the bucket is released when the character enters the world.
  ---
  --- Default: true
  privateInstance = true,

  --- Whether a freshly created character is handed to siku_intro for the
  --- cinematic introduction instead of spawning directly. Only applies
  --- when the siku_intro resource is started; selection of an existing
  --- character always spawns normally.
  ---
  --- Default: true
  introOnCreation = true,

  --- Where a freshly created character enters the world for the first
  --- time (x, y, z, heading).
  ---
  --- Only used when the character has no saved position yet; afterwards
  --- everyone respawns where they last played.
  firstSpawn = vector4(-3043.11, 26.90, 10.10, 325.98),
}
