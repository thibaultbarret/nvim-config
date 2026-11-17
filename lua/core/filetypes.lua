vim.filetype.add({
    extension = {
        ixx = "cpp",
        -- Parsers treesitter custom : voir plugins/treesitter.lua
        mfront = "mfront",
        mtest = "mtest",
    },
})

-- Snakemake / .snk files
vim.filetype.add({
    extension = {
        snk = "snakemake",
        smk = "snakemake",
    },
    filename = {
        ["Snakefile"] = "snakemake",
    },
    pattern = {
        ["Snakefile.*"] = "snakemake",
    },
})

-- Fichiers de configuration du shell
vim.filetype.add({
    filename = {
        [".zshrc"] = "zsh",
        [".bashrc"] = "bash",
        [".profile"] = "sh",
    },
})
