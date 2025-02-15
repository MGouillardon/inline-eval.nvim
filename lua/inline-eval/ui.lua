local config = require("inline-eval.config")
local state = require("inline-eval.state")

local M = {}

function M.update_results(results)
	local current_state = state.get()
	local current_config = config.get()

	if not (current_state.current_buf and vim.api.nvim_buf_is_valid(current_state.current_buf)) then
		return
	end

	vim.api.nvim_buf_clear_namespace(current_state.current_buf, current_state.namespace, 0, -1)

	for _, result in ipairs(results) do
		if result.line then
			local output = result.output
			if result.isError and result.stack then
				local first_stack_line = vim.split(result.stack, "\n")[1]
				output = output .. " | " .. first_stack_line
			end

			if #output > current_config.max_output_length then
				output = output:sub(1, current_config.max_output_length) .. "..."
			end

			local hl_group = result.isError and "ErrorMsg" or current_config.highlight_group
			vim.api.nvim_buf_set_extmark(current_state.current_buf, current_state.namespace, result.line - 1, 0, {
				virt_text = { { " => " .. output, hl_group } },
				virt_text_pos = "eol",
				hl_mode = "combine",
				priority = result.isError and 200 or 100,
			})
		end
	end
end

return M
