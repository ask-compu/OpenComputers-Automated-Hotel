local component = require("component")
local event = require("event")
local cereal = require("serialization")
local storefile = "/etc/bellhopaddress.cfg"
local m = component.modem

m.open(1212)
local _, _, from, port, _, message = event.pull("modem_message")
if message == "pairing client" and port == 1212 then
  local file = io.open(storefile,"w")
  local srl = cereal.serialize(from)
  file:write(srl)
  file:close()
  m.broadcast(1212, "pairing server")  
  print(tostring(from) .. " has been stored at /etc/frontdeskaddress.cfg")
  os.exit()
end
