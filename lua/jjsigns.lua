local M = {
	SIGNS = {
		add = { text = "┃", numhl = "JJAddedSign" },
		change = { text = "┃", numhl = "JJChangedSign" },
		delete = { text = "_", numhl = "JJDeletedSign" },
		topdelete = { text = "⎻", numhl = "JJDeletedSign" },
		changedelete = { text = "~" },
		untracked = { text = "┆" },
	},
}

-- Utility function to run a shell command and capture output
local function run_command(cmd)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
	return result
end

-- Parse Jujutsu changes and return line diagnostics
local function parse_jujutsu_status()
	local diagnostics = {}
	local buffer = vim.api.nvim_get_current_buf()
	local file_path = vim.api.nvim_buf_get_name(buffer)

	-- Run the Jujutsu command to get the diff for the current file
	local jj_output = run_command("jj diff --context=0 --color=never --quiet --git " .. file_path)

	-- Parse the output line by line
	for line in jj_output:gmatch("[^\r\n]+") do
		-- Example parsing logic (customize this based on jj output format)
		local r_l, r_c, a_l, a_c = line:match("^@@%s+-(%d+),(%d+)%s+%+(%d+),(%d+)%s+@@$")
		if r_l and r_c then
			-- vim.notify(line .. " " .. (r_l or ""))
			-- vim.notify(r_l .. "," .. r_c .. " " .. a_l .. "," .. a_c)

			if a_c ~= "0" then
				for line = tonumber(a_l), tonumber(a_l) + tonumber(a_c) - 1 do
					vim.fn.sign_place(
						0,
						"CustomSignGroup",
						r_c == "0" and "JJAddedSign" or "JJChangedSign",
						vim.api.nvim_get_current_buf(),
						{ lnum = line, priority = 10 }
					)
				end
			else
				local line = tonumber(a_l)
				vim.fn.sign_place(
					0,
					"CustomSignGroup",
					"JJTopDeletedSign",
					vim.api.nvim_get_current_buf(),
					{ lnum = line, priority = 10 }
				)
			end
		end
	end

	return diagnostics
end

-- Function to display Jujutsu diagnostics
function M.show_diagnostics()
	local buffer = vim.api.nvim_get_current_buf()
	local diagnostics = parse_jujutsu_status()

	-- Set diagnostics for the current buffer
	vim.diagnostic.set(vim.api.nvim_create_namespace("JujutsuDiagnostics"), buffer, diagnostics, {})
end

-- Auto-command to refresh diagnostics on buffer write
function M.setup()
	vim.cmd("highlight JJAddedSign guifg=#99FF99")
	vim.cmd("highlight JJChangedSign guifg=#FFA500")
	vim.cmd("highlight JJDeletedSign guifg=#FF5555")

	vim.fn.sign_define("JJAddedSign", M.SIGNS.add)
	vim.fn.sign_define("JJChangedSign", M.SIGNS.change)
	vim.fn.sign_define("JJDeletedSign", M.SIGNS.delete)
	vim.fn.sign_define("JJTopDeletedSign", M.SIGNS.topdelete)
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
		pattern = "*",
		callback = M.show_diagnostics,
	})
end

return M
