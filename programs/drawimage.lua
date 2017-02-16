local args = {...}
local image = require("image")
local component = require("component")
local gpu = component.gpu

gpu.setResolution(160,50)
local loadimage = image.load(args[1])
image.draw(1, 1, loadimage)