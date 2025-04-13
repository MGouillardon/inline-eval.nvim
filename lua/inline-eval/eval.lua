local config = require("inline-eval.config")
local ui = require("inline-eval.ui")

local M = {}

local state = {
	last_code = "",
	temp_file = vim.fn.tempname(),
	job_id = nil,
}

local function get_interpreter_cmd()
	local filetype = vim.bo.filetype
	if filetype == "php" then
		return config.get().php_path
	else
		return config.get().node_path
	end
end

local function prepare_php_code(code)
	if not code:match("^%s*<%?php") then
		code = "<?php\n" .. code
	end
	return code
end

function M.evaluate_buffer()
	local code = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	local filetype = vim.bo.filetype

	if state.last_code == code then
		return
	end
	state.last_code = code

	if state.job_id then
		vim.fn.jobstop(state.job_id)
	end

	ui.create_float()

	-- Update the file extension based on the filetype
	local file_ext = filetype == "php" and ".php" or ".js"
	local temp_file = state.temp_file .. file_ext

	-- Prepare code for PHP if needed
	if filetype == "php" then
		code = prepare_php_code(code)
	end

	local f = io.open(temp_file, "w")
	if not f then
		vim.notify("Failed to write to temporary file", vim.log.levels.ERROR)
		return
	end
	f:write(code)
	f:close()

	local interpreter_cmd = get_interpreter_cmd()
	local output_lines = {}

	state.job_id = vim.fn.jobstart(string.format("%s %s", interpreter_cmd, vim.fn.shellescape(temp_file)), {
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
	os.remove(state.temp_file .. ".php")
	os.remove(state.temp_file .. ".js")
end

return M
