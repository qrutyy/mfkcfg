local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- Clangd setup для macOS
lspconfig.clangd.setup{
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    settings = {
        clangd = {
            fallbackFlags = { "-std=c11" }
        }
    }
}

-- OCaml Setup
lspconfig.ocamllsp.setup({
    cmd = {"ocamllsp"},
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- HTML Setup
lspconfig.html.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- Bash Language Server
lspconfig.bashls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    settings = {
        bashIde = {
            globPattern = "*@(.sh|.inc|.bash|.command)"
        }
    }
})

-- Dockerfile Language Server
lspconfig.dockerls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- YAML Language Server
lspconfig.yamlls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.yml"
            }
        }
    }
})

-- JSON Language Server
lspconfig.jsonls.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- Markdown Language Server
lspconfig.marksman.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- CMake Language Server
lspconfig.cmake.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- Python Language Server
lspconfig.pyright.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
            }
        }
    }
})

-- Swift Language Server
lspconfig.sourcekit.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

-- Kotlin Language Server
lspconfig.kotlin_language_server.setup({
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities
})

