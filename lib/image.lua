
---------------------------------------- OpenComputers Image Format (OCIF) -----------------------------------------------------------

--[[
	
	�����: Pornogion
		VK: https://vk.com/id88323331
	�������: IT
		VK: https://vk.com/id7799889
	�������� �������:
		image.load(string ����): table �����������
			��������� ������������ �������� � ������� .pic � ���������� ��
			� �������� ������� (�������).
		image.draw(int x, int y, table �����������)
			������ �� ������ ����������� ����� �������� �� ��������� �����������.
		image.save(string ����, table ����������� [, int ����� �����������])
			��������� ��������� �������� �� ���������� ���� � ������� .pic,
			�� ��������� ��������� ����� ����������� 3. �������������
			������������ ������ ���.
	������� ��� ������ � ������������:
		
		image.transform(table ��������, int ������� �� ������, int ������� �� ������): table ��������
			�������� ������ �������� �� ������ ������������ �� �������� ��������.
			
		image.expand(table ��������, string �����������, int ���������� ��������[, int ���� ����, int ���� ������, int ������������, char ������]): table ��������
			��������� ��������� �������� � ��������� ����������� (fromRight, fromLeft, fromTop, fromBottom),
			�������� ��� ���� ������ ����� �������. ���� ������� ������������ ���������, �� ������ ������
			�������� ����� ���� ������ ���������� ��������.
		image.crop(table ��������, string �����������, int ���������� ��������): table ��������
			�������� ��������� �������� � ��������� ����������� (fromRight, fromLeft, fromTop, fromBottom),
			������ ������ �������.
		image.rotate(table ��������, int ����): table ��������
			������������ ��������� �������� �� ��������� ����. ���� ����� �����
			�������� 90, 180 � 270 ��������.
		image.flipVertical(table ��������): table ��������
			�������� ��������� �������� �� ���������.
		image.flipHorizontal(table ��������): table ��������
			�������� ��������� �������� �� �����������.
	������� ��� ������ � ������:
		image.hueSaturationBrightness(table ��������, int ���, int ������������, int �������): table ��������
			������������ �������� ���, ������������ � ������� ��������� ��������.
			�������� ���������� ����� ���� �������������� ��� ���������� ���������
			� �������������� ��� ��� ����������. ���� ��������, � �������, ������������
			������ �� ���������, ������ ���������� 0.
			
			��� �������� �� ������ ������������ ��������� ����������:
				image.hue(table ��������, int ���): table ��������
				image.saturation(table ��������, int ������������): table ��������
				image.brightness(table ��������, int �������): table ��������
				image.blackAndWhite(table ��������): table ��������
		image.colorBalance(table ��������, int �������, int �������, int �����): table ��������
			������������ �������� ������ ����������� ��������� ��������. ��������� ��������
			������� ����� ��������� ��� ������������� �������� ��� ���������� ������������� ������,
			��� � ������������� ��� ����������.
		image.invert(table ��������): table ��������
			����������� ����� � ��������� ��������.
		image.photoFilter(table ��������, int ����, int ������������): table ��������
			����������� �� ��������� ����������� ���������� � ��������� �������������.
			������������ ����� ���� �� 0 �� 255.
		image.replaceColor(table ��������, int ��������������, int �������������): table ��������
			�������� � ��������� ����������� ���� ���������� ���� �� ������.
]]

--------------------------------------- ��������� ��������� --------------------------------------------------------------

-- ���������� �������� ����������� ��������� � �����������
local libraries = {
	component = "component",
	unicode = "unicode",
	fs = "filesystem",
	colorlib = "colorlib",
	bit32 = "bit32",
}

for library in pairs(libraries) do if not _G[library] then _G[library] = require(libraries[library]) end end; libraries = nil

local image = {}

-------------------------------------------- ���������� -------------------------------------------------------------------

--��������� ���������
local constants = {
	OCIFSignature = "OCIF",
	OCIF2Elements = {
		alphaStart = "A",
		symbolStart = "S",
		backgroundStart = "B",
		foregroundStart = "F",
	},
	elementCount = 4,
	byteSize = 8,
	nullChar = 0,
	rawImageLoadStep = 19,
	compressedFileFormat = ".pic",
	pngFileFormat = ".png",
}

---------------------------------------- ��������� ������� -------------------------------------------------------------------

--������� ����������� ������� ������� ����������� � ���������� ���������� ������� �����������
local function convertIndexToCoords(index, width)
	--�������� ������ � ����������� ���� (1 = 1, 4 = 2, 7 = 3, 10 = 4, 13 = 5, ...)
	index = (index + constants.elementCount - 1) / constants.elementCount
	--�������� ������� �� ������� ������� �� ������ �����������
	local ostatok = index % width
	--���� ������� ����� 0, �� � ����� ������ �����������, � ���� ���, �� � ����� �������
	local x = (ostatok == 0) and width or ostatok
	--� ������ ��� ��� ������ �������� ���������� �� Y
	local y = math.ceil(index / width)
	--������� ������� �� ����������
	ostatok = nil
	--���������� ����������
	return x, y
end

--������� ����������� ���������� ��������� ������� ����������� � ������ ��� ������� �����������
local function convertCoordsToIndex(x, y, width)
	return (width * (y - 1) + x) * constants.elementCount - constants.elementCount + 1
end

--���������� ��������� ������� �������, ��� ����� ��� �� ���������
--������������ �������������� ������� ����� #massiv
--���, ���
--...
--���
local function getArraySize(array)
	local size = 0
	for key in pairs(array) do
		size = size + 1
	end
	return size
end

--�������� ���������� ����, ������� ����� ������� �� ���������� �����
local function getCountOfBytes(number)
	if number == 0 or number == 1 then return 1 end
	return math.ceil(math.log(number, 256))
end

--������������� ����� �� ������������ �����
local function extractBytesFromNumber(number, countOfBytesToExtract)
	local bytes = {}
	local byteCutter = 0xff
	for i = 1, countOfBytesToExtract do
		table.insert(bytes, 1, bit32.rshift(bit32.band(number, byteCutter), (i-1)*8))
		byteCutter = bit32.lshift(byteCutter, 8)
	end
	return table.unpack(bytes)
end

--������� ����� � ������� �� ��� �����
local function mergeBytesToNumber(...)
	local bytes = {...}
	local finalNumber = bytes[1]
	for i = 2, #bytes do
		finalNumber = bit32.bor(bit32.lshift(finalNumber, 8), bytes[i])
	end
	return finalNumber
end

-- ��������������� ��� ���������� ����� � ������
local function convertBytesToString(...)
	local bytes = {...}
	for i = 1, #bytes do
		bytes[i] = string.char(bytes[i])
	end
	return table.concat(bytes)
end

--�������� ���-���������� � ������ ����� UTF-8 �������: 1100 0010 --> 0010 0000
local function selectTerminateBit_l()
	local prevByte = nil
	local prevTerminateBit = nil

	return function( byte )
		local x, terminateBit = nil
		if ( prevByte == byte ) then
			return prevTerminateBit
		end

		x = bit32.band( bit32.bnot(byte), 0x000000FF )
		x = bit32.bor( x, bit32.rshift(x, 1) )
		x = bit32.bor( x, bit32.rshift(x, 2) )
		x = bit32.bor( x, bit32.rshift(x, 4) )
		x = bit32.bor( x, bit32.rshift(x, 8) )
		x = bit32.bor( x, bit32.rshift(x, 16) )

		terminateBit = x - bit32.rshift(x, 1)

		prevByte = byte
		prevTerminateBit = terminateBit

		return terminateBit
	end
end
local selectTerminateBit = selectTerminateBit_l()

--��������� n ������ �� �����, ���������� ����������� ����� ��� �����, ���� �� ������� ���������, �� ���������� 0
local function readBytes(file, count)
  local readedBytes = file:read(count)
  return mergeBytesToNumber(string.byte(readedBytes, 1, count))
end

--�������������� ����� � ������ ��� ������ � ���� ������� �������
local function encodePixel(background, foreground, alpha, char)
	--������������� ������ ����� � ���������� �����
	local ascii_background1, ascii_background2, ascii_background3 = colorlib.HEXtoRGB(background)
	local ascii_foreground1, ascii_foreground2, ascii_foreground3 = colorlib.HEXtoRGB(foreground)
	--������������� ������ ��� ������-������� � ��������� ��������� ascii-�����
	local ascii_char1, ascii_char2, ascii_char3, ascii_char4, ascii_char5, ascii_char6 = string.byte( char, 1, 6 )
	ascii_char1 = ascii_char1 or constants.nullChar
	--���������� ��� �������������
	return ascii_background1, ascii_background2, ascii_background3, ascii_foreground1, ascii_foreground2, ascii_foreground3, alpha, ascii_char1, ascii_char2, ascii_char3, ascii_char4, ascii_char5, ascii_char6
end

--������������� UTF-8 �������
local function decodeChar(file)
	local first_byte = readBytes(file, 1)
	local charcode_array = {first_byte}
	local len = 1

	local middle = selectTerminateBit(first_byte)
	if ( middle == 32 ) then
		len = 2
	elseif ( middle == 16 ) then 
		len = 3
	elseif ( middle == 8 ) then
		len = 4
	elseif ( middle == 4 ) then
		len = 5
	elseif ( middle == 2 ) then
		len = 6
	end

	for i = 1, len-1 do
		table.insert( charcode_array, readBytes(file, 1) )
	end

	return string.char( table.unpack( charcode_array ) )
end

--���������� ��������������� HEX-���������� � ���������
local function HEXtoSTRING(color, bitCount, withNull)
	local stro4ka = string.format("%X",color)
	local sStro4ka = unicode.len(stro4ka)

	if sStro4ka < bitCount then
		stro4ka = string.rep("0", bitCount - sStro4ka) .. stro4ka
	end

	sStro4ka = nil

	if withNull then return "0x"..stro4ka else return stro4ka end
end

--��������� ������� �����
local function getFileFormat(path)
	local name = fs.name(path)
	local starting, ending = string.find(name, "(.)%.[%d%w]*$")
	if starting == nil then
		return nil
	else
		return unicode.sub(name, starting + 1, -1)
	end
	name, starting, ending = nil, nil, nil
end

--�������� ��������� ����� � �������� �� � ����������
local function readSignature(file)
	local readedSignature = file:read(4)
	if readedSignature ~= constants.OCIFSignature then
		file:close()
		error("Can't load file: wrong OCIF format signature (\""..readedSignature .. "\" ~= \"" ..constants.OCIFSignature .. "\")")
	end
end

--�������� ��������� � ����
local function writeSignature(file)
	file:write(constants.OCIFSignature)
end

--����� ��� ����� � ����������� � 8-������ �������
local function convertImageColorsTo8Bit(picture)
	for i = 1, #picture, 4 do
		picture[i] = colorlib.convert24BitTo8Bit(picture[i])
		picture[i + 1] = colorlib.convert24BitTo8Bit(picture[i + 1])
		if i % 505 == 0 then os.sleep(0) end
	end
	return picture
end

--������� ��� ����� � ����������� � 24-������ �������
local function convertImageColorsTo24Bit(picture)
	for i = 1, #picture, 4 do
		picture[i] = colorlib.convert8BitTo24Bit(picture[i])
		picture[i + 1] = colorlib.convert8BitTo24Bit(picture[i + 1])
		if i % 505 == 0 then os.sleep(0) end
	end
	return picture
end

------------------------------ ���, ��� �������� ������� OCIF1 ------------------------------------------------------------

-- ������ � ���� ������� OCIF-������� �����������
local function saveOCIF1(file, picture)
	local encodedPixel
	file:write( string.char( picture.width  ) )
	file:write( string.char( picture.height ) )
	
	for i = 1, picture.width * picture.height * constants.elementCount, constants.elementCount do
		encodedPixel =
		{
			encodePixel(picture[i], picture[i + 1], picture[i + 2], picture[i + 3])
		}
		for j = 1, #encodedPixel do
			file:write( string.char( encodedPixel[j] ) )
		end
	end

	file:close()
end

--������ �� ����� ������� OCIF-������� �����������, ���������� ������ ���� 2 (��������� � ����� ��. ����� �����)
local function loadOCIF1(file)
	local picture = {}

	--������ ������ � ������ �����
	picture.width = readBytes(file, 1)
	picture.height = readBytes(file, 1)

	for i = 1, picture.width * picture.height do
		--������ ���������
		table.insert(picture, readBytes(file, 3))
		--������ ���������
		table.insert(picture, readBytes(file, 3))
		--������ �����
		table.insert(picture, readBytes(file, 1))
		--������ ������
		table.insert(picture, decodeChar( file ))
	end

	file:close()

	return picture
end

------------------------------------------ ���, ��� �������� ������� OCIF2 ------------------------------------------------

local function saveOCIF2(file, picture, compressColors)
	--���������� ������ �����������
	file:write(string.char(picture.width))
	file:write(string.char(picture.height))

	--���������� ��������
	local grouppedPucture = image.convertToGroupedImage(picture)

	--���������� ��� �����
	for alpha in pairs(grouppedPucture) do
		--�������� ������ �������, ����������� �������
		local arraySize = getArraySize(grouppedPucture[alpha])
		local countOfBytesForArraySize = getCountOfBytes(arraySize)
		--���������� � ���� ������ �����������, ������ ������� ����� � ���� �������� �����
		file:write(
			constants.OCIF2Elements.alphaStart,
			string.char(countOfBytesForArraySize),
			convertBytesToString(extractBytesFromNumber(arraySize, countOfBytesForArraySize)),
			string.char(alpha)
		)
		
		for symbol in pairs(grouppedPucture[alpha]) do
			--���������� ���������
			file:write(constants.OCIF2Elements.symbolStart)
			--���������� ���������� ���� ������ ������ � ������
			if compressColors then
				file:write(
					string.char(getArraySize(grouppedPucture[alpha][symbol])),
					convertBytesToString(string.byte(symbol, 1, 6))
				)
			else
				file:write(	
					convertBytesToString(extractBytesFromNumber(getArraySize(grouppedPucture[alpha][symbol]), 3)),
					convertBytesToString(string.byte(symbol, 1, 6))
				)
			end
		
			for foreground in pairs(grouppedPucture[alpha][symbol]) do
				--���������� ���������
				file:write(constants.OCIF2Elements.foregroundStart)
				--���������� ���������� ������ ���� � ���� ������
				if compressColors then
					file:write(
						string.char(getArraySize(grouppedPucture[alpha][symbol][foreground])),
						string.char(foreground)
					)
				else
					file:write(
						convertBytesToString(extractBytesFromNumber(getArraySize(grouppedPucture[alpha][symbol][foreground]), 3)),
						convertBytesToString(extractBytesFromNumber(foreground, 3))
					)
				end
		
				for background in pairs(grouppedPucture[alpha][symbol][foreground]) do
					--���������� ��������� � ������ ������� ���������
					file:write(
							constants.OCIF2Elements.backgroundStart,
							convertBytesToString(extractBytesFromNumber(getArraySize(grouppedPucture[alpha][symbol][foreground][background]), 2))
					)
					--���������� ���� ����
					if compressColors then
						file:write(string.char(background))
					else
						file:write(convertBytesToString(extractBytesFromNumber(background, 3)))
					end
			
					--���������� ����������
					for y in pairs(grouppedPucture[alpha][symbol][foreground][background]) do
						--���������� ��������� ���������, ������ ������� y � ���� �������� y
						file:write(
							"Y",
							string.char(getArraySize(grouppedPucture[alpha][symbol][foreground][background][y])),
							string.char(y)
						)
						--���������� ������
						--�
						for i = 1, #grouppedPucture[alpha][symbol][foreground][background][y] do
							file:write(string.char(grouppedPucture[alpha][symbol][foreground][background][y][i]))
						end
					end
				end
			end
		end
	end

	file:close()
end

local function loadOCIF2(file, decompressColors, useOCIF4)
	local picture = {}

	--������ ������ �����������
	local readedWidth = string.byte(file:read(1))
	local readedHeight = string.byte(file:read(1))
	picture.width = readedWidth
	picture.height = readedHeight

	local header, alpha, symbol, foreground, background, y, alphaSize, symbolSize, foregroundSize, backgroundSize, ySize = ""
	while true do
		header = file:read(1)
		if not header then break end
		-- print("----------------------")
		-- print("���������: " .. header)

		if header == "A" then
			local countOfBytesForArraySize = string.byte(file:read(1))
			alphaSize = string.byte(file:read(countOfBytesForArraySize))
			alpha = string.byte(file:read(1))
			-- print("���������� ���� ��� ������ ������� ��������: " .. countOfBytesForArraySize)
			-- print("������ ������� ��������: " .. alphaSize)
			-- print("�����: " .. alpha)

		elseif header == "S" then
			if decompressColors then
				symbolSize = string.byte(file:read(1))
			else
				symbolSize = mergeBytesToNumber(string.byte(file:read(3), 1, 3))
			end
			symbol = decodeChar(file)
			-- print("������ ������� ����� ������: " .. symbolSize)
			-- print("������: \"" .. symbol .. "\"")

		elseif header == "F" then
			if decompressColors then
				foregroundSize = string.byte(file:read(1))
				foreground = colorlib.convert8BitTo24Bit(string.byte(file:read(1)))
			else
				foregroundSize = mergeBytesToNumber(string.byte(file:read(3), 1, 3))
				foreground = mergeBytesToNumber(string.byte(file:read(3), 1, 3))
			end
			-- print("������ ������� ����� ����: " .. foregroundSize)
			-- print("���� ������: " .. foreground)

		elseif header == "B" then
			backgroundSize = mergeBytesToNumber(string.byte(file:read(2), 1, 2))
			if decompressColors then
				background = colorlib.convert8BitTo24Bit(string.byte(file:read(1)))
			else
				background = mergeBytesToNumber(string.byte(file:read(3), 1, 3))
			end
			-- print("������ ������� ���������: " .. backgroundSize)
			-- print("���� ����: " .. background)

			--��������� �������� ������� OCIF3
			if not useOCIF4 then
				--������ ����������
				for i = 1, backgroundSize, 2 do
					local x = string.byte(file:read(1))
					local y = string.byte(file:read(1))
					local index = convertCoordsToIndex(x, y, readedWidth)
					-- print("����������: " .. x .. "x" .. y .. ", ������: "..index)

					picture[index] = background
					picture[index + 1] = foreground
					picture[index + 2] = alpha
					picture[index + 3] = symbol
				end	
			end

		--����� ������ OCIF4
		elseif header == "Y" and useOCIF4 then
			ySize = string.byte(file:read(1))
			y = string.byte(file:read(1))
			-- print("������ ������� Y: " .. ySize)
			-- print("������� Y: " .. y)

			for i = 1, ySize do
				local x = string.byte(file:read(1))
				local index = convertCoordsToIndex(x, y, readedWidth)
				-- print("����������: " .. x .. "x" .. y .. ", ������: "..index)

				picture[index] = background
				picture[index + 1] = foreground
				picture[index + 2] = alpha
				picture[index + 3] = symbol
			end		
		else
			error("Error while reading OCIF format: unknown Header type (" .. header .. ")")
		end

	end

	file:close()

	return picture
end

------------------------------ ���, ��� �������� ������� RAW ------------------------------------------------------------

--���������� � ���� ������ ������� ����������� ���� 2 (��������� � ����� ��. ����� �����)
local function saveRaw(file, picture)

	file:write("\n")

	local xPos, yPos = 1, 1
	for i = 1, picture.width * picture.height * constants.elementCount, constants.elementCount do
		file:write( HEXtoSTRING(picture[i], 6), " ", HEXtoSTRING(picture[i + 1], 6), " ", HEXtoSTRING(picture[i + 2], 2), " ", picture[i + 3], " ")

		xPos = xPos + 1
		if xPos > picture.width then
			xPos = 1
			yPos = yPos + 1
			file:write("\n")
		end
	end

	file:close()
end

--�������� �� ����� ������ ������� ����������� ���� 2 (��������� � ����� ��. ����� �����)
local function loadRaw(file)
	--������ ���� ���� "����� ���"
	file:read(1)

	local picture = {}
	local background, foreground, alpha, symbol, sLine
	local lineCounter = 0

	for line in file:lines() do
		sLine = unicode.len(line)
		for i = 1, sLine, constants.rawImageLoadStep do
			background = "0x" .. unicode.sub(line, i, i + 5)
			foreground = "0x" .. unicode.sub(line, i + 7, i + 12)
			alpha = "0x" .. unicode.sub(line, i + 14, i + 15)
			symbol = unicode.sub(line, i + 17, i + 17)

			table.insert(picture, tonumber(background))
			table.insert(picture, tonumber(foreground))
			table.insert(picture, tonumber(alpha))
			table.insert(picture, symbol)
		end
		lineCounter = lineCounter + 1
	end

	picture.width = sLine / constants.rawImageLoadStep
	picture.height = lineCounter

	file:close()
	return picture
end

----------------------------------- ���, ��� �������� ��������� PNG-������� ------------------------------------------------------------

function image.loadPng(path)
	if not _G.libPNGImage then _G.libPNGImage = require("libPNGImage") end

	local success, pngImageOrErrorMessage = pcall(libPNGImage.newFromFile, path)

	if not success then
		io.stderr:write(" * PNGView: PNG Loading Error *\n")
		io.stderr:write("While attempting to load '" .. path .. "' as PNG, libPNGImage erred:\n")
		io.stderr:write(pngImageOrErrorMessage)
		return
	end

	local picture = {}
	picture.width, picture.height = pngImageOrErrorMessage:getSize()

	local r, g, b, a, hex
	for j = 0, picture.height - 1 do
		for i = 0, picture.width - 1 do
			r, g, b, a = pngImageOrErrorMessage:getPixel(i, j)

			if r and g and b and a and a > 0 then
				hex = colorlib.RGBtoHEX(r, g, b)
				table.insert(picture, hex)
				table.insert(picture, 0x000000)
				table.insert(picture, 0x00)
				table.insert(picture, " ")
			end

		end
	end

	return picture
end

----------------------------------- ��������������� ������� ��������� ------------------------------------------------------------

--�������������� � ������������� �� ������ �������� ���� 2 (��������� � ����� ��. ����� �����)
function image.convertToGroupedImage(picture)
	--������� ������ ���������������� ��������
	local optimizedPicture = {}
	--������ ���������
	local xPos, yPos, background, foreground, alpha, symbol = 1, 1, nil, nil, nil, nil
	--���������� ��� �������� �������
	for i = 1, picture.width * picture.height * constants.elementCount, constants.elementCount do
		--�������� ������ �� ������������������� �������
		background, foreground, alpha, symbol = picture[i], picture[i + 1], picture[i + 2], picture[i + 3]
		--���������� �������� �� ������
		optimizedPicture[alpha] = optimizedPicture[alpha] or {}
		optimizedPicture[alpha][symbol] = optimizedPicture[alpha][symbol] or {}
		optimizedPicture[alpha][symbol][foreground] = optimizedPicture[alpha][symbol][foreground] or {}
		optimizedPicture[alpha][symbol][foreground][background] = optimizedPicture[alpha][symbol][foreground][background] or {}
		optimizedPicture[alpha][symbol][foreground][background][yPos] = optimizedPicture[alpha][symbol][foreground][background][yPos] or {}

		table.insert(optimizedPicture[alpha][symbol][foreground][background][yPos], xPos)
		--���� xPos ��������� width �����������, �� �������� �� 1, ����� xPos++
		xPos = (xPos == picture.width) and 1 or xPos + 1
		--���� xPos ��������� 1, �� yPos++, � ���� ���, �� �����
		yPos = (xPos == 1) and yPos + 1 or yPos
	end
	--���������� ���������������� ������
	return optimizedPicture
end

--���������� �� ��������� ����������� �������� ��������� ������ � ������ ��� �����
function image.createImage(width, height, random)
	local picture = {}
	local symbolArray = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�"}
	picture.width = width
	picture.height = height
	local background, foreground, symbol
	for j = 1, height do
		for i = 1, width do
			if random then
				background = math.random(0x000000, 0xffffff)
				foreground = math.random(0x000000, 0xffffff)
				symbol = symbolArray[math.random(1, #symbolArray)]
			else
				background = 0x880000
				foreground = 0xffffff
				symbol = "Q"
			end

			table.insert(picture, background)
			table.insert(picture, foreground)
			table.insert(picture, 0x00)
			table.insert(picture, symbol)
		end
	end
	-- image.draw(x, y, picture)
	return picture
end

-- ������� ����������� ����� ������ � �������� � ��������, ��������� ����� GPU-�������� ��� ��������� �� ������
-- ���������� ������ ��� ���������� �����, ��� ��� �� �������������� �� �����������,
-- � � ����� ����� ����� � ����� ��������. ������ ������������ ����������.
function image.optimize(picture)
	local i1, i2, i3 = 0, 0, 0
	for i = 1, #picture, constants.elementCount do
		--��������� �������� �� ����
		i1, i2, i3 = i + 1, i + 2, i + 3
		--���� ���� ���� ����� ����� ������, � ������������ ����������������� �����������
		if picture[i] == picture[i1] and (picture[i3] == "-" or picture[i3] == "-") then
			picture[i3] = " "
		end
		--���� ������ ����� ��������, �.�. ���� ������ �� �����������
		if picture[i3] == " " then		
			picture[i1] = 0x000000
		end
	end

	return picture
end

--�������� ������� �� ����������� �� ��������� �����������
function image.get(picture, x, y)
	if x >= 1 and y >= 1 and x <= picture.width and y <= picture.height then
		local index = convertCoordsToIndex(x, y, picture.width)
		return picture[index], picture[index + 1], picture[index + 2], picture[index + 3] 
	else
		return nil
	end
end

--���������� ������� � ����������� �� ��������� �����������
function image.set(picture, x, y, background, foreground, alpha, symbol)
	if x >= 1 and y >= 1 and x <= picture.width and y <= picture.height then
		local index = convertCoordsToIndex(x, y, picture.width)
		picture[index] = background or 0xFF00FF
		picture[index + 1] = foreground or 0xFF00FF
		picture[index + 2] = alpha or 0x00
		picture[index + 3] = symbol or " "
		return picture
	else
		error("Can't set pixel because it's located out of image coordinates: x = " .. x .. ", y = " .. y)
	end
end

------------------------------------------ ������� ������ ��������� � ������ ------------------------------------------------

--������� �������� ������ � ��������� ��� �� ���������� ����
function image.screenshot(path)
	local picture = {}
	local foreground, background, symbol
	picture.width, picture.height = component.gpu.getResolution()
	
	for j = 1, picture.height do
		for i = 1, picture.width do
			symbol, foreground, background = component.gpu.get(i, j)
			table.insert(picture, background)
			table.insert(picture, foreground)
			table.insert(picture, 0x00)
			table.insert(picture, symbol)
		end
	end

	image.save(path, picture)
end

------------------------------------------ ������ ����������������� ����������� ------------------------------------------------

--������� ���� ��������
function image.insertRow(picture, y, rowArray)
	local index = convertCoordsToIndex(1, y, picture.width)
	for i = 1, #rowArray, 4 do
		table.insert(picture, index, rowArray[i + 3])
		table.insert(picture, index, rowArray[i + 2])
		table.insert(picture, index, rowArray[i + 1])
		table.insert(picture, index, rowArray[i])
		index = index + 4
	end
	picture.height = picture.height + 1
	return picture
end

function image.insertColumn(picture, x, columnArray)
	local index = convertCoordsToIndex(x, 1, picture.width)
	for i = 1, #columnArray, 4 do
		table.insert(picture, index, columnArray[i + 3])
		table.insert(picture, index, columnArray[i + 2])
		table.insert(picture, index, columnArray[i + 1])
		table.insert(picture, index, columnArray[i])
		index = index + picture.width * 4 + 4
	end
	picture.width = picture.width + 1
	return picture
end

--�������� ���� ��������
function image.removeRow(picture, y)
	local index = convertCoordsToIndex(1, y, picture.width)
	for i = 1, picture.width * 4 do table.remove(picture, index) end
	picture.height = picture.height - 1
	return picture
end

--�������� ������� ��������
function image.removeColumn(picture, x)
	local index = convertCoordsToIndex(x, 1, picture.width)
	for i = 1, picture.height do
		for j = 1, 4 do table.remove(picture, index) end
		index = index + (picture.width) * 4 - 4
	end
	picture.width = picture.width - 1
	return picture
end

--��������� ���� ��������
function image.getRow(picture, y)
	local row, background, foreground, alpha, symbol = {width = picture.width, height = 1}
	for x = 1, picture.width do
		background, foreground, alpha, symbol = image.get(picture, x, y)
		table.insert(row, background)
		table.insert(row, foreground)
		table.insert(row, alpha)
		table.insert(row, symbol)
	end
	return row
end

--��������� ������� ��������
function image.getColumn(picture, x)
	local column, background, foreground, alpha, symbol = {width = 1, height = picture.height}
	for y = 1, picture.height do
		background, foreground, alpha, symbol = image.get(picture, x, y)
		table.insert(column, background)
		table.insert(column, foreground)
		table.insert(column, alpha)
		table.insert(column, symbol)
	end
	return column
end

--�������� ����� ������� �����������
function image.duplicate(picture)
	local newPicture = {width = picture.width, height = picture.height}
	for i = 1, #picture do newPicture[i] = picture[i] end
	return newPicture
end

--������ ���������� ����������������� �� ��������
function image.transform(picture, newWidth, newHeight)
	local newPicture = image.duplicate(picture)
	local widthScale, heightScale = newWidth / picture.width, newHeight / picture.height
	local deltaWidth, deltaHeight = math.abs(newWidth - picture.width), math.abs(newHeight - picture.height)
	local widthIteration, heightIteration = widthScale > 1 and newWidth / deltaWidth or picture.width / deltaWidth, heightScale > 1 and newHeight / deltaHeight or picture.height / deltaHeight

	-- ecs.error(widthIteration, heightIteration, deltaWidth, picture.width, newWidth)

	--������� ������� �� ������
	if widthScale > 1 then
		local x = 1
		while x <= newPicture.width do
			if math.floor(x % widthIteration) == 0 then newPicture = image.insertColumn(newPicture, x, image.getColumn(newPicture, x - 1)) end
			x = x + 1
		end
	elseif widthScale < 1 then
		local x = 1
		while x <= newPicture.width do
			if math.floor(x % widthIteration) == 0 then newPicture = image.removeColumn(newPicture, x) end
			x = x + 1
		end
	end

	--� �� ������
	if heightScale > 1 then
		local y = 1
		while y <= newPicture.height do
			if math.floor(y % heightIteration) == 0 then newPicture = image.insertRow(newPicture, y, image.getRow(newPicture, y - 1)) end
			y = y + 1
		end
	elseif heightScale < 1 then
		local y = 1
		while y <= newPicture.height do
			if math.floor(y % heightIteration) == 0 then newPicture = image.removeRow(newPicture, y) end
			y = y + 1
		end
	end

	return newPicture
end

function image.expand(picture, mode, countOfPixels, background, foreground, alpha, symbol)
	local column = {}; for i = 1, picture.height do table.insert(column, background or 0xFFFFFF); table.insert(column, foreground or 0xFFFFFF); table.insert(column, alpha or 0x00); table.insert(column, symbol or " ") end
	local row = {}; for i = 1, picture.height do table.insert(row, background or 0xFFFFFF); table.insert(row, foreground or 0xFFFFFF); table.insert(row, alpha or 0x00); table.insert(row, symbol or " ") end

	if mode == "fromRight" then
		for i = 1, countOfPixels do picture = image.insertColumn(picture, picture.width + 1, column) end
	elseif mode == "fromLeft" then
		for i = 1, countOfPixels do picture = image.insertColumn(picture, 1, column) end
	elseif mode == "fromTop" then
		for i = 1, countOfPixels do picture = image.insertRow(picture, 1, row) end
	elseif mode == "fromBottom" then
		for i = 1, countOfPixels do picture = image.insertRow(picture, picture.height + 1, row) end
	else
		error("Wrong image expanding mode: only 'fromRight', 'fromLeft', 'fromTop' and 'fromBottom' are supported.")
	end

	return picture
end

function image.crop(picture, mode, countOfPixels)
	if mode == "fromRight" then
		for i = 1, countOfPixels do picture = image.removeColumn(picture, picture.width) end
	elseif mode == "fromLeft" then
		for i = 1, countOfPixels do picture = image.removeColumn(picture, 1) end
	elseif mode == "fromTop" then
		for i = 1, countOfPixels do picture = image.removeRow(picture, 1) end
	elseif mode == "fromBottom" then
		for i = 1, countOfPixels do picture = image.removeRow(picture, picture.height) end
	else
		error("Wrong image cropping mode: only 'fromRight', 'fromLeft', 'fromTop' and 'fromBottom' are supported.")
	end

	return picture
end

function image.flipVertical(picture)
	local newPicture = {}; newPicture.width = picture.width; newPicture.height = picture.height
	for j = picture.height, 1, -1 do
		for i = 1, picture.width do
			local index = convertCoordsToIndex(i, j, picture.width)
			table.insert(newPicture, picture[index]); table.insert(newPicture, picture[index + 1]); table.insert(newPicture, picture[index + 2]); table.insert(newPicture, picture[index + 3])
			picture[index], picture[index + 1], picture[index + 2], picture[index + 3] = nil, nil, nil, nil
		end
	end
	return newPicture
end

function image.flipHorizontal(picture)
	local newPicture = {}; newPicture.width = picture.width; newPicture.height = picture.height
	for j = 1, picture.height do
		for i = picture.width, 1, -1 do
			local index = convertCoordsToIndex(i, j, picture.width)
			table.insert(newPicture, picture[index]); table.insert(newPicture, picture[index + 1]); table.insert(newPicture, picture[index + 2]); table.insert(newPicture, picture[index + 3])
			picture[index], picture[index + 1], picture[index + 2], picture[index + 3] = nil, nil, nil, nil
		end
	end
	return newPicture
end

function image.rotate(picture, angle)
	local function rotateBy90(picture)
		local newPicture = {}; newPicture.width = picture.height; newPicture.height = picture.width
		for i = 1, picture.width do
			for j = picture.height, 1, -1 do
				local index = convertCoordsToIndex(i, j, picture.width)
				table.insert(newPicture, picture[index]); table.insert(newPicture, picture[index + 1]); table.insert(newPicture, picture[index + 2]); table.insert(newPicture, picture[index + 3])
				picture[index], picture[index + 1], picture[index + 2], picture[index + 3] = nil, nil, nil, nil
			end
		end
		return newPicture
	end

	local function rotateBy180(picture)
		local newPicture = {}; newPicture.width = picture.width; newPicture.height = picture.height
		for j = picture.height, 1, -1 do
				for i = picture.width, 1, -1 do
				local index = convertCoordsToIndex(i, j, picture.width)
				table.insert(newPicture, picture[index]); table.insert(newPicture, picture[index + 1]); table.insert(newPicture, picture[index + 2]); table.insert(newPicture, picture[index + 3])
				picture[index], picture[index + 1], picture[index + 2], picture[index + 3] = nil, nil, nil, nil
			end
		end
		return newPicture
	end

	local function rotateBy270(picture)
		local newPicture = {}; newPicture.width = picture.height; newPicture.height = picture.width
		for i = picture.width, 1, -1 do
			for j = 1, picture.height do
				local index = convertCoordsToIndex(i, j, picture.width)
				table.insert(newPicture, picture[index]); table.insert(newPicture, picture[index + 1]); table.insert(newPicture, picture[index + 2]); table.insert(newPicture, picture[index + 3])
				picture[index], picture[index + 1], picture[index + 2], picture[index + 3] = nil, nil, nil, nil
			end
		end
		return newPicture
	end

	if angle == 90 then
		return rotateBy90(picture)
	elseif angle == 180 then
		return rotateBy180(picture)
	elseif angle == 270 then
		return rotateBy270(picture)
	else
		error("Can't rotate image: angle must be 90, 180 or 270 degrees.")
	end
end

------------------------------------------ ������� ��� ������ � ������ -----------------------------------------------

function image.hueSaturationBrightness(picture, hue, saturation, brightness)
	local function calculateBrightnessChanges(color)
		local h, s, b = colorlib.HEXtoHSB(color)
		b = b + brightness; if b < 0 then b = 0 elseif b > 100 then b = 100 end
		s = s + saturation; if s < 0 then s = 0 elseif s > 100 then s = 100 end
		h = h + hue; if h < 0 then h = 0 elseif h > 360 then h = 360 end
		return colorlib.HSBtoHEX(h, s, b)
	end

	for i = 1, #picture, 4 do
		picture[i] = calculateBrightnessChanges(picture[i])
		picture[i + 1] = calculateBrightnessChanges(picture[i + 1])
	end

	return picture
end

function image.hue(picture, hue)
	return image.hueSaturationBrightness(picture, hue, 0, 0)
end

function image.saturation(picture, saturation)
	return image.hueSaturationBrightness(picture, 0, saturation, 0)
end

function image.brightness(picture, brightness)
	return image.hueSaturationBrightness(picture, 0, 0, brightness)
end

function image.blackAndWhite(picture)
	return image.hueSaturationBrightness(picture, 0, -100, 0)
end

function image.colorBalance(picture, r, g, b)
	local function calculateRGBChanges(color)
		local rr, gg, bb = colorlib.HEXtoRGB(color)
		rr = rr + r; gg = gg + g; bb = bb + b
		if rr < 0 then rr = 0 elseif rr > 255 then rr = 255 end
		if gg < 0 then gg = 0 elseif gg > 255 then gg = 255 end
		if bb < 0 then bb = 0 elseif bb > 255 then bb = 255 end
		return colorlib.RGBtoHEX(rr, gg, bb)
	end

	for i = 1, #picture, 4 do
		picture[i] = calculateRGBChanges(picture[i])
		picture[i + 1] = calculateRGBChanges(picture[i + 1])
	end

	return picture
end

function image.invert(picture)
	for i = 1, #picture, 4 do
		picture[i] = 0xffffff - picture[i]
		picture[i + 1] = 0xffffff - picture[i + 1]
	end
	return picture 
end

function image.photoFilter(picture, color, transparency)
	if transparency < 0 then transparency = 0 elseif transparency > 255 then transparency = 255 end
	for i = 1, #picture, 4 do
		picture[i] = colorlib.alphaBlend(picture[i], color, transparency)
		picture[i + 1] = colorlib.alphaBlend(picture[i + 1], color, transparency)
	end
	return picture
end

function image.replaceColor(picture, fromColor, toColor)
	for i = 1, #picture, 4 do
		if picture[i] == fromColor then picture[i] = toColor end
	end
	return picture
end

--������� �������� �� ������
function image.gaussianBlur(picture, radius, force)
	--������� ��� ��������� ������� ��������
	local function createConvolutionMatrix(maximumValue, matrixSize)
		local delta = maximumValue / matrixSize
		local matrix = {}
		for y = 1, matrixSize do
			for x = 1, matrixSize do
				local value = ((x - 1) * delta + (y - 1) * delta) / 2
				matrix[y] = matrix[y] or {}
				matrix[y][x] = value
			end
		end
		return matrix
	end

	--������� ��� ������������� ���������� ����� �� ��������� ������� �� ������ ���������� �������� �������
	local function spreadPixelToSpecifiedCoordinates(picture, xCoordinate, yCoordinate, matrixValue, startBackground, startForeground, startAlpha, startSymbol)
		local matrixBackground, matrixForeground, matrixAlpha, matrixSymbol = image.get(picture, xCoordinate, yCoordinate)

		if matrixBackground and matrixForeground then
			local newBackground = colorlib.alphaBlend(startBackground, matrixBackground, matrixValue)
			--��������� ��� ��� � ����, �������
			--�����, �����. ���� ������ ����� �������, �� �� ������ �� ��������� ���� ������, �����?
			--�� � ������� ��������� ��� ���� ����� �����, ������� ��������� ������ ���� �����������
			--������� ���� ��� ������� ������� �� ����������� �������� ����� ������, ������� ������ ����� ����
			--�.�. ����� �� ��� ��� � �����, �� ����� ������� ��� �����, ���
			local newForeground = matrixSymbol == " " and newBackground or colorlib.alphaBlend(startForeground, matrixForeground, matrixValue)

			image.set(picture, xCoordinate, yCoordinate, newBackground, newForeground, 0x00, matrixSymbol)
		end
	end

	--�������, �������������� ��������� ������� �� �������� �������� �� ������ �������
	local function spreadColorToOtherPixels(picture, xStart, yStart, matrix)
		--�������� ��������� ������ � �������
		local startBackground, startForeground, startAlpha, startSymbol = image.get(picture, xStart, yStart)
		local xCoordinate, yCoordinate
		--���������� �������
		for yMatrix = 1, #matrix do
			for xMatrix = 1, #matrix[yMatrix] do
				--���������� ��������� �������, �� ��� ��� ��� ���������-��?
				if not (xMatrix == 1 and yMatrix == 1) then
					--�������� ���������� ����� �������� � �����������
					--� � �������� ����������� �������
					xCoordinate, yCoordinate = xStart - xMatrix + 1, yStart - yMatrix + 1
					spreadPixelToSpecifiedCoordinates(picture, xCoordinate, yCoordinate, matrix[yMatrix][xMatrix], startBackground, startForeground, startAlpha, startSymbol)
					--��� ������ � ���������� ������� �������
					xCoordinate, yCoordinate = xStart + xMatrix - 1, yStart + yMatrix - 1
					spreadPixelToSpecifiedCoordinates(picture, xCoordinate, yCoordinate, matrix[yMatrix][xMatrix], startBackground, startForeground, startAlpha, startSymbol)
				end
			end
		end
	end

	--���������� �������
	local matrix = createConvolutionMatrix(force or 0x55, radius)
	--������������ ��� ������� �� �����������
	for y = 1, picture.height do
		for x = 1, picture.width do
			spreadColorToOtherPixels(picture, x, y, matrix)
		end
	end
	return picture
end

----------------------------------------- ��������� ��������� ����������� -------------------------------------------------------------------

--������������� ����������� � ��������� �������������, ������� ����� ���� ��������� � ���
--������, ���� �� ������� �������� � �������� ��������
function image.toString(picture)
	local stringedPicture = {}
	picture = convertImageColorsTo8Bit(picture)
	table.insert(stringedPicture, string.format("%02X", picture.width))
	table.insert(stringedPicture, string.format("%02X", picture.height))
	for i = 1, #picture, 4 do
		table.insert(stringedPicture, string.format("%02X", picture[i]))
		table.insert(stringedPicture, string.format("%02X", picture[i + 1]))
		table.insert(stringedPicture, string.format("%02X", picture[i + 2]))
		table.insert(stringedPicture, picture[i + 3])
	end
	picture = convertImageColorsTo24Bit(picture)
	return table.concat(stringedPicture)
end

--�������� ����������� �� ��������� �������������, ��������� �����
function image.fromString(stringedPicture)
	local picture = {}
	local subIndex = 1
	picture.width = tonumber("0x" .. unicode.sub(stringedPicture, subIndex, subIndex + 1)); subIndex = subIndex + 2
	picture.height = tonumber("0x" .. unicode.sub(stringedPicture, subIndex, subIndex + 1)); subIndex = subIndex + 2
	
	for pixel = 1, picture.width * picture.height do
		table.insert(picture, tonumber("0x" .. unicode.sub(stringedPicture, subIndex, subIndex + 1))); subIndex = subIndex + 2
		table.insert(picture, tonumber("0x" .. unicode.sub(stringedPicture, subIndex, subIndex + 1))); subIndex = subIndex + 2
		table.insert(picture, tonumber("0x" .. unicode.sub(stringedPicture, subIndex, subIndex + 1))); subIndex = subIndex + 2
		table.insert(picture, unicode.sub(stringedPicture, subIndex, subIndex)); subIndex = subIndex + 1
	end
	picture = convertImageColorsTo24Bit(picture)
	return picture
end

----------------------------------------- �������� ������� ��������� -------------------------------------------------------------------

--��������� ����������� ������ ��������������� �������
function image.save(path, picture, encodingMethod)
	encodingMethod = encodingMethod or 4
	--������� ����� ��� ����, ���� �� ���
	fs.makeDirectory(fs.path(path))
	--�������� ������ ���������� �����
	local fileFormat = getFileFormat(path)

	--��������� ������������ ������� �����
	if fileFormat == constants.compressedFileFormat then
		--������������ ��������
		picture = image.optimize(picture)
		--��������� ����
		local file = io.open(path, "w")
		--���������� ���������
		writeSignature(file)
		--����������� � ����������
		if encodingMethod == 0 or string.lower(encodingMethod) == "raw" then
			file:write(string.char(encodingMethod))
			saveRaw(file, picture)
		elseif encodingMethod == 1 or string.lower(encodingMethod) == "ocif1" then
			file:write(string.char(encodingMethod))
			saveOCIF1(file, picture)
		elseif encodingMethod == 2 or string.lower(encodingMethod) == "ocif2" then
			file:write(string.char(encodingMethod))
			saveOCIF2(file, picture)
		elseif encodingMethod == 3 or string.lower(encodingMethod) == "ocif3" then
			error("Saving in encoding method 3 is deprecated and no longer supported. Use method 4 instead of it.")
		elseif encodingMethod == 4 or string.lower(encodingMethod) == "ocif4" then
			file:write(string.char(encodingMethod))
			picture = convertImageColorsTo8Bit(picture)
			saveOCIF2(file, picture, true)
			picture = convertImageColorsTo24Bit(picture)
		elseif encodingMethod == 6 then
			file:close()
			file = io.open(path, "w")
			file:write(image.toString(picture))
			file:close()
		else
			file:close()
			error("Unsupported encoding method.\n")
		end
	else
		file:close()
		error("Unsupported file format.\n")
	end
end

--��������� ����������� ������ ��������������� �������
function image.load(path)
	--������ ������, ���� ������ ����� �� ����������
	if not fs.exists(path) then error("File \""..path.."\" does not exists.\n") end
	--�������� ������ ���������� �����
	local fileFormat = getFileFormat(path)
	--��������� ������������ ������� �����
	if fileFormat == constants.compressedFileFormat then
		local file = io.open(path, "rb")
		--������ ��������� �����
		readSignature(file)
		--������ ����� ��������� �����������
		local encodingMethod = string.byte(file:read(1))
		--������ ����� � ����������� �� ������
		--print("�������� ���� ���� " .. encodingMethod)
		if encodingMethod == 0 then
			return image.optimize(loadRaw(file))
		elseif encodingMethod == 1 then
			return image.optimize(loadOCIF1(file))
		elseif encodingMethod == 2 then
			return image.optimize(loadOCIF2(file))
		elseif encodingMethod == 3 then
			return image.optimize(loadOCIF2(file, true))
		elseif encodingMethod == 4 then
			return image.optimize(loadOCIF2(file, true, true))
		else
			file:close()
			error("Unsupported encoding method: " .. encodingMethod .. "\n")
		end
	--��������� ���-�������
	elseif fileFormat == constants.pngFileFormat then
		return image.loadPng(path)
	else
		error("Unsupported file format: " .. fileFormat .. "\n")
	end
end

--��������� ����������� ���� 3 (��������� � ����� ��. ����� �����)
function image.draw(x, y, picture)
	--������������ � ��������� �����������
	picture = image.convertToGroupedImage(picture)
	--��� ��� ������
	x, y = x - 1, y - 1

	local xPos, yPos, currentBackground
	for alpha in pairs(picture) do
		for symbol in pairs(picture[alpha]) do
			for foreground in pairs(picture[alpha][symbol]) do
				if component.gpu.getForeground ~= foreground then component.gpu.setForeground(foreground) end
				for background in pairs(picture[alpha][symbol][foreground]) do
					if component.gpu.getBackground ~= background then component.gpu.setBackground(background) end
					currentBackground = background

					for yArray in pairs(picture[alpha][symbol][foreground][background]) do
						for xArray = 1, #picture[alpha][symbol][foreground][background][yArray] do
							xPos, yPos = x + picture[alpha][symbol][foreground][background][yArray][xArray], y + yArray
							
							--���� ����� �������, �� ��� �� ������ ���������
							if (alpha > 0x00 and alpha < 0xFF) or (alpha == 0xFF and symbol ~= " ")then
								_, _, currentBackground = component.gpu.get(xPos, yPos)
								currentBackground = colorlib.alphaBlend(currentBackground, background, alpha)
								component.gpu.setBackground(currentBackground)

								component.gpu.set(xPos, yPos, symbol)

							elseif alpha == 0x00 then
								if currentBackground ~= background then
									currentBackground = background
									component.gpu.setBackground(currentBackground)
								end

								component.gpu.set(xPos, yPos, symbol)
							end
							--ecs.wait()
						end
					end
				end
			end
		end
	end
end

local function createSaveAndLoadFiles()
	ecs.prepareToExit()
	ecs.error("������/�������� �����������")
	-- local cyka = image.load("MineOS/System/OS/Icons/Love.pic")
	local cyka = image.createImage(4, 4)
	ecs.error("����� ����������� �����������")
	image.draw(2, 2, cyka)
	ecs.error("�������� ��� � 4 ��������")
	image.save("0.pic", cyka, 0)
	image.save("1.pic", cyka, 1)
	image.save("4.pic", cyka, 4)
	ecs.prepareToExit()
	ecs.error("�������� ��� 4 ������� � ����� ��")
	local cyka0 = image.load("0.pic")
	image.draw(2, 2, cyka0)
	local cyka1 = image.load("1.pic")
	image.draw(10, 2, cyka1)
	local cyka4 = image.load("4.pic")
	image.draw(34, 2, cyka4)
end

------------------------------------------------------------------------------------------------------------------------

-- local picture = image.load("MineOS/System/OS/Icons/Love.pic")
-- buffer.clear(0xFF8888)
-- buffer.draw(true)

-- buffer.image(1, 1, picture)
-- buffer.draw()

-- local newPicture = transform(picture, 0.5, 2)

-- local columnArray = {}; for i = 1, picture.height do table.insert(columnArray, 0xFFFFFF); table.insert(columnArray, 0x000000); table.insert(columnArray, 0x00); table.insert(columnArray, " ") end
-- local rowArray = {}; for i = 1, picture.width do table.insert(rowArray, 0xFFFFFF); table.insert(rowArray, 0x000000); table.insert(rowArray, 0x00); table.insert(rowArray, " ") end
-- local rowArray = image.getRow(picture, 2)
-- picture = image.insertColumn(picture, 1, columnArray)
-- picture = image.insertRow(picture, 3, rowArray)
-- picture = image.removeColumn(picture, 1)

-- buffer.image(1, 19, picture)
-- buffer.image(1, 19, newPicture)
-- buffer.draw()

------------------------------------------------------------------------------------------------------------------------

return image