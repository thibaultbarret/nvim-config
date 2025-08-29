local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

-- Table des lettres grecques avec leurs symboles Unicode
local greek_letters = {
	-- Lettres minuscules
	{ trigger = "alpha", symbol = "α" },
	{ trigger = "beta", symbol = "β" },
	{ trigger = "gamma", symbol = "γ" },
	{ trigger = "delta", symbol = "δ" },
	{ trigger = "epsilon", symbol = "ε" },
	{ trigger = "zeta", symbol = "ζ" },
	{ trigger = "eta", symbol = "η" },
	{ trigger = "theta", symbol = "θ" },
	{ trigger = "iota", symbol = "ι" },
	{ trigger = "kappa", symbol = "κ" },
	{ trigger = "lambda", symbol = "λ" },
	{ trigger = "mu", symbol = "μ" },
	{ trigger = "nu", symbol = "ν" },
	{ trigger = "xi", symbol = "ξ" },
	{ trigger = "omicron", symbol = "ο" },
	{ trigger = "pi", symbol = "π" },
	{ trigger = "rho", symbol = "ρ" },
	{ trigger = "sigma", symbol = "σ" },
	{ trigger = "tau", symbol = "τ" },
	{ trigger = "upsilon", symbol = "υ" },
	{ trigger = "phi", symbol = "φ" },
	{ trigger = "chi", symbol = "χ" },
	{ trigger = "psi", symbol = "ψ" },
	{ trigger = "omega", symbol = "ω" },

	-- Lettres majuscules
	{ trigger = "Alpha", symbol = "Α" },
	{ trigger = "Beta", symbol = "Β" },
	{ trigger = "Gamma", symbol = "Γ" },
	{ trigger = "Delta", symbol = "Δ" },
	{ trigger = "Epsilon", symbol = "Ε" },
	{ trigger = "Zeta", symbol = "Ζ" },
	{ trigger = "Eta", symbol = "Η" },
	{ trigger = "Theta", symbol = "Θ" },
	{ trigger = "Iota", symbol = "Ι" },
	{ trigger = "Kappa", symbol = "Κ" },
	{ trigger = "Lambda", symbol = "Λ" },
	{ trigger = "Mu", symbol = "Μ" },
	{ trigger = "Nu", symbol = "Ν" },
	{ trigger = "Xi", symbol = "Ξ" },
	{ trigger = "Omicron", symbol = "Ο" },
	{ trigger = "Pi", symbol = "Π" },
	{ trigger = "Rho", symbol = "Ρ" },
	{ trigger = "Sigma", symbol = "Σ" },
	{ trigger = "Tau", symbol = "Τ" },
	{ trigger = "Upsilon", symbol = "Υ" },
	{ trigger = "Phi", symbol = "Φ" },
	{ trigger = "Chi", symbol = "Χ" },
	{ trigger = "Psi", symbol = "Ψ" },
	{ trigger = "Omega", symbol = "Ω" },

	-- Variantes spéciales
	{ trigger = "varepsilon", symbol = "ε" },
	{ trigger = "vartheta", symbol = "ϑ" },
	{ trigger = "varkappa", symbol = "ϰ" },
	{ trigger = "varpi", symbol = "ϖ" },
	{ trigger = "varrho", symbol = "ϱ" },
	{ trigger = "varsigma", symbol = "ς" }, -- sigma final
	{ trigger = "varphi", symbol = "ϕ" },
	-- Autres :

	{ trigger = "partial", symbol = "∂" },
}

-- Générer les snippets automatiquement
local snippets = {}

for _, letter in ipairs(greek_letters) do
	table.insert(
		snippets,
		s({
			trig = letter.trigger,
			dscr = "Insert Greek letter " .. letter.symbol,
			wordTrig = true, -- Se déclenche seulement sur les mots complets
		}, {
			t(letter.symbol),
		})
	)
end

-- Configuration pour tous les filetypes
ls.add_snippets("all", snippets)
