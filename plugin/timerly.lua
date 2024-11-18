vim.api.nvim_create_user_command("TTimerlyToggle", function()
	require("timerly").toggle()
end, { desc = "Toggle Timerly" })
