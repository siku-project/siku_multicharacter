SpawnConfig = {
  --- Maximum number of characters a player can own.
  ---
  --- Drives the number of slots shown on the selection screen; a player
  --- with every slot used must delete a character (when allowed) before
  --- creating a new one.
  ---
  --- Default: 2
  characterSlots = 2,

  --- Whether players can delete their own characters from the
  --- selection screen.
  ---
  --- Deletion is permanent: the character and everything attached to it
  --- are removed. Keep it disabled to route deletions through the staff.
  ---
  --- Default: false
  playerCanDeleteCharacter = false,

  --- Where the player ped is staged while the selection and creation
  --- screens are open (x, y, z, heading).
  ---
  --- The spot is only a backdrop for the character scene.
  characterSelectionSpawn = vector4(925.45, 11.70, 112.55, 301.35),

  --- Whether each player goes through selection and creation inside a
  --- private routing bucket.
  ---
  --- Isolated, players staged at the same spot never see each other;
  --- the bucket is released when the character enters the world.
  ---
  --- Default: true
  playerInstance = true,

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
  spawnPosition = vector4(-3043.11, 26.90, 10.10, 325.98)
}
