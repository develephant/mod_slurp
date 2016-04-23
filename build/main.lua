--==============================================================--
--== Slurp Demo/Test
--==============================================================--
local Slurp = require('mod_slurp')

local callback = function( evt )
  print( evt.status, evt.phase )
end

local s = Slurp:new({
  callback = callback,
  debug = true,
  timeout = 5000,
  breather = 555,
  options =
  {
    headers =
    {
      ["X-My-Corona-ID"] = 'app-1234'
    }
  }
})

s:add('woopy') --< ?
s:add('ws://socket.io') --< Invalid protocol
s:add('https://www.google.com') --< This should be the only url that triggers
s:add('https://www.yahoo.com') --< Unless Google fails, this won't trigger

s:run()
