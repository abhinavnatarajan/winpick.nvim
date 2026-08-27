local api = vim.api

local alphabet = {}
for byte = string.byte("A"), string.byte("Z") do
	table.insert(alphabet, string.char(byte))
end

for byte = string.byte("0"), string.byte("9") do
	table.insert(alphabet, string.char(byte))
end

--- Shows label and buffer name, if available. Else, show only the label.
--- @param label string: Label to be shown alongside the buffer name.
--- @param winid integer: ID of the selected window.
--- @param bufnr integer: ID of the selected window's buffer.
--- @return string: The label as is.
local function default_label_formatter(label, winid, bufnr)
	local buf_name = api.nvim_buf_get_name(bufnr)

	if buf_name:len() == 0 then
		return label
	end

	return string.format("%s: %s", label, vim.fn.fnamemodify(buf_name, ":~:."))
end

local M = {}

--- @class Config
--- @field border string
--- @field prompt string
--- @field filter (fun(winid: integer): boolean) | nil
--- @field format_label fun(label: string, winid: integer, bufnr: integer): string
--- @field chars string[]

--- Builds the default options.
--- @return Config: The defaults.
function M.defaults()
	return {
		border = "double",
		prompt = "Pick a window: ",
		format_label = default_label_formatter,
		filter = nil,
		chars = nil,
	}
end

--- Maps a table index to an ASCII character starting from A (1 is A, 2 is B, and so on).
--- @param idx integer: Index of a table.
--- @return string: The respective ASCII character.
function M.format_index(idx)
	return string.char(idx + 64)
end

--- Returns the list of labels that will sequentially be used for visual cues.
--- @param custom_chars string[]: List of characters that will serve as labels.
--- @return string[]: Alphabet containing user-provided characters plus a complementary alphabet.
function M.resolve_chars(custom_chars)
	if vim.tbl_isempty(custom_chars) then
		return alphabet
	end

	local chars = {}
	local added = {}

	for _, charlist in ipairs({ custom_chars, alphabet }) do
		for _, char in ipairs(charlist) do
			local val = char:upper()

			if not added[val] then
				added[val] = true
				table.insert(chars, val)
			end
		end
	end

	return chars
end

--- Shows visual cues for each window.
--- @param targets table<string, integer>: Map of labels and their respective window ids.
--- @param opts Config: Options for showing visual cues.
--- @return table: List of visual cues that were opened.
function M.show_cues(targets, opts)
	-- Reset view.
	local cues = {}
	for label, win in pairs(targets) do
		local bufnr = api.nvim_create_buf(false, true)
		local winbufnr = api.nvim_win_get_buf(win)

		if opts.format_label then
			label = opts.format_label(label, win, winbufnr)
		end

		local padding = string.rep(" ", 4)
		local fill = string.rep(" ", label:len())

		local lines = {
			padding .. fill .. padding,
			padding .. label .. padding,
			padding .. fill .. padding,
		}

		api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)

		local width = label:len() + padding:len() * 2
		local height = 3

		local center_x = api.nvim_win_get_width(win) / 2
		local center_y = api.nvim_win_get_height(win) / 2

		local cue_winid = api.nvim_open_win(bufnr, false, {
			relative = "win",
			win = win,
			width = width,
			height = height,
			col = math.floor(center_x - width / 2),
			row = math.floor(center_y - height / 2),
			focusable = false,
			style = "minimal",
			border = opts.border,
		})

		vim.bo[bufnr].buftype = "nofile"

		table.insert(cues, cue_winid)
	end

	return cues
end

--- Closes all windows for visual cues.
function M.hide_cues(cues)
	for _, win in pairs(cues) do
		-- We use pcall here because we dont' want to throw an error just
		-- because we couldn't close a window that was probably already closed!
		pcall(api.nvim_win_close, win, true)
	end
end

return M
