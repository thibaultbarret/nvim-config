local clangxx = "/usr/local/opt/llvm/bin/clang++"

return {
    name = "clang++ build & run",
    builder = function()
        local src = vim.fn.expand("%:p")
        local bin = vim.fn.expand("%:p:r")
        return {
            cmd = { clangxx },
            args = {
                "-std=c++20",
                "-Wall",
                "-Wextra",
                "-g",
                src,
                "-o",
                bin,
            },
            components = {
                { "on_output_quickfix", open = false },
                "on_result_diagnostics",
                -- enchaîne l'exécution si la compilation réussit
                { "dependencies", task_names = {} },
                "default",
            },
            -- post-compilation : lance le binaire
            after = function(task, status)
                if status == require("overseer").STATUS.SUCCESS then
                    require("overseer").run_template({ name = "__run_bin", params = { bin = bin } })
                end
            end,
        }
    end,
    condition = { filetype = { "cpp" } },
}
