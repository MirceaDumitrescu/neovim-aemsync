local http = require("http")
local ltn12 = require("ltn12")
--
-- Define a local table to represent your module
local M = {}

local default_config = {
    serverUrl = "http://localhost:4502", -- Default server URL
    username = "admin", -- Default username
    password = "admin", -- Default password
}

local function read_file(path)
    local file = io.open(path, "rb") -- "rb" mode for binary read, which is safer for any file content
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
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

-- Define the setup function that users can call to initialize the plugin
function M.setup(opts)
    -- Merge user-provided options with the default configuration
    config = vim.tbl_deep_extend("force", {}, default_config, opts or {})

    -- Define the :AemSync command
    vim.api.nvim_create_user_command('AemSync', function()
        local file_path = vim.fn.expand("%:p") -- Get the current file path
        M.sync_to_aem(file_path)
    end, {desc = "Sync current file to AEM"})
end

-- Return the module table
return M


