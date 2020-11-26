


.PHONY: 

pdf:
	pdflatex --interaction=batchmode Rapport.tex #--interaction=batchmode ignore les erreurs de compilation
	#firefox Rapport.pdf &