local args = {...}
local image = require("image")
local loadimage = image.load(args[1])
image.draw(1, 1, loadimage)