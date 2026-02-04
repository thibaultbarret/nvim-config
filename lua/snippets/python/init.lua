local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- init
    s("init", {
        t("# --- 🔧 INITIALIZATION ---"),
        t({ "", "def __init__(self, " }),
        i(1, "args"),
        t("):"),
        t({ "", '    """' }),
        t({ "", "    " }),
        i(2, "Initialize the class."),
        t({ "", '    """' }),
        t({ "", "    " }),
        i(0),
    }),
    --
    -- __init__ with list, dict, bool, str
    s("init_all", {
        t("# --- 🔧 INITIALIZATION ---"),
        t({ "", "def __init__(self, " }),
        i(1, "args"),
        t("):"),
        t({ "", '    """' }),
        t({ "", "    " }),
        i(2, "Initialize the class."),
        t({ "", '    """' }),
        t({
            "",
            "",
            "    self.__init_bool()",
            "    self.__init_dict()",
            "    self.__init_list()",
            "    self.__init_str()",
        }),
        i(0),
        -- Bool
        t({ "", "", "def __init_bool(self):", "" }),
        t({ '    """Initialize booleans."""' }),
        t({ "", "    pass" }),
        -- Dict
        t({ "", "", "def __init_dict(self):", "" }),
        t({ '    """Initialize dictionaries."""' }),
        t({ "", "    pass" }),
        -- List
        t({ "", "", "def __init_list(self):", "" }),
        t({ '    """Initialize lists."""' }),
        t({ "", "    pass" }),
        -- Strings
        t({ "", "", "def __init_str(self):", "" }),
        t({ '    """Initialize strings."""' }),
        t({ "", "    pass" }),
    }),
    --
    -- init dict class
    s("dict", {
        t("self.__d_"),
        i(1),
        t(": "),
        c(2, {
            sn(nil, { t("Dict["), i(1), t("] = {}") }),
            sn(nil, { i(1), t(" = {}") }),
        }),
        i(0),
    }),
    --
    -- init list class
    s("list", {
        t("self.__l_"),
        i(1),
        t(": "),
        c(2, {
            sn(nil, { t("List["), i(1), t("] = []") }),
            sn(nil, { i(1), t(" = []") }),
        }),
        i(0),
    }),
    --
    -- init str class
    s("str", {
        t("self.__s_"),
        i(1),
        t(': str = "'),
        i(2),
        t('"'),
    }),

    -- init array class
    s("array", {
        t("self.__a_"),
        i(1),
        t(" = "),
        i(2),
        t(""),
    }),
}
