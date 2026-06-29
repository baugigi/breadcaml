all:
	# Create the executable ppx_petscii
	ocamlc -I +compiler-libs ocamlcommon.cma c64_petscii.ml ppx_petscii.ml -o ppx_petscii
	# Output the original source
	cat sample_input.ml
	# Output the modified source
	ocamlc -dsource -ppx ./ppx_petscii sample_input.ml -c
	# Compile with ppx extension
	ocamlc -ppx ./ppx_petscii sample_input.ml -o test
	# Run the program
	./test

clean:
	rm -f *cmo *cmi test ppx_petscii *~
