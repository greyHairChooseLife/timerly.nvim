local M = {
  visible_watch = false,
  visible_input = false,
  volt_set = false,
  timer = vim.uv.new_timer(),
  clock = nil,
  xpad = 1,
  progress = 0,
  mode = "focus",
  minutes = 10,
  h = 7,
  is_center = false,

  config = {
    minutes = { 50, 5 },
    on_finish = function()
      local utils = require "timerly.utils"
      local state = require "timerly.state"
      local api = vim.api
      local timerlyapi = require "timerly.api"

      if state.visible_watch then
        api.nvim_win_hide(state.win)
        state.visible_watch = false
      end

        timerlyapi.reset()
        utils.open_watch(true)
        state.visible_watch = true
        state.is_center = true
    end,
    mapping = function() -- is func
      local map = vim.keymap.set
      local utils = require "timerly.utils"
      local state = require "timerly.state"
      local api = vim.api
      local timerlyapi = require "timerly.api"
      local opts = { noremap = true, silent = true, buffer = state.buf }

      map("n", "q", "", opts)
      map("n", "<Esc>", function()
        api.nvim_win_hide(state.win)
        state.visible_watch = false
      end, opts)
      map("n", "gq", function()
        api.nvim_win_hide(state.win)
        state.visible_watch = false
      end, opts)

      map("n", "K", function()
        timerlyapi.increment()
      end, opts)
      map("n", "J", function()
        timerlyapi.decrement()
      end, opts)
      map("n", "<Space>", function()
        if state.status == "start" then
          timerlyapi.pause()
        else
          if state.is_center then
            api.nvim_win_hide(state.win)
            state.visible_watch = false
            utils.open_watch()
            state.visible_watch = true
            timerlyapi.start()
            state.is_center = false
          else
            timerlyapi.start()
          end
        end
      end, opts)
    end,
  },

  status = "", -- or pause
}

return M
