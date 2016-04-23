local Slurp = require('mod_slurp')

local urls = { 'http://www.gel23oes.com', 'https://www.google.com' }

local function networkCallback( evt )
  print( evt.status )
  print( evt.phase )
  print( evt.response )
end

local s = Slurp:new( urls, networkCallback )
s:request()
