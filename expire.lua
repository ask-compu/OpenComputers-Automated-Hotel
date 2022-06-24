local event = require("event")
local unixtime = require("unixtime")
local timerID = nil
local roomlist = {"A1","A2","A3","A4","A5","A6","B1","B2","B3","B4","B5","B6"}

local function expireCheck()
  currenttime = unixtime()
  for i,t in ipairs(roomlist) do
    event.push("database",false,t)
    local _,db = event.pull("databaseReply")
    if db["reserved"] then
      if currenttime - db["time"] > 1728000 then
        event.push("dispatch","unreserve",t)
        db["reserved"] = false
        db["time"] = 0
        db["username"] = ""
        event.push("database",true,t,db)
      end
    end
  end
end

function start()
  expireCheck()
  timerID = event.timer(3600,expireCheck,math.huge)
end
 
function stop()
  event.cancel(timerID)
end