local M = {}

M.state = {
	buffers = {},
	current_buf = nil,
	timer = nil,
	namespace = vim.api.nvim_create_namespace("inline-eval"),
	is_running = false,
}

function M.get()
	return M.state
end

function M.reset()
	M.state.current_buf = nil
	M.state.is_running = false
	if M.state.timer then
		vim.fn.timer_stop(M.state.timer)
		M.state.timer = nil
	end
end

function M.set_buffer(bufnr)
	M.state.current_buf = bufnr
end

function M.set_timer(timer_id)
	M.state.timer = timer_id
end

function M.set_running(is_running)
	M.state.is_running = is_running
end

return M
