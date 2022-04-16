%token INTEGER VARIABLE BOOLEAN STRING 
%token NOT AND OR XOR

%left '^'
%left "&&" "||"
%left '+' '-'
%left '*' '/'
%left '!'

%{ 
    #include <stdio.h>

    void yyerror(char *); 
    int yylex(void); 
%}

%%

program: 
    program statement '\n' 
    | 
    ; 

statement: 
    expr ';'
    | VARIABLE '=' expr ';'
    | VARIABLE '=' STRING ';'
    | VARIABLE '=' bool ';'
    ;

expr:
    INTEGER 
    | VARIABLE 
    | expr '+' expr { $$ = $1 + $3; } 
    | expr '-' expr { $$ = $1 - $3; } 
    | expr '*' expr { $$ = $1 * $3; } 
    | expr '/' expr { $$ = $1 / $3; } 
    | '(' expr ')' { $$ = $2; }
    ; 

bool: 
    BOOLEAN
    | NOT bool { $$ = !$2; }
    | bool OR bool { $$ = $1 || $3; }
    | bool XOR bool { $$ = $1 ^ $3; }
    | bool AND bool { $$ = $1 && $3; }
    | '(' bool ')' { $$ = $2; } 
    ;

%%

void yyerror(char *s) { 
    fprintf(stderr, "%s\n", s);
    return; 
} 

int main() {  
    yyparse();
    return 0; 
}