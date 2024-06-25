local provider = "clangd"

local custom_on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "<leader>lh", "<cmd>ClangdSwitchSourceHeader<cr>", opts)
    vim.keymap.set("x", "<leader>lA", "<cmd>ClangdAST<cr>", opts)
    vim.keymap.set("n", "<leader>lH", "<cmd>ClangdTypeHierarchy<cr>", opts)
    vim.keymap.set("n", "<leader>lt", "<cmd>ClangdSymbolInfo<cr>", opts)
    vim.keymap.set("n", "<leader>lm", "<cmd>ClangdMemoryUsage<cr>", opts)
    ---
    local clangd_extensions = require("clangd_extensions.inlay_hints")
    clangd_extensions.setup_autocmd()
    clangd_extensions.set_inlay_hints()

    local require_ok, navbuddy = pcall(require, "nvim-navbuddy")
    if require_ok then 
        navbuddy.attach(client, bufnr)
    end
end
local custom_on_init = function(client, bufnr)
    require("clangd_extensions.config").setup {}
    require("clangd_extensions.ast").init()
    vim.cmd [[
    command ClangdToggleInlayHints lua require('clangd_extensions.inlay_hints').toggle_inlay_hints()
    command -range ClangdAST lua require('clangd_extensions.ast').display_ast(<line1>, <line2>)
    command ClangdTypeHierarchy lua require('clangd_extensions.type_hierarchy').show_hierarchy()
    command ClangdSymbolInfo lua require('clangd_extensions.symbol_info').show_symbol_info()
    command -nargs=? -complete=customlist,s:memuse_compl ClangdMemoryUsage lua require('clangd_extensions.memory_usage').show_memory_usage('<args>' == 'expand_preamble')
    ]]
end

local opts = { 
    capabilities = { offsetEncoding = { "utf-16" },}, 
    on_attach = custom_on_attach,
    on_init = custom_on_init,
    cmd = {
        provider,
        -- some settings can only passed as commandline flags, see `clangd --help`
        "--background-index",
        "--clang-tidy",
        "--all-scopes-completion",
        "--log=error",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
        "--pch-storage=memory", -- could also be disk
        "--folding-ranges",
        "--enable-config", -- clangd 11+ supports reading from .clangd configuration file
        --offset-encoding=utf-16", --temporary fix for null-ls
        -- "--limit-references=1000",
        -- "--limit-resutls=1000",
        -- "--malloc-trim",
        -- "--clang-tidy-checks=-*,llvm-*,clang-analyzer-*,modernize-*,-modernize-use-trailing-return-type",
        -- "--header-insertion=never",
        -- "--query-driver=<list-of-white-listed-complers>"
    },
}
return opts