%token INTEGER FLOAT VARIABLE BOOLEAN STRING CONST

%token NOT AND OR XOR
%token GE LE EQ NE '>' '<'
%token INTTYPE BOOLTYPE STRINGTYPE FLOATTYPE

%token IF WHILE REPEAT UNTIL FOR PRINT
%token SWITCH CASE DEFAULT BREAK 

%nonassoc ENDIF 
%nonassoc ELSE

%right "="
%left XOR
%left OR
%left AND
%left EQ NE
%left GE LE '>' '<'
%left '+' '-'
%left '*' '/' '%'
%right NOT


%{ 
    #include <stdio.h>

    void yyerror(char *); 
    int yylex(void); 
%}

%%

program: 
    | statement_list
    ; 

block: 
    '{' '}'
    | '{' statement_list '}'
    ;
    
statement_list: 
    statement 
    | block
    | statement_list statement
    | statement_list block
    ;

statement: 
    PRINT expr ';' 

    | var_definition ';'
    | VARIABLE '=' expr ';'

    | WHILE '(' expr ')' body 
    | REPEAT body UNTIL '(' expr ')' ';'
    | FOR for_header body
    
    | IF '(' expr ')' body %prec ENDIF 
    | IF '(' expr ')' body ELSE body 

    | BREAK ';'

    | SWITCH '(' VARIABLE ')' '{' case_list '}'

    | ';'
    ; 

body:
    statement
    | block
    ; 

for_header:
    '(' for_var ';' for_cond ';' for_expr ')'

type:
    INTTYPE | BOOLTYPE | STRINGTYPE | FLOATTYPE

value:
    BOOLEAN | INTEGER | FLOAT | STRING

var_definition:
    type VARIABLE
    | CONST type VARIABLE
    | type VARIABLE '=' expr
    | CONST type VARIABLE '=' expr
    ;

for_var:
    var_definition
    | VARIABLE '=' expr
    |
    ;

for_cond:
    expr
    |
    ;

for_expr:
    VARIABLE '=' expr
    |
    ;

case_list: 
    case_list case_statement
    | 
    ;

case_statement:
    CASE case_switch_val ':' body 
    | DEFAULT ':' body 
    ;

case_switch_val: 
    INTEGER | STRING | BOOLEAN;

expr:
    value
    | NOT expr
    | expr OR expr 
    | expr XOR expr
    | expr AND expr 
    | expr GE expr 
    | expr LE expr 
    | expr EQ expr 
    | expr NE expr 
    | expr '+' expr  
    | expr '-' expr  
    | expr '*' expr  
    | expr '/' expr 
    | expr '%' expr
    | expr '>' expr
    | expr '<' expr 
    | '(' expr ')' 
    | VARIABLE
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