-- launch searches from within mpv
--
-- actions: copy link to clipboard (only if url) / copy metadata to clipboard /
-- dump metadata to file / search (menu)
--
-- flow: keybind (e.g. '?') -> show metadata + options -> navigate up/down ->
-- enter -> xdg-open

-- https://mpv.io/manual/stable/#mp-functions

-- https://mpv.io/manual/stable/#list-of-events
-- mp.register_event("file-loaded", on_file_loaded)
-- mp.register_event("shutdown", on_file_loaded)

local mp = require("mp")
-- local assdraw = require("mp.assdraw")

SEARCH_URLS = {
	discogs = "https://www.discogs.com/search/?type=all&q=",
	spotify = "https://open.spotify.com/search/",
}

local function keys(tab)
	-- https://stackoverflow.com/a/12674376
	local _keys = {}
	local n = 0

	for k, _ in pairs(tab) do
		n = n + 1
		_keys[n] = k
	end

	table.sort(_keys)

	return _keys
end

local function sanitize(s)
	return string.gsub(
		s,
		"'",
		-- "'\\''"
		""
	)
end

-- urlencode https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99

local function search_prompt()
	local input = require("mp.input")

	-- -- [search] get function: 0x74d846d57d08
	-- -- [search] log function: 0x74d846d52f28
	-- -- [search] log_error function: 0x74d846d52ef0
	-- -- [search] set_log function: 0x74d846d52c50
	-- -- [search] terminate function: 0x74d846d55a08
	-- for k, v in pairs(input) do
	-- 	print(k, v)
	-- end

	-- -- TODO: why is input.select missing??
	-- -- attempt to call field 'select' (a nil value)
	-- input.select({
	-- 	prompt = "Select: ",
	-- 	items = keys(SEARCH_URLS),
	-- 	default_item = 1,
	-- 	submit = function(idx)
	-- 		mp.commandv("print-text", SEARCH_URLS[idx])
	-- 	end,
	-- })

	-- works in both osd and console!
	input.get({
		prompt = "Select:",
		-- TODO: edited
		-- TODO: increase font size (only needed for osd)
		opened = function()
			input.set_log(keys(SEARCH_URLS))
		end,
		submit = function(typed)
			for k, _ in pairs(SEARCH_URLS) do
				if string.find(k, "^" .. typed) ~= nil then
					local query = get_metadata()
					search(k, query, true)
					break
				end
			end
			input.terminate()
		end,
	})
end

function search(source, query, verbose)
	local search_url = SEARCH_URLS[source] .. sanitize(query)
	local cmd = string.format("xdg-open '%s'", search_url)

	mp.osd_message(query, 2)

	if verbose then
		print(cmd)
	end

	-- see also: commandv run
	os.execute(cmd)
end

local function copy_link()
	local path = mp.get_property_native("path")

	if string.find(path, "^http") == nil then
		return
	end

	local pos = mp.get_property_native("time-pos")
	print(string.format("%s&t=%d", path, pos))
	-- TODO: xclip
	mp.osd_message("Copied link", 2)
end

function get_metadata() -- {{{
	local props = {

		-- https://mpv.io/manual/stable/#property-expansion
		-- https://mpv.io/manual/stable/#property-list

		"filename/no-ext",
		"media-title", -- metadata/by-key/title
		"path",
		"time-pos", -- s.ms
		-- "filename",
		-- "playlist", -- table
	}

	for _, prop in pairs(props) do
		print(prop .. ":" .. mp.get_property_native(prop))
	end

	local path = mp.get_property_native("path")
	if string.find(path, "^http") == nil then
		-- generalise metadata extraction, depending on file/url
		local meta = mp.get_property_native("metadata")
		local query = table.concat({ meta["album"], meta["artist"] }, " ")
		return query
	else
		return mp.get_property_native("media-title")
	end
end -- }}}

mp.add_key_binding("/", "menu", search_prompt)
mp.add_key_binding("y", "copy_link", copy_link)
