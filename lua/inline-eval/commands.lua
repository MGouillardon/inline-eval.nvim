local config = require("inline-eval.config")
local state = require("inline-eval.state")
local eval = require("inline-eval.eval")

local M = {}

function M.setup()
	vim.api.nvim_create_user_command("InlineEvalStart", function()
		M.start()
	end, {})
	vim.api.nvim_create_user_command("InlineEvalStop", M.stop, {})
end

function M.start()
	local current_config = config.get()
	local current_ft = vim.bo.filetype

	if not vim.tbl_contains(current_config.supported_filetypes, current_ft) then
		vim.notify(string.format("Unsupported filetype: %s", current_ft), vim.log.levels.WARN)
		return
	end

	M.stop()
	state.set_buffer(vim.api.nvim_get_current_buf())
	state.set_running(true)

	local timer_id = vim.fn.timer_start(current_config.update_interval, function()
		eval.evaluate_buffer()
	end, { ["repeat"] = -1 })

	state.set_timer(timer_id)

	local augroup = vim.api.nvim_create_augroup("InlineEval", { clear = true })
	vim.api.nvim_create_autocmd("BufLeave", {
		group = augroup,
		buffer = state.get().current_buf,
		callback = M.stop,
	})
end

function M.stop()
	local current_state = state.get()
	if not current_state then
		return
	end

	eval.cleanup()

	if current_state.current_buf and vim.api.nvim_buf_is_valid(current_state.current_buf) then
		vim.api.nvim_buf_clear_namespace(current_state.current_buf, current_state.namespace, 0, -1)
	end

	state.reset()
end

return M
