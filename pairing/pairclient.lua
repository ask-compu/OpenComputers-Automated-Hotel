local component = require("component")
local event = require("event")
local cereal = require("serialization")
local storefile = "/etc/serveraddress.cfg"
local m = component.modem

m.open(1212)
m.broadcast(1212, "pairing client")
local _, _, from, port, _, message = event.pull("modem_message")
if message == "pairing server" and port == 1212 then
  local file = io.open(storefile,"w")
  local srl = cereal.serialize(from)
  file:write(srl)
  file:close()
  print(tostring(from) .. " has been stored at /etc/serveraddress.cfg")
  os.exit()
end
