local config = require("inline-eval.config")
local eval = require("inline-eval.eval")
local state = require("inline-eval.state")

local M = {}

local augroup = vim.api.nvim_create_augroup("InlineEvalGroup", { clear = true })

function M.setup()
	vim.api.nvim_create_user_command("InlineEvalStart", M.start, {})
	vim.api.nvim_create_user_command("InlineEvalStop", M.stop, {})
end

function M.start()
	local current_ft = vim.bo.filetype
	if not vim.tbl_contains(config.get().supported_filetypes, current_ft) then
		vim.notify(string.format("Unsupported filetype: %s", current_ft), vim.log.levels.WARN)
		return
	end

	state.start()

	local timer = nil
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = augroup,
		buffer = vim.api.nvim_get_current_buf(),
		callback = function()
			if timer then
				vim.fn.timer_stop(timer)
			end
			timer = vim.fn.timer_start(config.get().update_interval, function()
				eval.evaluate_buffer()
			end)
		end,
	})

	eval.evaluate_buffer()
end

function M.stop()
	vim.api.nvim_clear_autocmds({ group = augroup })
	state.stop()
	eval.close()
end

return M
