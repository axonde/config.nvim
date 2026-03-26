local jdtls_status, jdtls = pcall(require, 'jdtls')
if not jdtls_status then
    vim.notify('⚠️ nvim-jdtls not installed', vim.log.levels.WARN)
    return
end

-- Set Java
local java_home = os.getenv('JAVA_HOME')
local mason_path = vim.fn.stdpath('data') .. '/mason/packages/jdtls'

-- Функция поиска lombok.jar
local function find_lombok_jar()
    local gradle_cache = (os.getenv('GRADLE_USER_HOME') or (os.getenv('HOME') .. '/.gradle')) .. '/caches'
    local pattern = gradle_cache .. '/modules-2/files-2.1/org.projectlombok/lombok/*/*/lombok-*.jar'
    local jars = vim.fn.glob(pattern, false, true)
    for _, jar in ipairs(jars) do
        if not jar:match('%-sources%.jar$') then
            return jar
        end
    end
    return nil
end
lombok_jar = find_lombok_jar()

-- Формируем команду запуска jdtls
local cmd = {
    java_home .. '/bin/java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Xmx1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
}

if lombok_jar then
    table.insert(cmd, '-javaagent:' .. lombok_jar)
end

table.insert(cmd, '-jar')
table.insert(cmd, vim.fn.glob(mason_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'))
table.insert(cmd, '-configuration')
table.insert(cmd, mason_path .. '/config_mac')
table.insert(cmd, '-data')
table.insert(cmd, vim.fn.stdpath('cache') .. '/jdtls-workspace/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t'))

-- Корень проекта
local root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'mvnw', 'gradlew' }, { upward = true })[1]) or vim.fn.getcwd()

local capabilities = vim.lsp.protocol.make_client_capabilities()

-- ---- ЗАПУСК через nvim-jdtls ----
---@diagnostic disable-next-line: undefined-field
jdtls.start_or_attach({
    cmd = cmd,
    root_dir = root_dir,
    capabilities = capabilities,
    settings = {
        java = {
            configuration = {
                runtimes = {
                    { name = 'JavaSE-21', path = java_home, default = true },
                }
            },
            import = {
                gradle = {
                    enabled = true,
                    wrapper = { enabled = true },
                    java = {
                        compileOnly = { enabled = true }
                    }
                }
            },
            eclipse = {
                downloadSources = true,
            },
            project = {
                referencedLibraries = lombok_jar and { lombok_jar } or {}
            }
        }
    },
})
