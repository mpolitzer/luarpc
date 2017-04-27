interface {
	name = "inttestes",
	methods = {
		foo = {
			resulttype = "double",
			args = {
				{ direction = "in",  type = "double"},
				{ direction = "in",  type = "double"},
				{ direction = "inout", type = "double"},
			}

		},
		bar = {
			resulttype = "void",
			args = {
			}
		},
		boo = {
			resulttype = "double",
			args = {
				{ direction = "in", type = "string"},
			}
		}
	}
}
