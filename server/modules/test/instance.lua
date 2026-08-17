Siku.RegisterCommand('instance', function(src)
  local moduleBucket <const> = Siku.bucket.getPlayer(src)
  local engineBucket <const> = GetPlayerRoutingBucket(tostring(src))
  local instanced <const> = Siku.bucket.isPlayerInstanced(src)

  Siku.print.info(('[instance] player %d — module bucket: %s | engine bucket: %d | instanced: %s'):format(
    src, tostring(moduleBucket), engineBucket, tostring(instanced)
  ))
  Siku.print.info(('[instance] %d bucket(s) tracked by the core'):format(Siku.bucket.getCount()))

  if moduleBucket and moduleBucket ~= 0 then
    Siku.print.info(Siku.bucket.getInfo(moduleBucket))
  end
end, {
  description = 'Prints your current routing bucket instance state',
})
