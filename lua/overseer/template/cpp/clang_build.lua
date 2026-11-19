local clangxx = "/usr/local/opt/llvm/bin/clang++" -- Homebrew LLVM, Intel mac

return {
    name = "clang++ build",
    builder = function()
        local src = vim.fn.expand("%:p")
        local bin = vim.fn.expand("%:p:r")
        return {
            cmd = { clangxx },
            args = {
                "-std=c++20",
                "-Wall",
                "-Wextra",
                "-Wpedantic",
                "-g",
                src,
                "-o",
                bin,
            },
            components = {
                {
                    "on_output_quickfix",
                    open_on_match = true, -- ouvre la quickfix dès qu'une erreur est détectée
                    tail = false, -- ne suit pas la sortie en live, attend la fin
                    -- set_diagnostics = true, -- bonus : pousse aussi dans les diagnostics nvim
                    errorformat = table.concat({ -- <- C'EST ICI
                        "%f:%l:%c: %trror: %m",
                        "%f:%l:%c: %tarning: %m",
                        "%f:%l:%c: %tote: %m",
                        "%-G%.%#",
                    }, ","),
                },
                "default",
            },
        }
    end,
    condition = {
        filetype = { "cpp" },
    },
}
