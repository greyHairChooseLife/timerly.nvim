local utils = require "timerly.utils"
local state = require "timerly.state"
local api = vim.api
local volt = require "volt"
local volt_events = require "volt.events"
local timerlyapi = require "timerly.api"

state.ns = api.nvim_create_namespace "Timerly"

local M = {}

M.setup = function(opts)
  state.config = vim.tbl_deep_extend("force", state.config, opts or {})
end

M.open = function()
  state.volt_set = true
  local config = state.config
  state.minutes = config.minutes[1]

  utils.secs_to_ascii(state.minutes * 60)

  state.w = 24 + 2 + (2 * 4) + (2 * state.xpad)
  state.w_with_pad = state.w - (2 * state.xpad)

  utils.open_watch(true)
  state.is_center = true
  -- utils.open_watch()

  vim.fn.prompt_setcallback(state.input_buf, function(input)
    local n = tonumber(input)
    if type(n) == "number" then
      state.minutes = n
      timerlyapi.reset()
    end
  end)

  volt.gen_data {
    {
      buf = state.buf,
      layout = require "timerly.layout",
      xpad = state.xpad,
      ns = state.ns,
    },
  }

  volt.run(state.buf, { h = state.h, w = state.w })
  volt_events.add(state.buf)

  volt.mappings {
    bufs = { state.buf, state.input_buf },
    after_close = function()
      state.timer:stop()
      state.buf = nil
      state.input_buf = nil
      state.volt_set = false
    end,
  }

  require "timerly.actions"
end

M.toggle_watch = function()
  if not state.volt_set then
    M.open()
  elseif state.visible_watch then
    api.nvim_win_close(state.win, true)
  else
    utils.open_watch()
  end

  state.visible_watch = not state.visible_watch
end

M.toggle_input = function()
  if not state.volt_set then
    M.open()
    utils.open_input()
    state.visible_watch = true
    state.visible_input = true
  elseif state.visible_input then
    api.nvim_win_close(state.input_win, true)
    state.visible_input = false
  elseif state.visible_watch then
    utils.open_input()
    state.visible_input = true
  end
end

M.toggle = function()
  if not state.volt_set then
    M.open()
    state.visible_watch = true
  elseif state.volt_set and not state.visible_watch then
    state.win = vim.api.nvim_open_win(state.buf, false, state.win_conf)
    state.visible_watch = true
    api.nvim_win_set_hl_ns(state.win, state.ns)
    api.nvim_set_hl(state.ns, "Normal", { link = "ExdarkBg" })
    api.nvim_set_hl(state.ns, "FLoatBorder", { link = "Exdarkborder" })

  else
    api.nvim_win_hide(state.win)
    state.visible_watch = false
  end
end

return M
