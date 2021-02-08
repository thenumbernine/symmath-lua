local env = setmetatable({}, {__index=_G})
require 'ext.env'(env)
if setfenv then setfenv(1, env) else _ENV = env end
require 'symmath'.setup{env=env}



dt_alpha_def = (
	TensorRef(
		var("\\alpha"),
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="i"}
			)
		) -
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


dt_beta_u_def = (
	TensorRef(
		var("\\beta"),
		TensorIndex{lower=false, symbol="i"},
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	TensorRef(
		var("B"),
		TensorIndex{lower=false, symbol="i"}
	)
)


dt_B_u_def = (
	TensorRef(
		var("B"),
		TensorIndex{lower=false, symbol="i"},
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			(
				Constant(3) /
				Constant(4)
			) *
			TensorRef(
				var("\\bar{\\Lambda}"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, derivative=",", symbol="t"}
			)
		) -
		(
			var("\\eta") *
			TensorRef(
				var("B"),
				TensorIndex{lower=false, symbol="i"}
			)
		)
	)
)


dt_W_def = (
	TensorRef(
		var("W"),
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
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
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			TensorRef(
				var("W"),
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="i"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(6)
			) *
			var("W") *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="i"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		)
	)
)


dt_epsilonBar_ll_def = (
	TensorRef(
		var("\\bar{\\epsilon}"),
		TensorIndex{lower=true, symbol="i"},
		TensorIndex{lower=true, symbol="j"},
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="k"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="k"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, derivative=",", symbol="k"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="k"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="j"},
				TensorIndex{lower=true, symbol="k"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="k"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"},
				TensorIndex{lower=true, derivative=",", symbol="k"}
			)
		)
	)
)


dt_K_def = (
	TensorRef(
		var("K"),
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(4) *
			var("S") *
			var("\\alpha") *
			var("\\pi")
		) +
		(
			var("W") *
			TensorRef(
				var("W"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\Lambda}"),
				TensorIndex{lower=false, symbol="a"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\mathcal{C}"),
				TensorIndex{lower=false, symbol="a"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="a"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			TensorRef(
				var("K"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="e"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="e"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="e"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			var("\\alpha") *
			(
				var("K") ^
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
			var("\\alpha") *
			TensorRef(
				var("R"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		)
	)
)


dt_ABar_ll_def = (
	TensorRef(
		var("\\bar{A}"),
		TensorIndex{lower=true, symbol="i"},
		TensorIndex{lower=true, symbol="j"},
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(8) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("S") *
			var("\\alpha") *
			var("\\pi") *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("\\alpha") *
			TensorRef(
				var("R"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
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
			TensorRef(
				var("W"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\Lambda}"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\mathcal{C}"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
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
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="e"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="e"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="e"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="j"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			var("K") *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			)
		) +
		(
			var("\\alpha") *
			TensorRef(
				var("R"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="j"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			)
		) +
		(
			Constant(-8) *
			var("\\alpha") *
			var("\\pi") *
			TensorRef(
				var("S"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			var("W") *
			TensorRef(
				var("W"),
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="j"}
			)
		) +
		(
			Constant(-1) *
			var("W") *
			TensorRef(
				var("W"),
				TensorIndex{lower=true, derivative=",", symbol="j"}
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="i"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
			)
		) +
		(
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="j"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=true, symbol="j"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		)
	)
)


dt_LambdaBar_u_def = (
	TensorRef(
		var("\\bar{\\Lambda}"),
		TensorIndex{lower=false, symbol="i"},
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-2) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=false, symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(2) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="b"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(6)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="i"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="i"}
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
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=false, symbol="e"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, symbol="f"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=false, symbol="e"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, symbol="e"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=false, symbol="f"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="f"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=false, symbol="f"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, symbol="f"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="d"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, symbol="d"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=false, symbol="e"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			var("\\alpha") *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=false, symbol="c"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=false, symbol="c"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=true, symbol="c"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=false, symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=false, symbol="i"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="i"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		)
	)
)


dt_alpha_norm_def = (
	TensorRef(
		var("\\alpha"),
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-1) *
			var("K") *
			var("f") *
			(
				var("\\alpha") ^
				Constant(2)
			)
		) +
		(
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			)
		)
	)
)


dt_beta_U_norm_def = (
	TensorRef(
		var("\\beta"),
		TensorIndex{lower=false, symbol="I"},
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	TensorRef(
		var("B"),
		TensorIndex{lower=false, symbol="I"}
	)
)


dt_B_U_norm_def = (
	TensorRef(
		var("B"),
		TensorIndex{lower=false, symbol="I"},
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-1) *
			var("\\eta") *
			TensorRef(
				var("B"),
				TensorIndex{lower=false, symbol="I"}
			)
		) +
		(
			Constant(3) *
			(
				Constant(1) /
				Constant(4)
			) *
			TensorRef(
				var("\\bar{\\Lambda}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="t"}
			)
		)
	)
)


dt_W_norm_def = (
	TensorRef(
		var("W"),
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
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
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("W") *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			TensorRef(
				var("W"),
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(6)
			) *
			var("W") *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		)
	)
)


dt_K_norm_def = (
	TensorRef(
		var("K"),
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(4) *
			var("S") *
			var("\\alpha") *
			var("\\pi")
		) +
		(
			var("W") *
			TensorRef(
				var("W"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\Lambda}"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\mathcal{C}"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			TensorRef(
				var("K"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, symbol="G"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="G"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="G"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			var("\\alpha") *
			(
				var("K") ^
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
			var("\\alpha") *
			TensorRef(
				var("R"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		)
	)
)


dt_epsilonBar_LL_norm_def = (
	TensorRef(
		var("\\bar{\\epsilon}"),
		TensorIndex{lower=true, symbol="I"},
		TensorIndex{lower=true, symbol="J"},
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="k"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="K"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, symbol="K"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="k"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, symbol="K"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="k"},
				TensorIndex{lower=false, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="k"},
				TensorIndex{lower=false, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="K"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="k"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="K"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="N"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="j"},
				TensorIndex{lower=false, symbol="N"},
				TensorIndex{lower=true, derivative=",", symbol="k"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="K"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="M"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=false, symbol="M"},
				TensorIndex{lower=true, derivative=",", symbol="k"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="k"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, derivative=",", symbol="k"}
			)
		)
	)
)


dt_ABar_LL_norm_def = (
	TensorRef(
		var("\\bar{A}"),
		TensorIndex{lower=true, symbol="I"},
		TensorIndex{lower=true, symbol="J"},
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(8) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("S") *
			var("\\alpha") *
			var("\\pi") *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("W") *
			TensorRef(
				var("W"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			var("\\alpha") *
			TensorRef(
				var("R"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\Lambda}"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="M"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=false, symbol="M"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="N"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="j"},
				TensorIndex{lower=false, symbol="N"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="M"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=false, symbol="M"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="N"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="j"},
				TensorIndex{lower=false, symbol="N"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			var("K") *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			)
		) +
		(
			Constant(-1) *
			var("W") *
			TensorRef(
				var("W"),
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="j"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			)
		) +
		(
			Constant(-1) *
			var("W") *
			TensorRef(
				var("W"),
				TensorIndex{lower=true, derivative=",", symbol="j"}
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			)
		) +
		(
			var("\\alpha") *
			TensorRef(
				var("R"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			)
		) +
		(
			Constant(-8) *
			var("\\alpha") *
			var("\\pi") *
			TensorRef(
				var("S"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="i"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		) +
		(
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			)
		) +
		(
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="M"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=false, symbol="M"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="N"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="j"},
				TensorIndex{lower=false, symbol="N"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="j"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="j"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="i"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="G"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, symbol="G"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="G"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\mathcal{C}"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
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
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			(
				var("W") ^
				Constant(2)
			)
		)
	)
)


dt_LambdaBar_U_norm_def = (
	TensorRef(
		var("\\bar{\\Lambda}"),
		TensorIndex{lower=false, symbol="I"},
		TensorIndex{lower=true, derivative=",", symbol="t"}
	)
):eq(
	(
		(
			Constant(-2) *
			TensorRef(
				var("\\alpha"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(2) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="D"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(6)
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
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
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="H"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="H"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="f"},
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\delta"),
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="H"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="H"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="H"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="f"},
				TensorIndex{lower=false, symbol="H"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\delta"),
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="H"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="H"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="f"},
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="H"}
			) *
			TensorRef(
				var("\\delta"),
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="H"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=false, symbol="H"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="H"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="E"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="f"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="f"},
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="H"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="H"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="f"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="f"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="f"},
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="H"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="H"},
				TensorIndex{lower=true, derivative=",", symbol="f"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="f"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="H"},
				TensorIndex{lower=true, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="H"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="f"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="I"},
				TensorIndex{lower=true, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="f"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="J"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="f"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="H"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="H"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="f"},
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="K"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="K"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="f"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="f"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, symbol="K"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(2) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(2) *
			(
				Constant(1) /
				Constant(3)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			(
				Constant(1) /
				Constant(2)
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			Constant(-1) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, derivative=",", symbol="a"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="e"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="d"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="D"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="G"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="G"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="e"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="e"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="a"},
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			var("\\alpha") *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, symbol="E"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-2) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="E"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="D"},
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
			)
		) +
		(
			var("\\alpha") *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="E"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="E"},
				TensorIndex{lower=true, derivative=",", symbol="a"}
			)
		) +
		(
			Constant(-1) *
			var("\\alpha") *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{A}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="b"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="c"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("\\hat{\\Gamma}"),
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, symbol="C"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="A"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="D"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="F"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="d"},
				TensorIndex{lower=true, symbol="D"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="d"},
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="c"},
				TensorIndex{lower=true, symbol="C"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="c"},
				TensorIndex{lower=false, symbol="I"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="C"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="F"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, symbol="C"},
				TensorIndex{lower=true, symbol="F"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=true, derivative=",", symbol="a"}
			) *
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="J"}
			) *
			TensorRef(
				var("\\bar{\\gamma}"),
				TensorIndex{lower=false, symbol="B"},
				TensorIndex{lower=false, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="a"},
				TensorIndex{lower=true, symbol="A"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="b"},
				TensorIndex{lower=true, symbol="B"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=true, symbol="i"},
				TensorIndex{lower=false, symbol="I"}
			) *
			TensorRef(
				var("e"),
				TensorIndex{lower=false, symbol="i"},
				TensorIndex{lower=true, symbol="J"},
				TensorIndex{lower=true, derivative=",", symbol="b"}
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
			TensorRef(
				var("\\beta"),
				TensorIndex{lower=false, symbol="I"}
			) *
			(
				Constant(1) /
				var("\\bar{\\gamma}")
			)
		)
	)
)


return {
--	{dt_alpha_def = dt_alpha_def},
--	{dt_beta_u_def = dt_beta_u_def},
--	{dt_W_def = dt_W_def},
--	{dt_K_def = dt_K_def},
--	{dt_epsilonBar_ll_def = dt_epsilonBar_ll_def},
--	{dt_ABar_ll_def = dt_ABar_ll_def},
--	{dt_LambdaBar_u_def = dt_LambdaBar_u_def},
--	{dt_B_u_def = dt_B_u_def},
--
--	{dt_alpha_norm_def = dt_alpha_norm_def},
--	{dt_beta_U_norm_def = dt_beta_U_norm_def},
--	{dt_B_U_norm_def = dt_B_U_norm_def},
--	{dt_W_norm_def = dt_W_norm_def},
--	{dt_K_norm_def = dt_K_norm_def},
--	{dt_epsilonBar_LL_norm_def = dt_epsilonBar_LL_norm_def},
--	{dt_ABar_LL_norm_def = dt_ABar_LL_norm_def},
	{dt_LambdaBar_U_norm_def = dt_LambdaBar_U_norm_def},
}

