%{ 
    #include<string.h>
    #include <stdbool.h>
    #include<ctype.h>

    void insert(bool is_init, bool is_const, char *type);
    int is_exist(char *name);
    void init_var();
    void open_scope();
    void close_scope();
    void insert_data_type();

    void printSymbolTable();

    void yyerror(char *s);
    int yywrap();

    extern int yylex();
    extern int line_num;

    struct  dataType{
        char *type, *name, *value, *dataType;
        bool is_initizalized, is_const;
        int token_scope;
        int par_scopes[10];
        int line_no;
    }; 
    struct dataType symbolTable[100];

    char *dtype;
    int current_scope_idx = 0, next_scope = 2;

    int scopes_stack[100];
%}

%union {
    int INTGR;
    char * STRNG;
    float FLT;
    char CHR;
}

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

%%

program: 
    | statement_list
    ; 

block: 
    '{' {open_scope();} '}' {close_scope();}
    | '{' {open_scope();} statement_list '}' {close_scope();}
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
    | VARIABLE '=' expr ';' {init_var();}

    | WHILE '(' expr ')' body 
    | REPEAT body UNTIL '(' expr ')' ';'
    | FOR for_header  for_body
    
    | IF '(' expr ')' body %prec ENDIF 
    | IF '(' expr ')' body ELSE body 

    | BREAK ';'

    | SWITCH '(' VARIABLE ')' '{' case_list '}'

    | ';'
    ; 

for_body:
    statement
    | {next_scope--;} block 
    ; 

body:
    statement
    | block 
    ; 

for_header:
    '(' {open_scope();} for_var ';' for_cond ';' for_expr ')' {close_scope();}

type:
    INTTYPE { insert_data_type(); }
    | BOOLTYPE { insert_data_type(); }
    | STRINGTYPE { insert_data_type(); }
    | FLOATTYPE { insert_data_type(); }

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
    | VARIABLE '=' expr {init_var();}
    |
    ;

for_cond:
    expr
    |
    ;

for_expr:
    VARIABLE '=' expr {init_var();}
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
int sym_table_idx = 0;

void yyerror(char *s) { 
    fprintf(stderr, "%s\n", s);
    return; 
} 

int main() {  
    scopes_stack[0] = 1;
    yyparse();
    printSymbolTable();
    return 0; 
}

void insert_data_type() {
    strcpy(dtype, yytext);
}

void insert(bool is_init, bool is_const, char *type) {
    bool in_table = is_exist(yytext);
    if(in_table) {
        yyerror("Variable already exists");
    } else {
        struct dataType *entry = &symbolTable[sym_table_idx];
        entry->name = yytext;
        entry->dataType = dtype;
        entry->is_const = is_const;
        entry->line_no = line_num;
        entry->type = type;
        entry->is_initizalized = is_init;
        entry->token_scope = scopes_stack[current_scope_idx];

        for(int i=0;i<=current_scope_idx;i++) {
            entry->par_scopes[i] = scopes_stack[i];
        }

        strcpy(dtype, (char *) "N/A");
        sym_table_idx ++;
    }    
}

void init_var() {
    int idx = is_exist(yytext)-1;
    symbolTable[idx].is_initizalized = true;
}

void open_scope() {
    current_scope_idx ++;
    scopes_stack[current_scope_idx] = next_scope++;
}

void close_scope() {
    current_scope_idx --;
}

int is_exist(char *name) {
	for(int i=sym_table_idx-1; i>=0; i--) {
		if(strcmp(symbolTable[i].name, name)==0 && symbolTable[i].token_scope == scopes_stack[current_scope_idx]) {
			return i+1;
		}
	}
	return 0;
}

void printSymbolTable() {
    printf("\nName\tData Type\tScope\tType\tLine\tConst\tInitialized \n");

    for(int i=0; i<sym_table_idx; i++) {
        struct dataType *entry = &symbolTable[sym_table_idx];
        printf("%s\t%s\t%d\t%s\t%d\t%d\t%d\n", entry->name, entry->dataType, entry->token_scope, entry->type, entry->line_no, entry->is_const, entry->is_initizalized);
    }
}