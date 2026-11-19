vim.filetype.add({
    extension = {
        cppm = "cpp", -- interface de module (Clang/GCC convention)
        ixx = "cpp", -- convention MSVC pour les interfaces de module
        cc = "cpp", -- si pas déjà géré
    },
})
