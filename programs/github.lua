local args = {...}
local internet = require("internet")
local fs = require("filesystem")
local seri = require("serialization")
local shell = require("shell")

local repoURL = "https://raw.githubusercontent.com/k0f3st/OpenComputers/master/"

local function getFile(url, path)
	local sContent = ""

	print(" ")
	print("[git] Подключаюсь к репозиторию GitHub...")

	local result, response = pcall(internet.request, url)
	if not result then
		return nil
	end

	print(" ")

	if result == "" or result == " " or result == "\n" then info("[git] Файл пуст или неверная ссылка."); return end

	if fs.exists(path) then
		info("[git] Файл уже существует и будет перезаписан.")
		fs.remove(path)
	end
	fs.makeDirectory(fs.path(path))
	local file = io.open(path, "w")

	for chunk in response do
		file:write(chunk)
		sContent = sContent .. chunk
	end

	file:close()
	print("[git] Файл загружен и находится в /"..path)
	print(" ")
	return sContent
end

if args[1] == "get" then
	getFile(repoURL .. args[2], args[3])
end