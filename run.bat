cd src
flex a3e.l
bison -d -t a3e.y
gcc lex.yy.c a3e.tab.c -o a3e
.\a3e < ../tests/full_rules.txt
cd ..
