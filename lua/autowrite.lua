local autowrite = {}

-- autowrite default public options
local options = {

  -- Allow autowrite to log any info notifications to the user
  create_commands = true,
  -- Allow autowrite to log any info notifications to the user
  verbose_info = true,
  -- HACK Option: Fix Undo bug that happens on lazy
  undo_hack = false,
}

-- autowrite private options
-- This is used to set options which cannot be changed by the public API
local private_opts = {
  enabled_buffers = {},
  global = false,
}

local notify = vim.schedule_wrap(function(msg, level, opts)
  if level ~= vim.log.levels.INFO or options.verbose_info then
    vim.notify(msg, level, opts)
  end
end)

--- Setup autowrite comamnd with options
--- This function is not pure so running it multiple times is unintended behaviour
---@param opts table
function autowrite.setup(opts)
  if type(opts) == 'table' then
    -- merge opts table to default table
    for k, v in pairs(opts) do
      options[k] = v
    end

    -- merge the private options to the table
    for k, v in pairs(private_opts) do
      ---@diagnostic disable-next-line: assign-type-mismatch
      options[k] = v
    end

    if options.create_commands then
      vim.api.nvim_create_user_command('EnableAutowrite', function()
        autowrite.EnableAutowrite()
      end, {
        desc = 'Enable Autowrite for current buffer',
      })

      vim.api.nvim_create_user_command('DisableAutowrite', function()
        autowrite.EnableAutowrite()
      end, {
        desc = 'Disable Autowrite for current buffer',
      })

      vim.api.nvim_create_user_command('ToggleAutowrite', function()
        autowrite.ToggleAutowrite()
      end, {
        desc = 'Toggle on and off Autowrite for current buffer',
      })
    end
  else
    local error_msg = [[
      Can't setup autowrite.nvim, correct syntax is: 
      require('autowrite').setup { ... }
      ]]
    notify(error_msg, vim.log.levels.ERROR)
  end
end

--- This setups the autowrite autocommand and keeps track of it
--- @param bufnr any
local function EnableAutowriteOnBuf(bufnr)
  if options.enabled_buffers[bufnr] ~= nil then
    notify('This buffer has autowrite enabled already', vim.log.levels.INFO)
  else
    options.enabled_buffers[bufnr] = vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
      buffer = bufnr,
      callback = function()
        if options.undo_hack then
          -- HACK:
          -- For some reason in lazy.nvim (could be somethign else but I think it's lazy) the autocmd doesn't work correctly with undo
          -- To put a bandage on this issue, I just made it so that the write command is part of undo block with undoj
          -- This causes an error when doing an undo since undo cause a text change in which undoj tries to run but errors since
          -- undoj can't run after an undo since there is nothing to join.
          -- HOWEVER!!!, this solves the issue of it not being to all be undo in 1 undo so this "fix" the issue
          pcall(function()
            vim.cmd 'silent write | undoj'
          end)
        else
          vim.cmd 'silent write'
        end
      end,
    })
  end
end

--- This setups the autowrite autocommand and keeps track of it
--- @param bufnr any
local function DisableAutowriteOnBuf(bufnr)
  if options.enabled_buffers[bufnr] == nil then
    notify('This buffer has autowrite disabled already', vim.log.levels.INFO)
  else
    vim.api.nvim_del_autocmd(options.enabled_buffers[bufnr])
    options.enabled_buffers[bufnr] = nil
  end
end

function autowrite.EnableAutowrite()
  local buf = vim.api.nvim_get_current_buf()
  EnableAutowriteOnBuf(buf)
end

function autowrite.DisableAutowrite()
  local buf = vim.api.nvim_get_current_buf()
  DisableAutowriteOnBuf(buf)
end

function autowrite.ToggleAutowrite()
  local buf = vim.api.nvim_get_current_buf()
  if options.enabled_buffers[buf] == nil then
    EnableAutowriteOnBuf(buf)
  else
    DisableAutowriteOnBuf(buf)
  end
end

return autowrite
