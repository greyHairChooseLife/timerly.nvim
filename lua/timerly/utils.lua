local M = {}
local state = require "timerly.state"
local ascii = require "timerly.ascii"
local redraw = require("volt").redraw
local api = vim.api

M.secs_to_ascii = function(n)
  local mins = n / 60 -- Make sure mins is an integer
  local secs = n % 60

  local nums = {
    math.floor(mins / 10) + 1,
    math.floor(mins % 10) + 1,
    11,
    math.floor(secs / 10) + 1,
    math.floor(secs % 10) + 1,
  }

  local abc = { {}, {}, {}, {}, {} }

  for i = 1, 5 do
    local numascii = ascii[nums[i]]

    local hlgroup = "Exgreen"

    if i > 3 then
      hlgroup = "linenr"
    end

    for row = 1, 5 do
      if i ~= 1 then
        table.insert(abc[row], { "  " })
      end

      table.insert(abc[row], { numascii[row], hlgroup })
    end
  end

  state.clock = abc
end

M.start = function(minutes)
  local total_secs = minutes * 60

  state.timer:start(
    0,
    1000,
    vim.schedule_wrap(function()
      state.progress = math.floor((total_secs / (state.minutes * 60)) * 100)
      state.progress = 100 - state.progress
      M.secs_to_ascii(total_secs)

      if total_secs > 0 then
        total_secs = total_secs - 1
      else
        state.timer:stop()
        state.config.on_finish()
        state.status = ""
      end

      redraw(state.buf, "clock")
      -- redraw(state.buf, "progress")

      state.total_secs = total_secs
    end)
  )
end

M.open_watch = function(center)
  local centered_col = math.floor((vim.o.columns / 2) - (state.w / 2))
  local centered_row = math.floor((vim.o.lines / 2) - (state.h / 2))
  local right_col = math.floor((vim.o.columns) - (state.w / 2))

  state.buf = state.buf or api.nvim_create_buf(false, true)

  state.win_conf = {
    relative = "editor",
    row = center and centered_row or 0,
    col = center and centered_col or right_col,
    width = state.w,
    height = state.h,
    style = "minimal",
    border = "single",
  }

  state.win = api.nvim_open_win(state.buf, true, state.win_conf)

  api.nvim_win_set_hl_ns(state.win, state.ns)
  api.nvim_set_hl(state.ns, "Normal", { link = "ExdarkBg" })
  api.nvim_set_hl(state.ns, "FLoatBorder", { link = "Exdarkborder" })
end

M.open_input = function()
  state.input_buf = state.input_buf or api.nvim_create_buf(false, true)

  state.input_win = api.nvim_open_win(state.input_buf, true, {
    row = state.h + 1,
    col = -1,
    width = state.w,
    height = 1,
    relative = "win",
    win = state.win,
    style = "minimal",
    border = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
  })

  vim.bo[state.input_buf].buftype = "prompt"
  vim.fn.prompt_setprompt(state.input_buf, " 󰄉  Enter time: ")
  vim.wo[state.input_win].winhl = "Normal:ExBlack2Bg,FloatBorder:ExBlack2Border"

  vim.cmd.startinsert()
end

return M
