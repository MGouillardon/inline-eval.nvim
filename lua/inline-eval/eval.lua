local state = require("inline-eval.state")
local ui = require("inline-eval.ui")
local config = require("inline-eval.config")

local M = {}

M.debounce_timer = nil

function M.create_temp_file(code)
	local temp_file = os.tmpname()
	local f = io.open(temp_file, "w")
	if not f then
		vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
		return nil
	end

	local lines = vim.split(code, "\n")
	local line_map = {}
	for i, line in ipairs(lines) do
		if line:match("console[.]log") then
			line_map[#line_map + 1] = i
		end
	end

	local wrapped_code = [[
        const logs = [];
        let logIndex = 0;
        const lineMap = ]] .. vim.json.encode(line_map) .. [[;
        
        const formatValue = (value) => {
            if (value === null) return 'null';
            if (value === undefined) return 'undefined';
            try {
                if (typeof value === 'object') {
                    if (value instanceof Date) {
                        return value.toISOString();
                    }
                    if (value instanceof Error) {
                        return `${value.name}: ${value.message}`;
                    }
                    if (value instanceof RegExp) {
                        return value.toString();
                    }
                    return JSON.stringify(value, replacer);
                }
                if (typeof value === 'function') {
                    return value.toString().slice(0, 50);
                }
                return String(value);
            } catch (e) {
                return '[Complex Object: ' + e.message + ']';
            }
        };

        const replacer = (key, value) => {
            if (value instanceof Date) return value.toISOString();
            if (value instanceof Function) return value.toString().slice(0, 50);
            if (value instanceof RegExp) return value.toString();
            if (value instanceof Error) return `${value.name}: ${value.message}`;
            return value;
        };

        const originalLog = console.log;
        const originalError = console.error;

        console.log = (...args) => {
            try {
                const output = args.map(formatValue).join(' ');
                const line = lineMap[logIndex++] || 1;
                logs.push({ line, output });
                originalLog(...args);
            } catch (error) {
                logs.push({ 
                    line: 1,
                    output: `[Error formatting output: ${error.message}]`,
                    isError: true 
                });
            }
        };

        // Main execution
        try {
            ]] .. code .. [[
        } catch (error) {
            const lineMatch = error.stack?.match(/:(\d+):\d+\)/);
            const errorLine = lineMatch ? parseInt(lineMatch[1], 10) : 1;
            
            logs.push({ 
                line: errorLine,
                output: `${error.name}: ${error.message}`,
                isError: true,
                stack: error.stack
            });
        } finally {
            // Always output logs
            originalError(JSON.stringify(logs));
        }
    ]]

	f:write(wrapped_code)
	f:close()
	return temp_file
end

function M.cleanup()
	if M.debounce_timer then
		vim.fn.timer_stop(M.debounce_timer)
		M.debounce_timer = nil
	end
end

function M.evaluate_buffer()
	local current_state = state.get()
	if not current_state.is_running or not current_state.current_buf then
		return
	end

	if M.debounce_timer then
		vim.fn.timer_stop(M.debounce_timer)
		M.debounce_timer = nil
	end

	if not vim.api.nvim_buf_is_valid(current_state.current_buf) then
		state.reset()
		return
	end

	M.debounce_timer = vim.fn.timer_start(150, function()
		if not vim.api.nvim_buf_is_valid(current_state.current_buf) then
			if M.debounce_timer then
				vim.fn.timer_stop(M.debounce_timer)
				M.debounce_timer = nil
			end
			return
		end

		local lines = vim.api.nvim_buf_get_lines(current_state.current_buf, 0, -1, false)
		local code = table.concat(lines, "\n")

		local cache_key = vim.fn.sha256(code)
		if M.last_cache_key == cache_key then
			return
		end
		M.last_cache_key = cache_key

		local temp_file = M.create_temp_file(code)
		if not temp_file then
			return
		end

		local stdout = ""

		local job_id = vim.fn.jobstart(string.format('%s "%s"', config.get().node_path, temp_file), {
			on_stdout = function(_, data)
				if data then
					stdout = stdout .. table.concat(data, "\n")
				end
			end,
			on_stderr = function(_, data)
				if data and #data > 1 then -- Ignore les lignes vides
					local success, decoded = pcall(vim.json.decode, data[1])
					if success and decoded then
						vim.schedule(function()
							ui.update_results(decoded)
						end)
					end
				end
			end,
			on_exit = function(_, exit_code)
				os.remove(temp_file)
			end,
		})

		vim.defer_fn(function()
			if vim.fn.jobwait({ job_id }, 0)[1] == -1 then
				vim.fn.jobstop(job_id)
				vim.notify("Evaluation timed out", vim.log.levels.WARN)
			end
		end, 3000)
	end)
end

return M
