-- external dependencies
local http = require("socket.http")
local JSON = require("JSON")

-- internal dependencies
local config = require("config")

local utils = {}

COLORS = {
	reset = "\27[0m",
	green = "\27[32m",
	red = "\27[31m",
}

-- determine the linux session type
local function getSessionType()
	local sessionType = os.getenv("XDG_SESSION_TYPE")
	if sessionType == "wayland" then
		return "wayland"
	elseif sessionType == "x11" then
		return "x11"
	else
		return nil
	end
end

local function executeCommand(command)
	local success, error = os.execute(command)
	if success then
		print("copied to clipboard!")
	elseif error then
		print("Error:", error)
	end
end

local function copyToClipboard(text)
	local sessionType = getSessionType()
	local command

	if sessionType == "x11" then
		command = string.format(config.clipboard_command_x11, text)
	else
		command = string.format(config.clipboard_command_wayland, text)
	end
	executeCommand(command)
end

-- convert size to human readable format
local function convertSize(value)
	local MiB = math.floor(value / 1000000)
	if MiB > 1000 then
		return (string.format("%.2f", MiB / 1000) .. " GB")
	else
		return MiB .. " MB"
	end
end

-- read input using protected call
function utils.readInput()
	local success, input = pcall(io.read)

	if success then
		return input
	else
		print("\ncancled!")
		return nil
	end
end

-- format the text on screen
local function formatInfo(color, label, value)
	local coloredText = color .. label .. COLORS.reset
	if value then
		return "\n\n" .. coloredText .. " " .. value
	end
	return coloredText
end

-- api call
function utils.fetch(url)
	local response, status_code, _, _ = http.request(url)
	if status_code == 200 then
		return response
	else
		print("Request failed with status code: " .. status_code)
	end
end

function utils.fetchTorrent(url)
	local requestUrl = config.baseUrl .. "" .. url
	return utils.fetch(requestUrl)
end

function utils.torrentOptions(res)
	if res == nil then
		return
	end

	local r = JSON:decode(res)

	print("\nS No.", "\tSE", "\tLE", "\tDate", "\t\tSize", "\t\tName\n")

	local function printTorrentTable(index, value)
		print(string.rep("-", 150))
		print(
			index,
			"\t" .. "" .. formatInfo(COLORS.green, value.seeders),
			"\t" .. "" .. formatInfo(COLORS.red, value.leechers),
			"\t" .. "" .. os.date("%d-%b-%Y", value.added),
			"\t" .. "" .. convertSize(value.size),
			"\t" .. "" .. value.name
		)
	end

	if config.torrent_list.reverse then
		for i = #r, 1, -1 do
			local value = r[i]
			printTorrentTable(i, value)
		end
	else
		for i, value in ipairs(r) do
			printTorrentTable(i, value)
		end
	end

	io.write("\nEnter the number to see details\n")

	local index = utils.readInput()

	if index ~= nil then
		local i = tonumber(index)
		local selectedTorrent = r[i]

		local combined = ""

		combined = combined .. "" .. formatInfo(COLORS.green, "Name:", selectedTorrent["name"])
		combined = combined .. "" .. formatInfo(COLORS.green, "Info Hash:", selectedTorrent["info_hash"])
		combined = combined .. "" .. formatInfo(COLORS.green, "Username:", selectedTorrent["username"])
		combined = combined .. "" .. formatInfo(COLORS.green, "Files:", selectedTorrent["num_files"])
		combined = combined .. "" .. formatInfo(COLORS.green, "Seeders:", selectedTorrent["seeders"])
		combined = combined .. "" .. formatInfo(COLORS.green, "Leechers:", selectedTorrent["leechers"])
		combined = combined .. "" .. formatInfo(COLORS.green, "Date:", os.date("!%c", selectedTorrent["added"]))
		combined = combined .. "" .. formatInfo(COLORS.green, "Size:", convertSize(selectedTorrent["size"]))

		if #selectedTorrent["imdb"] > 0 then
			combined = combined
				.. ""
				.. formatInfo(COLORS.green, "IMDB:", "https://www.imdb.com/title/" .. "" .. selectedTorrent["imdb"])
		end

		print(formatInfo(COLORS.red, "\n[[ Info ]]"))
		print(combined)

		-- create magnet link
		local magnet = "magnet:?xt=urn:btih:" .. selectedTorrent.info_hash .. "&dn=" .. selectedTorrent.info_hash

		-- fetch trackers from external url
		local trackers = utils.fetch(config.trackers_url)
		local tracker_list = {}

		-- Split the response by lines and insert each line into the table
		for line in trackers:gmatch("[^\r\n]+") do
			table.insert(tracker_list, line)
		end

		for _, tracker in ipairs(tracker_list) do
			magnet = magnet .. "&tr=" .. tracker
		end

		print(formatInfo(COLORS.red, "\n[[ Actions ]]\n"))
		print("1. Download using Transmission Cli\t 2. Copy Magent Link\n")

		local option = tonumber(utils.readInput())
		if option == 1 then
			local client = "transmission-cli"
			local isInstalled = string.format("which %s", client) ~= client .. " not found"

			if isInstalled then
				os.execute(client .. " " .. magnet)
			else
				print(client .. " is not installed")
			end
		elseif option == 2 then
			copyToClipboard(magnet)
		end
	end
end

return utils
