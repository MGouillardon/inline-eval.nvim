local M = {}

M.defaults = {
	update_interval = 300,
	supported_filetypes = {
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
	},
	highlight_group = "Comment",
	node_path = "node",
	max_output_length = 100,
}

local config = M.defaults

function M.validate_config(opts)
	local valid_config = true
	local errors = {}

	if opts.update_interval and type(opts.update_interval) ~= "number" then
		valid_config = false
		table.insert(errors, "update_interval must be a number")
	end

	if opts.max_output_length and type(opts.max_output_length) ~= "number" then
		valid_config = false
		table.insert(errors, "max_output_length must be a number")
	end

	if opts.node_path and type(opts.node_path) ~= "string" then
		valid_config = false
		table.insert(errors, "node_path must be a string")
	end

	return valid_config, table.concat(errors, "\n")
end

function M.setup(opts)
	local valid, errors = M.validate_config(opts or {})
	if not valid then
		vim.notify("Invalid configuration:\n" .. errors, vim.log.levels.ERROR)
		return
	end

	config = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

function M.get()
	return config
end

return M
