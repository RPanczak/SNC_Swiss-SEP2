set scheme plotplain

preserve 

	* sample 1

	* https://www.stata.com/meeting/uk19/slides/uk19_newson.pdf
	somersd ssep ssepALT, taua transf(z) tdist
	scsomersd difference 0, transf(z) tdist

	baplot ssep2 ssep1

	concord ssep2 ssep1, summary loa(msize(vtiny))

	* batplot ssep ssepALT, info
	batplot ssep ssepALT, notrend info dp(0)

restore 

