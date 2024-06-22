-- launch searches from within mpv
--
-- actions: copy metadata to clipboard / dump metadata to file / search
--
-- flow: keybind (e.g. '?') -> show metadata + options -> navigate up/down ->
-- enter -> xdg-open

-- https://mpv.io/manual/stable/#mp-functions

-- https://mpv.io/manual/stable/#list-of-events
-- mp.register_event("file-loaded", on_file_loaded)
-- mp.register_event("shutdown", on_file_loaded)

local mp = require("mp")

local function esc(s)
	return string.gsub(s, "'", "'\\''")
end

local function search_discogs(query)
	local search_url = "https://www.discogs.com/search/?type=all&q=" .. query
	-- local cmd = "xdg-open '" .. esc(search_url) .. "'"
	local cmd = string.format("xdg-open '%s'", search_url)
	print(cmd)
	os.execute(cmd)
end

local function search()
	-- detect if playing url or file

	-- https://mpv.io/manual/stable/#property-expansion
	-- https://mpv.io/manual/stable/#property-list
	local name = mp.get_property("filename")
	-- mp.osd_message(name, 2)
	search_discogs(name)
end

mp.add_key_binding("?", "menu", search)
