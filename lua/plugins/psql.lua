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

local function createFileWithParentDirectories(path, content)
    local folderPath = path:match("(.*)/")

    if folderPath then
        os.execute("mkdir -p " .. folderPath)
    end

    local file = assert(io.open(path, "w"))
    file:write(content)
    file:close()
end

local connections_path = vim.fn.stdpath("config") .. "/keys/psql.json"

if vim.fn.filereadable(connections_path) == 0 then
    vim.notify("PSQL config file do not exist, create a new one", vim.log.levels.WARN)
    createFileWithParentDirectories(connections_path, "{}")
end

local connections = loadJsonFromFile(vim.fn.stdpath("config") .. "/keys/psql.json")

return {
    "axonde/psql.nvim",
    enabled = false, -- disabled for YANDEX
    cmd = { "Psql", "PsqlExec", "PsqlListDBs" },
    config = function()
        require("psql").setup({
            connections = connections,
            runner_output = "split",
        })
    end,
}
