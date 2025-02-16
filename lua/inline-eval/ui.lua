local config = require("inline-eval.config")

local M = {}

local state = {
	buf = nil,
	win = nil,
}

local function setup_buffer(buf)
	vim.bo[buf].bufhidden = "hide"
	vim.bo[buf].filetype = "javascript"
	vim.bo[buf].modifiable = false

	if config.get().output.use_treesitter then
		local ok, _ = pcall(require, "nvim-treesitter.parsers")
		if ok then
			vim.treesitter.start(buf, "javascript")
		end
	end
end

function M.create_float()
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		return
	end

	state.buf = vim.api.nvim_create_buf(false, true)
	setup_buffer(state.buf)

	local width = math.floor(vim.o.columns * 0.3)
	local opts = {
		relative = "editor",
		row = 2,
		col = vim.o.columns - width - 1,
		width = width,
		height = vim.o.lines - 8,
		style = "minimal",
		border = "rounded",
		title = " Output ",
		title_pos = "center",
	}

	if not state.win or not vim.api.nvim_win_is_valid(state.win) then
		state.win = vim.api.nvim_open_win(state.buf, false, opts)
		vim.wo[state.win].wrap = true
		vim.wo[state.win].winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
	else
		vim.api.nvim_win_set_config(state.win, opts)
	end
end

function M.update_output(output_lines)
	if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
		return
	end

	vim.bo[state.buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, output_lines)
	vim.bo[state.buf].modifiable = false
end

function M.close()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
		state.win = nil
	end
	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		vim.api.nvim_buf_delete(state.buf, { force = true })
		state.buf = nil
	end
end

return M
