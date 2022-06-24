local cereal = require("serialization")
local dbfile = "/var/paths.db"

ToA1 = {{"forward",3}, {"turnRight",1}, {"forward",8}, {"turnRight",1}, {"forward",13}, {"turnLeft",1}, {"forward",1}, {"down",1}}
ToA2 = {{"forward",3}, {"turnRight",1}, {"forward",8}, {"turnRight",1}, {"forward",1}, {"turnLeft",1}, {"forward",1}, {"down",1}}
ToA3 = {{"forward",3}, {"turnRight",1}, {"forward",6}, {"turnLeft",1}, {"forward",1}, {"down",1}}
ToA4 = {{"forward",3}, {"turnLeft",1}, {"forward",5},{"turnRight",1}, {"forward",1}, {"down",1}}
ToA5 = {{"forward",3}, {"turnLeft",1}, {"forward",7}, {"turnLeft",1}, {"forward",1}, {"turnRight",1}, {"forward",1}, {"down",1}}
ToA6 = {{"forward",3}, {"turnLeft",1}, {"forward",7}, {"turnLeft",1}, {"forward",13}, {"turnRight",1}, {"forward",1}, {"down",1}}
ToB1 = {{"forward",3}, {"turnRight",1}, {"forward",5}, {"turnRight",1}, {"forward",2}, {"up",5}, {"forward",6}, {"turnLeft",1}, {"forward",3}, {"turnRight",1}, {"forward",5}, {"turnLeft",1}, {"forward",1}, {"down",1}}
ToB2 = {{"forward",3}, {"turnRight",1}, {"forward",5}, {"turnRight",1}, {"forward",2}, {"up",5}, {"forward",6}, {"turnLeft",1}, {"forward",3}, {"turnLeft",1}, {"forward",7}, {"turnRight",1}, {"forward",1}, {"down",1}}
ToB3 = {{"forward",3}, {"turnRight",1}, {"forward",5}, {"turnRight",1}, {"forward",2}, {"up",5}, {"forward",6}, {"turnLeft",1}, {"forward",3}, {"turnLeft",1}, {"forward",8}, {"turnLeft",1}, {"forward",2}, {"turnRight",1}, {"forward",1}, {"down",1}}
ToB4 = {{"forward",3}, {"turnLeft",1}, {"forward",4}, {"turnLeft",1}, {"forward",2}, {"up",5}, {"forward",6}, {"turnRight",1}, {"forward",3}, {"turnRight",1}, {"forward",8}, {"turnRight",1}, {"forward",2}, {"turnLeft",1}, {"forward",1}, {"down",1}}
ToB5 = {{"forward",3}, {"turnLeft",1}, {"forward",4}, {"turnLeft",1}, {"forward",2}, {"up",5}, {"forward",6}, {"turnRight",1}, {"forward",3}, {"turnRight",1}, {"forward",7}, {"turnLeft",1}, {"forward",1}, {"down",1}}
ToB6 = {{"forward",3}, {"turnLeft",1}, {"forward",4}, {"turnLeft",1}, {"forward",2}, {"up",5}, {"forward",6}, {"turnRight",1}, {"forward",3}, {"turnLeft",1}, {"forward",5}, {"turnRight",1}, {"forward",1}, {"down",1}}
FromA1 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnRight",1}, {"forward",13}, {"turnLeft",1}, {"forward",8}, {"turnLeft",1}, {"forward",3}, {"turnAround",1}}
FromA2 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnRight",1}, {"forward",1}, {"turnLeft",1}, {"forward",8}, {"turnLeft",1}, {"forward",3}, {"turnAround",1}}
FromA3 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnRight",1}, {"forward",6}, {"turnLeft",1}, {"forward",3}, {"turnAround",1}}
FromA4 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnLeft",1}, {"forward",5}, {"turnRight",1}, {"forward",3}, {"turnAround",1}}
FromA5 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnLeft",1}, {"forward",1}, {"turnRight",1}, {"forward",7}, {"turnRight",1}, {"forward",3}, {"turnAround",1}}
FromA6 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnLeft",1}, {"forward",13}, {"turnRight",1}, {"forward",7}, {"turnRight",1}, {"forward",3}, {"turnAround",1}}
FromB1 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnRight",1}, {"forward",5}, {"turnLeft",1}, {"forward",3}, {"turnRight",1}, {"forward",6}, {"down",5}, {"forward",2}, {"turnLeft",1}, {"forward",5}, {"turnLeft",1}, {"forward",3}, {"turnAround",1}}
FromB2 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnLeft",1}, {"forward",7}, {"turnRight",1}, {"forward",3}, {"turnRight",1}, {"forward",6}, {"down",5}, {"forward",2}, {"turnLeft",1}, {"forward",5}, {"turnLeft",1}, {"forward",3}, {"turnAround",1}}
FromB3 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnLeft",1}, {"forward",2}, {"turnRight",1}, {"forward",8}, {"turnRight",1}, {"forward",3}, {"turnRight",1}, {"forward",6}, {"down",5}, {"forward",2}, {"turnLeft",1}, {"forward",5}, {"turnLeft",1}, {"forward",3}, {"turnAround",1}}
FromB4 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnRight",1}, {"forward",2}, {"turnLeft",1}, {"forward",8}, {"turnLeft",1}, {"forward",3}, {"turnLeft",1}, {"forward",6}, {"down",5}, {"forward",2}, {"turnRight",1}, {"forward",4}, {"turnRight",1}, {"forward",3}, {"turnAround",1}}
FromB5 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnRight",1}, {"forward",7}, {"turnLeft",1}, {"forward",3}, {"turnLeft",1}, {"forward",6}, {"down",5}, {"forward",2}, {"turnRight",1}, {"forward",4}, {"turnRight",1}, {"forward",3}, {"turnAround",1}}
FromB6 = {{"turnAround",1}, {"up",1}, {"forward",1}, {"turnLeft",1}, {"forward",5}, {"turnRight",1}, {"forward",3}, {"turnLeft",1}, {"forward",6}, {"down",5}, {"forward",2}, {"turnRight",1}, {"forward",4}, {"turnRight",1}, {"forward",3}, {"turnAround",1}}
db = {To={A1={},A2={},A3={},A4={},A5={},A6={},B1={},B2={},B3={},B4={},B5={},B6={}},From={A1={},A2={},A3={},A4={},A5={},A6={},B1={},B2={},B3={},B4={},B5={},B6={}}}

db["To"]["A1"] = ToA1
db["To"]["A2"] = ToA2
db["To"]["A3"] = ToA3
db["To"]["A4"] = ToA4
db["To"]["A5"] = ToA5
db["To"]["A6"] = ToA6
db["To"]["B1"] = ToB1
db["To"]["B2"] = ToB2
db["To"]["B3"] = ToB3
db["To"]["B4"] = ToB4
db["To"]["B5"] = ToB5
db["To"]["B6"] = ToB6
db["From"]["A1"] = FromA1
db["From"]["A2"] = FromA2
db["From"]["A3"] = FromA3
db["From"]["A4"] = FromA4
db["From"]["A5"] = FromA5
db["From"]["A6"] = FromA6
db["From"]["B1"] = FromB1
db["From"]["B2"] = FromB2
db["From"]["B3"] = FromB3
db["From"]["B4"] = FromB4
db["From"]["B5"] = FromB5
db["From"]["B6"] = FromB6

local file = io.open(dbfile,"w")
local srl = cereal.serialize(db)
file:write(srl)
file:close()