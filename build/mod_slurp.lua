--==============================================================--
--== Slurp Module for Corona SDK
--== (c)2016 Chris Byerley chris@coronalabs.com
--==============================================================--
local network = require('network')
local timer = require('timer')

local Slurp = {}

function Slurp.new( urls, callback, options )
  local urls = urls or nil
  local callback = callback or nil
  local options = options or {}

  --==============================================================--
  --== Slurp Instance Factory
  --==============================================================--
  local s =
  {
    callback = callback,
    method = "GET",
    network_id = nil,
    options = options,
    timer_id = nil,
    timeout = 5000,
    url_q = urls
  }

  function s:add( url )
    if url then
      table.insert( self.url_q, url )
    end
  end

  function s:run()
    --Check queue count
    local url_cnt = self:count()
    if url_cnt > 0 then
      --Get URL or URLObject
      local url = table.remove( self.url_q, 1 )
      --Defaults
      local callback = self.callback
      local options = self.options
      local timeout = self.timeout
      local method = self.method
      --check for URLObject
      if type( url ) == 'table' then
        --parse table
        callback = url.callback or self.callback or nil
        options = url.options or self.options or {}
        timeout = url.timeout or self.timeout or 5000
        method = url.method or self.method or "GET"
        url = url.url or url or nil
      end

      --Set up network listener
      local networkListener
      networkListener = function( evt )
        if evt.isError then
          self:stop()
          self:run()
        else
          print( evt.phase )
          if evt.phase == 'ended' then
            self:stop()
            --Send to callback with network event
            self.callback( evt )
          end
        end
      end

      --Make network request
      self:_start()
      self.network_id = network.request( url, self.method, networkListener, options )
    end
  end

  function s:stop()

    if self.timer_id then
      timer.cancel( self.timer_id )
      self.timer_id = nil
    end

    if self.network_id then
      network.cancel( self.network_id )
      self.network_id = nil
    end

    s:_done()
  end

  function s:count()
    return #self.url_q
  end

  function s:flush()
    s:stop()
    self.url_q = {}
    self.callback = nil
    self.method = 'GET'
  end

  --==============================================================--
  --== Privates
  --==============================================================--
  function s:_start()
    local onTimeout = function()
      self:_timedout()
    end
    self.timer_id = timer.performWithDelay( self.timeout, onTimeout )
  end

  function s:_timedout()
    --check for more
    if s:count() > 0 then
      s:run()
    else
      s:stop()
    end
  end

  function s:_done()
    print( 'Done' )
  end

  return s
end

--==============================================================--
--== URLObject Factory
--==============================================================--
function Slurp.newURLObject( url, callback, options )
  return { url = url, callback = callback, options = options }
end


return Slurp
