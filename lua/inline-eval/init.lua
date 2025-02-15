local config = require("inline-eval.config")
local commands = require("inline-eval.commands")
local state = require("inline-eval.state")

local M = {}

function M.setup(opts)
	config.setup(opts)
	commands.setup()
	state.get()
end

function M.start()
	commands.start()
end

function M.stop()
	commands.stop()
end

return M
