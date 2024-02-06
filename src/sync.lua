local http = require("http")
local ltn12 = require("ltn12")
--
-- Define a local table to represent your module
local M = {}

local function read_file(path)
    local file = io.open(path, "rb") -- "rb" mode for binary read, which is safer for any file content
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end


-- Define the setup_autocommands function within the module
local function setup_autocommands()
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.xml",
    callback = function()
      local file_path = vim.fn.expand("%:p") -- Get the full path of the saved file
      M.sync_to_aem(file_path) -- Assuming sync_to_aem is another function within your module
    end,
  })
end

-- Define the sync_to_aem function within the module
function M.sync_to_aem(file_path)
  -- Implementation of syncing the file to AEM
  local file_content = read_file(file_path)
    if not file_content then
        print("Failed to read file content.")
        return
    end

    local url = "http://your_aem_server.com/path/to/api"
    local response_body = {}

    local res, status = http.request({
        url = url,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/xml",
            -- Add additional headers like authentication here
        },
        source = ltn12.source.string(file_content),
        sink = ltn12.sink.table(response_body),
    })

    if status == 200 then
        print("File synced successfully to AEM.")
    else
        print("Failed to sync file to AEM: HTTP Status " .. tostring(status))
    end
end

-- Define a setup function that users can call to initialize the plugin
function M.setup(opts)
  -- Here you can process opts and configure your plugin
  setup_autocommands() -- Setup autocommands as part of the setup process
end

-- Return the module table
return M


