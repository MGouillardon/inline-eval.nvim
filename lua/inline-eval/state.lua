local M = {}

local state = {
	namespace = vim.api.nvim_create_namespace("inline-eval"),
	is_running = false,
}

function M.start()
	state.is_running = true
end

function M.stop()
	state.is_running = false
end

function M.is_active()
	return state.is_running
end

function M.get_namespace()
	return state.namespace
end

return M
