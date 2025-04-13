local M = {}

M.defaults = {
	update_interval = 300,
	supported_filetypes = {
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
		"php",
	},
	node_path = "deno",
	php_path = "php",
	live_eval = {
		enabled = true,
		min_lines = 1,
		max_lines = 100,
		debounce = true,
	},
	output = {
		use_treesitter = true,
	},
}

local config = M.defaults

function M.validate_config(opts)
	if opts.update_interval and type(opts.update_interval) ~= "number" then
		vim.notify("update_interval must be a number", vim.log.levels.ERROR)
		return false
	end

	if opts.node_path and type(opts.node_path) ~= "string" then
		vim.notify("node_path must be a string", vim.log.levels.ERROR)
		return false
	end

	if opts.output and opts.output.use_treesitter ~= nil and type(opts.output.use_treesitter) ~= "boolean" then
		vim.notify("output.use_treesitter must be a boolean", vim.log.levels.ERROR)
		return false
	end

	return true
end

function M.setup(opts)
	if M.validate_config(opts or {}) then
		config = vim.tbl_deep_extend("force", M.defaults, opts or {})
	end
end

function M.get()
	return config
end

return M
