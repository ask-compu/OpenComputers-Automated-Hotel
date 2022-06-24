local internet = require("internet")
local json = require("json")

local function time()
  jsonraw = tostring(internet.request("http://worldtimeapi.org/api/timezone/Etc/UTC")())
  decoded = json.decode(jsonraw)
  return tonumber(decoded["unixtime"])
end

return time
