%token INTEGER VARIABLE BOOLEAN STRING CONST

%token NOT AND OR XOR
%token GE LE EQ NE '>' '<'
%token INTTYPE BOOLTYPE STRINGTYPE

%token IF WHILE DO FOR PRINT
%nonassoc ENDIF 
%nonassoc ELSE

%left XOR
%left AND OR
%left '+' '-'
%left '*' '/'
%left NOT

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
    PRINT expr ';' 
    
    | int_def ';'
    | str_def ';'
    | bool_def ';'

    | WHILE '(' bool ')' statement 
    | DO statement WHILE '(' bool ')' ';'
    | FOR '(' int_def ';' VARIABLE '<' expr ';' VARIABLE '=' VARIABLE '+' INTEGER ')' statement
    
    | IF '(' bool ')' statement %prec ENDIF 
    | IF '(' bool ')' statement ELSE statement 
    | '{' statement_list '}' { $$ = $2; }
    ; 

statement_list: 
    statement { $$ = $1; } 
    | statement_list statement
    ;

int_def:
    VARIABLE '=' expr
    | INTTYPE VARIABLE '=' expr
    | CONST INTTYPE VARIABLE '=' expr

str_def:
    VARIABLE '=' STRING 
    | STRINGTYPE VARIABLE '=' STRING 
    | STRINGTYPE VARIABLE '=' VARIABLE 
    | CONST STRINGTYPE VARIABLE '=' STRING  
    | CONST STRINGTYPE VARIABLE '=' VARIABLE  

bool_def:
    | VARIABLE '=' bool 
    | BOOLTYPE VARIABLE '=' bool 
    | BOOLTYPE VARIABLE '=' VARIABLE 
    | CONST BOOLTYPE VARIABLE '=' bool 
    | CONST BOOLTYPE VARIABLE '=' VARIABLE 


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
    | expr GE expr { $$ = $1 >= $3; }
    | expr LE expr { $$ = $1 <= $3; }
    | expr EQ expr { $$ = $1 == $3; }
    | expr NE expr { $$ = $1 != $3; }
    | expr '>' expr { $$ = $1 > $3; }
    | expr '<' expr { $$ = $1 < $3; }
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