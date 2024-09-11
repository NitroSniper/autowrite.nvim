local autowrite = {}

-- autowrite default public options
local options = {

  -- Allow autowrite to log any info notifications to the user
  create_commands = true,
  -- Allow autowrite to log any info notifications to the user
  verbose_info = true,
}

-- autowrite private options
-- This is used to set options which cannot be changed by the public API
local private_opts = {
  enabled_buffers = {},
}

local notify = vim.schedule_wrap(function(msg, level, opts)
  if level ~= vim.log.levels.INFO or options.verbose_info then
    vim.notify(msg, level, opts)
  end
end)

--- Setup autowrite comamnd with options
--- This function is not pure so running it multiple times is unintended behaviour
---@param opts table
autowrite.setup = function(opts)
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
      command = 'silent write',
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

autowrite.EnableAutowrite = function()
  local buf = vim.api.nvim_get_current_buf()
  EnableAutowriteOnBuf(buf)
end

autowrite.DisableAutowrite = function()
  local buf = vim.api.nvim_get_current_buf()
  DisableAutowriteOnBuf(buf)
end

autowrite.ToggleAutowrite = function()
  local buf = vim.api.nvim_get_current_buf()
  if options.enabled_buffers[buf] == nil then
    EnableAutowriteOnBuf(buf)
  else
    DisableAutowriteOnBuf(buf)
  end
end

return autowrite
