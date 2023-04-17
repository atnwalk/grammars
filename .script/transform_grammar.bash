
for f in ../antlr4/*;
do
  FILE_BASE=$(basename "${f%.*}")
  python antlr_to_generic.py "${f}" | python generic_to_nautilus.py > ../nautilus/${FILE_BASE}.py
done

function gramatron() {
  f=$1
  limit=$2
  FILE_BASE=$(basename "${f%.*}")
  python antlr_to_generic.py "${f}" | python generic_to_gramatron.py > ../gramatron/"${FILE_BASE}.json"
  python to_gnf.py ../gramatron/"${FILE_BASE}.json" > "${FILE_BASE}_gnf.json"
  python construct_automata.py --gf "${FILE_BASE}_gnf.json" --limit ${limit}
  cp ${FILE_BASE}_gnf_automata.json ../gramatron/${FILE_BASE}_automata.json
#  cat ${FILE_BASE}_gnf_automata.json | python fix_pda.py > ../gramatron/${FILE_BASE}_automata.json
}

gramatron ../antlr4/JavaScript.g4 4
gramatron ../antlr4/Lua.g4 3
gramatron ../antlr4/Php.g4 10
gramatron ../antlr4/SQLite.g4 7
gramatron ../antlr4/Ruby.g4 13
