local config = require("inline-eval.config")
local commands = require("inline-eval.commands")

local M = {}

function M.setup(opts)
	config.setup(opts)
	commands.setup()
end

function M.start()
	commands.start()
end

function M.stop()
	commands.stop()
end

return M
