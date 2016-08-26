local colorlib = {}
local serialization = require("serialization")
--utils
local function check(tVal, tMaxVal, tMinVal, tType)
  
end

local function isNan(x)
  return x~=x
end

--RGB model
function colorlib.HEXtoRGB(color)
  color = math.ceil(color)

  local rr = bit32.rshift( color, 16 )
  local gg = bit32.rshift( bit32.band(color, 0x00ff00), 8 )
  local bb = bit32.band(color, 0x0000ff)

  return rr, gg, bb
end

function colorlib.RGBtoHEX(rr, gg, bb)
  return bit32.lshift(rr, 16) + bit32.lshift(gg, 8) + bb
end

--HSB model
function colorlib.RGBtoHSB(rr, gg, bb)
  local max = math.max(rr, math.max(gg, bb))
  local min = math.min(rr, math.min(gg, bb))
  local delta = max - min

  local h = 0
  if ( max == rr and gg >= bb) then h = 60*(gg-bb)/delta end
  if ( max == rr and gg <= bb ) then h = 60*(gg-bb)/delta + 360 end
  if ( max == gg ) then h = 60*(bb-rr)/delta + 120 end
  if ( max == bb ) then h = 60*(rr-gg)/delta + 240 end

  local s = 0
  if ( max ~= 0 ) then s = 1-(min/max) end

  local b = max*100/255

  if isNan(h) then h = 0 end

  return h, s*100, b
end

function colorlib.HSBtoRGB(h, s, v)
  if h >359 then h = 0 end
  local rr, gg, bb = 0, 0, 0
  local const = 255

  s = s/100
  v = v/100
  
  local i = math.floor(h/60)
  local f = h/60 - i
  
  local p = v*(1-s)
  local q = v*(1-s*f)
  local t = v*(1-(1-f)*s)

  if ( i == 0 ) then rr, gg, bb = v, t, p end
  if ( i == 1 ) then rr, gg, bb = q, v, p end
  if ( i == 2 ) then rr, gg, bb = p, v, t end
  if ( i == 3 ) then rr, gg, bb = p, q, v end
  if ( i == 4 ) then rr, gg, bb = t, p, v end
  if ( i == 5 ) then rr, gg, bb = v, p, q end

  return rr*const, gg*const, bb*const
end

function colorlib.HEXtoHSB(color)
  local rr, gg, bb = colorlib.HEXtoRGB(color)
  local h, s, b = colorlib.RGBtoHSB( rr, gg, bb )
  
  return h, s, b
end

function colorlib.HSBtoHEX(h, s, b)
  local rr, gg, bb = colorlib.HSBtoRGB(h, s, b)
  local color = colorlib.RGBtoHEX(rr, gg, bb)

  return color
end

--Смешивание двух цветов на основе альфа-канала второго
function colorlib.alphaBlend(firstColor, secondColor, alphaChannel)
  local invertedAlphaChannelDividedBy255 = (255 - alphaChannel) / 255
  alphaChannel = alphaChannel / 255
  
  local firstColorRed, firstColorGreen, firstColorBlue = colorlib.HEXtoRGB(firstColor)
  local secondColorRed, secondColorGreen, secondColorBlue = colorlib.HEXtoRGB(secondColor)

  return colorlib.RGBtoHEX(
    secondColorRed * invertedAlphaChannelDividedBy255 + firstColorRed * alphaChannel,
    secondColorGreen * invertedAlphaChannelDividedBy255 + firstColorGreen * alphaChannel,
    secondColorBlue * invertedAlphaChannelDividedBy255 + firstColorBlue * alphaChannel
  )
end

--Получение среднего цвета между перечисленными. К примеру, между черным и белым выдаст серый.
function colorlib.getAverageColor(...)
  local colors = {...}
  local averageRed, averageGreen, averageBlue = 0, 0, 0
  for i = 1, #colors do
    local r, g, b = colorlib.HEXtoRGB(colors[i])
    averageRed, averageGreen, averageBlue = averageRed + r, averageGreen + g, averageBlue + b
  end
  return colorlib.RGBtoHEX(math.floor(averageRed / #colors), math.floor(averageGreen / #colors), math.floor(averageBlue / #colors))
end

-----------------------------------------------------------------------------------------------------------------------

local openComputersPalette = {
  0x000000, 0x000040, 0x000080, 0x0000BF, 0x0000FF, 0x002400, 0x002440, 0x002480, 0x0024BF, 0x0024FF, 0x004900, 0x004940, 0x004980, 0x0049BF, 0x0049FF, 0x006D00, 
  0x006D40, 0x006D80, 0x006DBF, 0x006DFF, 0x009200, 0x009240, 0x009280, 0x0092BF, 0x0092FF, 0x00B600, 0x00B640, 0x00B680, 0x00B6BF, 0x00B6FF, 0x00DB00, 0x00DB40, 
  0x00DB80, 0x00DBBF, 0x00DBFF, 0x00FF00, 0x00FF40, 0x00FF80, 0x00FFBF, 0x00FFFF, 0x0F0F0F, 0x1E1E1E, 0x2D2D2D, 0x330000, 0x330040, 0x330080, 0x3300BF, 0x3300FF, 
  0x332400, 0x332440, 0x332480, 0x3324BF, 0x3324FF, 0x334900, 0x334940, 0x334980, 0x3349BF, 0x3349FF, 0x336D00, 0x336D40, 0x336D80, 0x336DBF, 0x336DFF, 0x339200, 
  0x339240, 0x339280, 0x3392BF, 0x3392FF, 0x33B600, 0x33B640, 0x33B680, 0x33B6BF, 0x33B6FF, 0x33DB00, 0x33DB40, 0x33DB80, 0x33DBBF, 0x33DBFF, 0x33FF00, 0x33FF40, 
  0x33FF80, 0x33FFBF, 0x33FFFF, 0x3C3C3C, 0x4B4B4B, 0x5A5A5A, 0x660000, 0x660040, 0x660080, 0x6600BF, 0x6600FF, 0x662400, 0x662440, 0x662480, 0x6624BF, 0x6624FF, 
  0x664900, 0x664940, 0x664980, 0x6649BF, 0x6649FF, 0x666D00, 0x666D40, 0x666D80, 0x666DBF, 0x666DFF, 0x669200, 0x669240, 0x669280, 0x6692BF, 0x6692FF, 0x66B600, 
  0x66B640, 0x66B680, 0x66B6BF, 0x66B6FF, 0x66DB00, 0x66DB40, 0x66DB80, 0x66DBBF, 0x66DBFF, 0x66FF00, 0x66FF40, 0x66FF80, 0x66FFBF, 0x66FFFF, 0x696969, 0x787878, 
  0x878787, 0x969696, 0x990000, 0x990040, 0x990080, 0x9900BF, 0x9900FF, 0x992400, 0x992440, 0x992480, 0x9924BF, 0x9924FF, 0x994900, 0x994940, 0x994980, 0x9949BF, 
  0x9949FF, 0x996D00, 0x996D40, 0x996D80, 0x996DBF, 0x996DFF, 0x999200, 0x999240, 0x999280, 0x9992BF, 0x9992FF, 0x99B600, 0x99B640, 0x99B680, 0x99B6BF, 0x99B6FF, 
  0x99DB00, 0x99DB40, 0x99DB80, 0x99DBBF, 0x99DBFF, 0x99FF00, 0x99FF40, 0x99FF80, 0x99FFBF, 0x99FFFF, 0xA5A5A5, 0xB4B4B4, 0xC3C3C3, 0xCC0000, 0xCC0040, 0xCC0080, 
  0xCC00BF, 0xCC00FF, 0xCC2400, 0xCC2440, 0xCC2480, 0xCC24BF, 0xCC24FF, 0xCC4900, 0xCC4940, 0xCC4980, 0xCC49BF, 0xCC49FF, 0xCC6D00, 0xCC6D40, 0xCC6D80, 0xCC6DBF, 
  0xCC6DFF, 0xCC9200, 0xCC9240, 0xCC9280, 0xCC92BF, 0xCC92FF, 0xCCB600, 0xCCB640, 0xCCB680, 0xCCB6BF, 0xCCB6FF, 0xCCDB00, 0xCCDB40, 0xCCDB80, 0xCCDBBF, 0xCCDBFF, 
  0xCCFF00, 0xCCFF40, 0xCCFF80, 0xCCFFBF, 0xCCFFFF, 0xD2D2D2, 0xE1E1E1, 0xF0F0F0, 0xFF0000, 0xFF0040, 0xFF0080, 0xFF00BF, 0xFF00FF, 0xFF2400, 0xFF2440, 0xFF2480, 
  0xFF24BF, 0xFF24FF, 0xFF4900, 0xFF4940, 0xFF4980, 0xFF49BF, 0xFF49FF, 0xFF6D00, 0xFF6D40, 0xFF6D80, 0xFF6DBF, 0xFF6DFF, 0xFF9200, 0xFF9240, 0xFF9280, 0xFF92BF, 
  0xFF92FF, 0xFFB600, 0xFFB640, 0xFFB680, 0xFFB6BF, 0xFFB6FF, 0xFFDB00, 0xFFDB40, 0xFFDB80, 0xFFDBBF, 0xFFDBFF, 0xFFFF00, 0xFFFF40, 0xFFFF80, 0xFFFFBF, 0xFFFFFF, 
  possibleChannelValues = {
    r = { 0x00, 0x0F, 0x1E, 0x2D, 0x33, 0x3C, 0x4B, 0x5A, 0x66, 0x69, 0x78, 0x87, 0x96, 0x99, 0xA5, 0xB4, 0xC3, 0xCC, 0xD2, 0xE1, 0xF0, 0xFF },
    g = { 0x00, 0x0F, 0x1E, 0x24, 0x2D, 0x3C, 0x49, 0x4B, 0x5A, 0x69, 0x6D, 0x78, 0x87, 0x92, 0x96, 0xA5, 0xB4, 0xB6, 0xC3, 0xD2, 0xDB, 0xE1, 0xF0, 0xFF },
    b = { 0x00, 0x0F, 0x1E, 0x2D, 0x3C, 0x40, 0x4B, 0x5A, 0x69, 0x78, 0x80, 0x87, 0x96, 0xA5, 0xB4, 0xBF, 0xC3, 0xD2, 0xE1, 0xF0, 0xFF }, 
  }
}

local function getClosestChannelValue(channelName, startIndex, endIndex, requestedValue)
  local difference = endIndex - startIndex
  local centerIndex = math.floor(difference / 2 + startIndex)

  if difference > 1 then
    if requestedValue >= openComputersPalette.possibleChannelValues[channelName][centerIndex] then
      return getClosestChannelValue(channelName, centerIndex, endIndex, requestedValue)
    else
      return getClosestChannelValue(channelName, startIndex, centerIndex, requestedValue)
    end
  else
    if math.abs(requestedValue - openComputersPalette.possibleChannelValues[channelName][startIndex]) > math.abs(openComputersPalette.possibleChannelValues[channelName][endIndex] - requestedValue) then
      return openComputersPalette.possibleChannelValues[channelName][endIndex]
    else
      return openComputersPalette.possibleChannelValues[channelName][startIndex]
    end
  end
end

function colorlib.convert24BitTo8Bit(hex24)
  local encodedIndex
  local r, g, b = colorlib.HEXtoRGB(hex24)

  local rClosest = getClosestChannelValue("r", 1, #openComputersPalette.possibleChannelValues.r, r)
  local gClosest = getClosestChannelValue("g", 1, #openComputersPalette.possibleChannelValues.g, g)
  local bClosest = getClosestChannelValue("b", 1, #openComputersPalette.possibleChannelValues.b, b)
  local hexFinal = colorlib.RGBtoHEX(rClosest, gClosest, bClosest)
  
  for i = 1, #openComputersPalette do
    if openComputersPalette[i] == hexFinal then
      encodedIndex = i
      break
    end
  end

  return encodedIndex - 1
end

function colorlib.convert8BitTo24Bit(hex8)
  return openComputersPalette[hex8 + 1]
end

function colorlib.debugColorCompression(color)
  print("Исходный цвет: " .. string.format("0x%06X", color))
  local compressedColor = colorlib.convert24BitTo8Bit(color)
  print("Сжатый цвет: " .. string.format("0x%02X", compressedColor))
  local decompressedColor = colorlib.convert8BitTo24Bit(compressedColor)
  print("Расжатый цвет: " .. string.format("0x%06X", decompressedColor))
end


-----------------------------------------------------------------------------------------------------------------------

return colorlib






