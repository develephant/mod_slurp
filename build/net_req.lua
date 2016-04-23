local mod = {}

function mod.new( url, method, callback, options )

  local s =
  {
    url = url,
    method = method,
    callback = callback,
    options = options,
    network_id = nil
  }

  function s:run()
    print('run')
    self.network_id = network.request( self.url, self.method, self.callback, self.options )
  end

  function s:stop()
    print('stop')
    network.cancel( self.network_id )
  end

  return s
end

return mod
