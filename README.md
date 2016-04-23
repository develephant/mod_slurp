# mod_slurp.lua

The Slurp Module for [Corona SDK](https://www.coronalabs.com) allows you to walk a list of URLs and get the first one with content. Skipping unresponsive endpoints, or network related site errors.

### Preflight

## [Download Slurp](https://github.com/develephant/mod_slurp/archive/master.zip)

Add the Slurp Module `mod_slurp.lua` to your __Corona SDK__ project.

```lua
local Slurp = require('mod_slurp')
```

### Usage

Using Slurp is pretty simple; you provide the module with a list of URLs and it will go through each one until it receives valid data. This can be useful for checking busy or unresponsive network endpoints.

__Slurp only has three API methods:__

---

#### `Slurp:new( urls, networkCallback[, options] )`

Set up a new Slurp instance.

#### Returns

A new Slurp instance ready to `:run()`

#### Parameters

|Name|Description|Required|
|----|-----------|--------|
|`urls`|A table array of URL strings, or custom URL table objects (see below)|Yes|
|`networkCallback`|The default method that will be called on network events|Yes|
|`options`|A table of options for the Slurp instance (see below)|No|

#### Options

There are a couple of options you can specify via a table when you create a Slurp instance:

|Key|Description|Default|
|----|-----------|-------|
|`timeout`|The amount of time (in milliseconds) before giving up on a connection|5000|
|`fetch_one`|After the first successful data, Slurp exits. You can have Slurp run through the whole list by setting this key to `false`|true

#### Example

```lua
--Require mod_slurp
local Slurp = require('mod_slurp')

--Crate the URL table array
local urls = { "http://www.e4rrBorked.com", "https://www.google.com" }

--Create a networkCallback
local function networkCallback( evt )
  print( evt.response )
end

--Create a new Slurp instance
local s = Slurp:new( urls, networkCallback, { timeout = 10000 } )
```

---

#### `slurp:run()`

Starts running the Slurp instance, checking sites for connectivity and results. You can run this anytime.

#### Returns

Events through the `networkCallback` set when the instance was created (see `:new()` above).

#### Parameters

__None__

#### Example

```lua
...

--Create the instance
local s = Slurp:new( urls, networkCallback )

--Run the instance
s:run()

```

---

#### `slurp:stop()`

While Slurp generally handles its own life-cycle, in situations where you need a full-stop, you can use this method.

#### Returns

__Nothing__

#### Parameters

__None__

#### Example

```lua
...

--Halt the Slurp instance from anymore processing.
s:stop()
```
---

### URLObjects

Slurp can also process a `URLObject` (a table) in its URL queue, to specify unique options to individual Slurp calls.

#### Schema

|Key|Description|Required|
|----|-----------|--------|
|`url`|The fully qualified URL path to call|Yes|
|`callback`|The custom callback for this URL call|No|
|`options`|A table of network.request options|No|

#### Example

```lua
--A URLObject
local url_obj =
{
  url = "https://www.google.com",
  callback = googleCallback,
  options =
  {
    path = '/?q=dogs'
  }
}
```

URLObjects can be mixed with regular string URLs in the URL queue, as shown below.

---

### Slurp In Action

Lets take a look at fully loaded Slurp session:

```lua
--Load the Slurp Module
local Slurp = require('mod_slurp')

--Put some URLs, and URLObjects into the URL "queue"
local q = {}
table.insert( q, 'http://www.err4Borked.com' ) --Faker
table.insert( q, { url = 'https://www.google.com', callback = googleCallback } )
--This next endpoint will probably never be hit, unless Google fails. :x
table.insert( q, 'https://www.yahoo.com' )

--Create a callback (general)
local function networkCallback( evt )
  print( evt.response )
end

--The custom Google callback
local function googleCallback( evt )
  print( 'Hi Google!' )
  print( evt.response )
end

--Initiate a Slurp instance
local s = Slurp:new( q, networkCallback )

--Run it, results come through the callbacks
s:run()
```

---

### Summary Notes

Once you put together the URL queue, as in the example above, and set up the "callbacks", we run the queue. By default, once the first successful result is found, Slurp stops processing that instance (unless you set it otherwise).

By incorporating `URLObjects` in the queue, you can specialize certain endpoint results. For instance, in the example above, we have a custom object for Google. When Google returns its results, the `googleCallback` will be triggered. Any other URL (in the example list above) would trigger the default `networkCallback`.

Timeouts are not based on the normal network timeout, but an actual timer instance. This provides more flexibility in moving through your queue. For instance, instead of waiting N seconds for the network timeout, you can decide to move on to the next URL at any amount of time of your choosing. This can be set when creating a Slurp instance. This can not be set per URL at this time.

If Slurp runs into network errors, it will skip to the next URL in the queue, if any. The timeout is disregarded in these cases.

__[Visit the Corona Labs forums with any questions.](https://forums.coronalabs.com)__

---
