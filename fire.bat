bison -d -t dragon_compiler.y
flex dragon_compiler.l
gcc lex.yy.c dragon_compiler.tab.c -o dragon_compiler
.\dragon_compiler < test.cpp

