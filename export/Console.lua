local class = require 'ext.class'
local string = require 'ext.string'
local table = require 'ext.table'
local Export = require 'symmath.export.Export'

local Console = class(Export)

Console.symbols = table{
	Alpha = 'Α',
	alpha = 'α',	--άλφα 	[a] [aː] 	[a]
	Beta = 'Β',
	beta = 'β',	--βήτα 	[b] 	[v]
	Gamma = 'Γ',
	gamma = 'γ',	--γάμμα 	[ɡ], [ŋ][ex 1] 	[ɣ] ~ [ʝ], [ŋ][ex 2] ~ [ɲ][ex 3]
	Delta = 'Δ',
	delta = 'δ',	--δέλτα 	[d] 	[ð]
	Epsilon = 'Ε',
	epsilon = 'ε',	--έψιλον 	[e]
	Zeta = 'Ζ',
	zeta = 'ζ',	--ζήτα 	[zd]A 	[z]
	Eta = 'Η',
	eta = 'η',	--ήτα 	[ɛː] 	[i]
	Theta = 'Θ',
	theta = 'θ',	--θήτα 	[tʰ] 	[θ]
	Iota = 'Ι',
	iota = 'ι',	--ιώτα 	[i] [iː] 	[i], [ʝ],[ex 4] [ɲ][ex 5]
	Kappa = 'Κ',
	kappa = 'κ',	--κάππα 	[k] 	[k] ~ [c]
	Lambda = 'Λ',
	lambda = 'λ',	--λάμδα 	[l]
	Mu = 'Μ',
	mu = 'μ',	--μυ 	[m]
	Nu = 'Ν',
	nu = 'ν',	--νυ 	[n]
	Xi = 'Ξ',
	xi = 'ξ',	--ξι 	[ks]
	Omicron = 'Ο',
	omicron = 'ο',	--όμικρον 	[o]
	Pi = 'Π',
	pi = 'π',	--πι 	[p]
	Rho = 'Ρ',
	rho = 'ρ',	--ρώ 	[r]
	Sigma = 'Σ',
	sigma = 'σ',	--σίγμα 	[s] 	[s] ~ [z]		/ς[note 1]
	Tau = 'Τ',
	tau = 'τ',	--ταυ 	[t]
	Upsilon = 'Υ',
	upsilon = 'υ',	--ύψιλον 	[y] [yː] 	[i]
	Phi = 'Φ',
	phi = 'φ',	--φι 	[pʰ] 	[f]
	Chi = 'Χ',
	chi = 'χ',	--χι 	[kʰ] 	[x] ~ [ç]
	Psi = 'Ψ',
	psi = 'ψ',	--ψι 	[ps]
	Omega = 'Ω',
	omega = 'ω',	--ωμέγα 	[ɔː] 	[o]

	-- TODO rename to 'infinity'.  see symmath.lua and symmath/export/LaTeX.lua
	infty = '∞',
}
for _,k in ipairs(Console.symbols:keys()) do
	Console.symbols[k] = string.trim(Console.symbols[k])
end

function Console:fixVariableName(name)
local orig = name
	local i=1
	while i < #name do
		for symname,symchar in pairs(Console.symbols) do
			if name:sub(i):match('^'..symname)
			and not name:sub(i+#symname):match('%a')	-- check 'not %w' rather than %W so that '' will hit the condition 
			then
				name = name:sub(1,i-1) .. symchar .. name:sub(i+#symname)
			end
		end
		i=i+1
	end
	return name
end

return Console
