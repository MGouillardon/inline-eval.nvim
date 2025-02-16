local config = require("inline-eval.config")
local ui = require("inline-eval.ui")

local M = {}

local state = {
	last_code = "",
	temp_file = vim.fn.tempname(),
	job_id = nil,
}

function M.evaluate_buffer()
	local code = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")

	if state.last_code == code then
		return
	end
	state.last_code = code

	if state.job_id then
		vim.fn.jobstop(state.job_id)
	end

	ui.create_float()

	local f = io.open(state.temp_file, "w")
	if not f then
		vim.notify("Failed to write to temporary file", vim.log.levels.ERROR)
		return
	end
	f:write(code)
	f:close()

	local output_lines = {}
	state.job_id =
		vim.fn.jobstart(string.format("%s %s", config.get().node_path, vim.fn.shellescape(state.temp_file)), {
			on_stdout = function(_, data)
				if data then
					vim.list_extend(
						output_lines,
						vim.tbl_filter(function(line)
							return line ~= ""
						end, data)
					)
				end
			end,
			on_stderr = function(_, data)
				if data then
					vim.list_extend(
						output_lines,
						vim.tbl_filter(function(line)
							return line ~= ""
						end, data)
					)
				end
			end,
			on_exit = function()
				vim.schedule(function()
					ui.update_output(output_lines)
				end)
			end,
		})
end

function M.close()
	if state.job_id then
		vim.fn.jobstop(state.job_id)
		state.job_id = nil
	end
	ui.close()
	os.remove(state.temp_file)
end

return M
