local function loadJsonFromFile(filepath)
    local file = io.open(filepath, "r")
    if not file then
        vim.notify("Не удалось открыть файл: " .. filepath, vim.log.levels.ERROR)
        return nil
    end

    local content = file:read("*a")
    io.close(file)

    local ok, decoded_json = pcall(vim.fn.json_decode, content)

    if not ok then
        vim.notify("Ошибка декодирования JSON из файла: " .. filepath, vim.log.levels.ERROR)
        return nil
    end

    return decoded_json
end

local function safeWrite(filename, content)
    local file, err = io.open(filename, "w")
    if not file then
        print("Error opening file:", err)
        return false
    end

    local success, err = file:write(content)
    if not success then
        print("Error writing to file:", err)
        file:close()
        return false
    end

    file:close()
    return true
end

local connections_path = vim.fn.stdpath("config") .. "/keys/psql.json"

if vim.fn.filereadable(connections_path) == 0 then
    vim.notify("PSQL config file do not exist, create a new one", vim.log.levels.WARN)
    safeWrite(connections_path, "{}")
end

local connections = loadJsonFromFile(vim.fn.stdpath("config") .. "/keys/psql.json")

return {
    "axonde/psql.nvim",
    cmd = { "Psql", "PsqlExec", "PsqlListDBs" },
    config = function()
        require("psql").setup({
            connections = connections,
            runner_output = "split",
        })
    end,
}
