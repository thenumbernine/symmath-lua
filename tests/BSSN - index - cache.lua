local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}



dt_alpha_def = (
	Tensor.Ref(
		var("\\alpha"),
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="i"}
			)
		) +
		-(
			(
				(
					var("\\alpha") ^
					Constant(2)
				) *
				var("f") *
				var("K")
			)
		)
	)
)


dt_beta_u_def = (
	Tensor.Ref(
		var("\\beta"),
		Tensor.Index{lower=false, symbol="i"},
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	Tensor.Ref(
		var("B"),
		Tensor.Index{lower=false, symbol="i"}
	)
)


dt_B_u_def = (
	Tensor.Ref(
		var("B"),
		Tensor.Index{lower=false, symbol="i"},
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			(
				Constant(3) /
				Constant(4)
			) *
			Tensor.Ref(
				var("\\bar{\\Lambda}"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, derivative=",", symbol="t"}
			)
		) +
		-(
			(
				var("\\eta") *
				Tensor.Ref(
					var("B"),
					Tensor.Index{lower=false, symbol="i"}
				)
			)
		)
	)
)


dt_W_def = (
	Tensor.Ref(
		var("W"),
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(6)
			) *
			var("W") *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="i"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("W") *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			Tensor.Ref(
				var("W"),
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="i"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			var("K") *
			var("W") *
			var("\\alpha")
		)
	)
)


dt_epsilonBar_ll_def = (
	Tensor.Ref(
		var("\\bar{\\epsilon}"),
		Tensor.Index{lower=true, symbol="i"},
		Tensor.Index{lower=true, symbol="j"},
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="k"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="k"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, derivative=",", symbol="k"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="k"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"},
				Tensor.Index{lower=true, derivative=",", symbol="k"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="j"},
				Tensor.Index{lower=true, symbol="k"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="k"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			)
		)
	)
)


dt_K_def = (
	Tensor.Ref(
		var("K"),
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			var("\\alpha") *
			(
				var("K") ^
				Constant(2)
			)
		) +
		(
			Tensor.Ref(
				var("K"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\Lambda}"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\mathcal{C}"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			var("W") *
			Tensor.Ref(
				var("W"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			)
		) +
		(
			var("\\alpha") *
			Tensor.Ref(
				var("R"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(4) *
			var("S") *
			var("\\alpha") *
			var("\\pi")
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="e"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="e"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="e"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-12) *
			var("\\alpha") *
			var("\\pi") *
			var("\\rho")
		)
	)
)


dt_ABar_ll_def = (
	Tensor.Ref(
		var("\\bar{A}"),
		Tensor.Index{lower=true, symbol="i"},
		Tensor.Index{lower=true, symbol="j"},
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="i"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			var("K") *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			)
		) +
		(
			Constant(-1) *
			var("W") *
			Tensor.Ref(
				var("W"),
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			Constant(-1) *
			var("W") *
			Tensor.Ref(
				var("W"),
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			)
		) +
		(
			var("\\alpha") *
			Tensor.Ref(
				var("R"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\Lambda}"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\mathcal{C}"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="j"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(8) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("S") *
			var("\\alpha") *
			var("\\pi") *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("\\alpha") *
			Tensor.Ref(
				var("R"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("W") *
			Tensor.Ref(
				var("W"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			)
		) +
		(
			Constant(-8) *
			var("\\alpha") *
			var("\\pi") *
			Tensor.Ref(
				var("S"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="e"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="e"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="e"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=true, symbol="j"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		)
	)
)


dt_LambdaBar_u_def = (
	Tensor.Ref(
		var("\\bar{\\Lambda}"),
		Tensor.Index{lower=false, symbol="i"},
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			(
				Constant(1) /
				Constant(6)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="i"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(6)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(6)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			(
				Constant(1) /
				(
					var("\\bar{\\gamma}") ^
					Constant(2)
				)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(6)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			(
				Constant(1) /
				(
					var("\\bar{\\gamma}") ^
					Constant(2)
				)
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(2) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-2) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=false, symbol="b"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=false, symbol="e"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, symbol="e"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=false, symbol="f"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, symbol="f"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, symbol="d"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="d"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=false, symbol="f"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="f"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=false, symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=false, symbol="e"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, symbol="f"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=false, symbol="e"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=true, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=false, symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=false, symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=false, symbol="i"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		)
	)
)


dt_alpha_norm_def = (
	Tensor.Ref(
		var("\\alpha"),
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			)
		) +
		(
			Constant(-1) *
			var("K") *
			var("f") *
			(
				var("\\alpha") ^
				Constant(2)
			)
		)
	)
)


dt_beta_U_norm_def = (
	Tensor.Ref(
		var("\\beta"),
		Tensor.Index{lower=false, symbol="I"},
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	Tensor.Ref(
		var("B"),
		Tensor.Index{lower=false, symbol="I"}
	)
)


dt_B_U_norm_def = (
	Tensor.Ref(
		var("B"),
		Tensor.Index{lower=false, symbol="I"},
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(3) *
			(
				Constant(1) /
				Constant(4)
			) *
			Tensor.Ref(
				var("\\bar{\\Lambda}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="t"}
			)
		) +
		(
			Constant(-1) *
			var("\\eta") *
			Tensor.Ref(
				var("B"),
				Tensor.Index{lower=false, symbol="I"}
			)
		)
	)
)


dt_W_norm_def = (
	Tensor.Ref(
		var("W"),
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(6)
			) *
			var("W") *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			var("K") *
			var("W") *
			var("\\alpha")
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("W") *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("W") *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			)
		) +
		(
			Tensor.Ref(
				var("W"),
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			)
		)
	)
)


dt_K_norm_def = (
	Tensor.Ref(
		var("K"),
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			var("\\alpha") *
			(
				var("K") ^
				Constant(2)
			)
		) +
		(
			Tensor.Ref(
				var("K"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			)
		) +
		(
			var("\\alpha") *
			Tensor.Ref(
				var("R"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\Lambda}"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\mathcal{C}"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(4) *
			var("S") *
			var("\\alpha") *
			var("\\pi")
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-12) *
			var("\\alpha") *
			var("\\pi") *
			var("\\rho")
		) +
		(
			var("W") *
			Tensor.Ref(
				var("W"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="G"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="G"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="G"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="G"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="G"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="G"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		)
	)
)


dt_epsilonBar_LL_norm_def = (
	Tensor.Ref(
		var("\\bar{\\epsilon}"),
		Tensor.Index{lower=true, symbol="I"},
		Tensor.Index{lower=true, symbol="J"},
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="k"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="K"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="K"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="k"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="k"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, symbol="K"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, derivative=",", symbol="k"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="K"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="M"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=false, symbol="M"},
				Tensor.Index{lower=true, derivative=",", symbol="k"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="k"},
				Tensor.Index{lower=false, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="K"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="N"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="j"},
				Tensor.Index{lower=false, symbol="N"},
				Tensor.Index{lower=true, derivative=",", symbol="k"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="k"},
				Tensor.Index{lower=false, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="k"},
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			)
		)
	)
)


dt_ABar_LL_norm_def = (
	Tensor.Ref(
		var("\\bar{A}"),
		Tensor.Index{lower=true, symbol="I"},
		Tensor.Index{lower=true, symbol="J"},
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="i"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			)
		) +
		(
			var("K") *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			)
		) +
		(
			Constant(-1) *
			var("W") *
			Tensor.Ref(
				var("W"),
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			)
		) +
		(
			Constant(-1) *
			var("W") *
			Tensor.Ref(
				var("W"),
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			)
		) +
		(
			var("\\alpha") *
			Tensor.Ref(
				var("R"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			)
		) +
		(
			Constant(8) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("S") *
			var("\\alpha") *
			var("\\pi") *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="N"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="j"},
				Tensor.Index{lower=false, symbol="N"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="M"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=false, symbol="M"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("\\alpha") *
			Tensor.Ref(
				var("R"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\Lambda}"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\mathcal{C}"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			)
		) +
		(
			Constant(-8) *
			var("\\alpha") *
			var("\\pi") *
			Tensor.Ref(
				var("S"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="M"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=false, symbol="M"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="M"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=false, symbol="M"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="N"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="j"},
				Tensor.Index{lower=false, symbol="N"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="N"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="j"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="j"},
				Tensor.Index{lower=false, symbol="N"},
				Tensor.Index{lower=true, derivative=",", symbol="i"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("W") *
			Tensor.Ref(
				var("W"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="G"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="G"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="G"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="G"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="G"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="G"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="I"},
				Tensor.Index{lower=true, symbol="J"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		)
	)
)


dt_LambdaBar_U_norm_def = (
	Tensor.Ref(
		var("\\bar{\\Lambda}"),
		Tensor.Index{lower=false, symbol="I"},
		Tensor.Index{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			(
				Constant(1) /
				Constant(6)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(6)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(6)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(6)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			(
				Constant(1) /
				(
					var("\\bar{\\gamma}") ^
					Constant(2)
				)
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(6)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			(
				Constant(1) /
				(
					var("\\bar{\\gamma}") ^
					Constant(2)
				)
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="J"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="J"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="D"}
			)
		) +
		(
			Constant(-2) *
			Tensor.Ref(
				var("\\alpha"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			)
		) +
		(
			Constant(2) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(2) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="E"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="J"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\hat{\\Gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, symbol="G"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="G"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="G"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="G"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="J"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="A"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="a"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="J"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="i"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="i"},
				Tensor.Index{lower=true, symbol="J"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="G"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="G"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="A"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			Tensor.Ref(
				var("\\bar{A}"),
				Tensor.Index{lower=true, symbol="G"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="G"},
				Tensor.Index{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="f"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="K"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="f"},
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="H"},
				Tensor.Index{lower=true, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="H"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("δ"),
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="f"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="f"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="f"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="H"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="H"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="E"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="f"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="B"},
				Tensor.Index{lower=true, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="f"},
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="H"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="H"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="H"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="H"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="f"},
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="f"},
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("δ"),
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="f"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=false, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="H"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("δ"),
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="H"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="f"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=false, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="d"},
				Tensor.Index{lower=true, symbol="D"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="c"},
				Tensor.Index{lower=false, symbol="I"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="d"},
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=true, derivative=",", symbol="f"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="C"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="D"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="C"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="D"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="f"},
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="F"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="c"},
				Tensor.Index{lower=true, symbol="H"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="H"},
				Tensor.Index{lower=true, derivative=",", symbol="c"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="f"},
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			Tensor.Ref(
				var("\\beta"),
				Tensor.Index{lower=false, symbol="A"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="B"},
				Tensor.Index{lower=false, symbol="I"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=false, symbol="E"},
				Tensor.Index{lower=false, symbol="F"}
			) *
			Tensor.Ref(
				var("\\bar{\\gamma}"),
				Tensor.Index{lower=true, symbol="C"},
				Tensor.Index{lower=true, symbol="K"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="a"},
				Tensor.Index{lower=true, symbol="A"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="b"},
				Tensor.Index{lower=true, symbol="B"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="e"},
				Tensor.Index{lower=true, symbol="E"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=false, symbol="f"},
				Tensor.Index{lower=true, symbol="F"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="b"},
				Tensor.Index{lower=false, symbol="C"},
				Tensor.Index{lower=true, derivative=",", symbol="f"}
			) *
			Tensor.Ref(
				var("e"),
				Tensor.Index{lower=true, symbol="e"},
				Tensor.Index{lower=false, symbol="K"},
				Tensor.Index{lower=true, derivative=",", symbol="a"}
			)
		)
	)
)


return {
	{dt_alpha_def = dt_alpha_def},
	{dt_beta_u_def = dt_beta_u_def},
	{dt_W_def = dt_W_def},
	{dt_K_def = dt_K_def},
	{dt_epsilonBar_ll_def = dt_epsilonBar_ll_def},
	{dt_ABar_ll_def = dt_ABar_ll_def},
	{dt_LambdaBar_u_def = dt_LambdaBar_u_def},
	{dt_B_u_def = dt_B_u_def},

	{dt_alpha_norm_def = dt_alpha_norm_def},
	{dt_beta_U_norm_def = dt_beta_U_norm_def},
	{dt_B_U_norm_def = dt_B_U_norm_def},
	{dt_W_norm_def = dt_W_norm_def},
	{dt_K_norm_def = dt_K_norm_def},
	{dt_epsilonBar_LL_norm_def = dt_epsilonBar_LL_norm_def},
	{dt_ABar_LL_norm_def = dt_ABar_LL_norm_def},
	{dt_LambdaBar_U_norm_def = dt_LambdaBar_U_norm_def},
}

