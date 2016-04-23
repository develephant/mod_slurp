--==============================================================--
--== mod_slurp - url checker. downloader
--== (c)2016 Chris Byerley - chris@coronalabs.com
--== Version 0.0.1
--==============================================================--

--==============================================================--
--== Preflight
--==============================================================--
local Slurp =
{
  callback = nil,
  method = 'GET',
  network_id = nil,
  options = {},
  timeout = 5000,
  timer_id = 0,
  url_q = {}
}

--==============================================================--
--== Publics
--==============================================================--
function Slurp:new( url_q, callback, options_tbl )
  --validate url queue
  self.url_q = url_q or {}
  --validate callback
  self.callback = callback or nil
  --validate options tbl
  local options_tbl = options_tbl or {}

  --method
  if options_tbl.method then
    seld.method = options_tbl.method
  end

  --timeout options
  if options_tbl.timeout then
    self.timeout = options_tbl.timeout
  end
end

function Slurp:run()
  self:_runner()
end

function Slurp:stop()
  self:_timeout_stop()
  self:_network_cancel()
  self:_done()
end

--==============================================================--
--== Privates
--==============================================================--
function Slurp:_runner()
  print('runner')

  --get req url, if any
  if self:_is_list_empty() == false then
    local url = self:_parse_url_entry( self:_get_next_url() )

    self:_timeout_start()
    self:_network_request( url )

  else --all done
    self:stop()
  end
end

function Slurp:_parse_url_entry( url_obj )
  --validate
  local url_obj = url_obj or ""
  --check for url object
  if type( url_obj ) == 'table' then
    --validate
    local url = url_obj.url or nil
    --check for custom options
    if url_obj.options then
      self.options = url_obj.options
    end
    --check for custom callback
    if url_obj.callback then
      self.callback = url_obj.callback
    end
    --check for custom method
    if url_obj.method then
      self.method = url_obj.method
    end

    return url
  end
  --just a string
  return tostring( url_obj )
end

function Slurp:_is_list_empty()
  if #self.url_q > 0 then
    return false
  end
  return true
end

function Slurp:_get_next_url()
  if self:_is_list_empty() == false then
    return table.remove( self.url_q, 1 )
  end
  return nil
end

function Slurp:_timeout_start()
  local function onTimeout()
    self:_timeout_done()
  end
  self.timer_id = timer.performWithDelay( self.timeout, onTimeout )
end

function Slurp:_timeout_stop()
  timer.cancel( self.timer_id )
end

function Slurp:_timeout_done()
  self:_network_cancel()
  self:run()
end

function Slurp:_network_request( url )
  local function onRequest( evt )
    if evt.isError then
      --unrecoverable error, skip to next
      self:run()
    else --a catch!
      self:stop()
      self.callback( evt )
    end
  end
  self.network_id = network.request( url, self.method, onRequest, self.options )
end

function Slurp:_network_cancel()
  if self.network_id then
    network.cancel( self.network_id )
  end
end

function Slurp:_done()
  print('Done')
end

return Slurp
