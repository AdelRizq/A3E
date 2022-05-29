%{ 
    #include<string.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include <stdbool.h>

    void yyerror(char *s);
    int yywrap();
    int yylex();

    void insert(bool is_init, bool is_const, char type);
    int is_duplicated(char *name);
    void init_var();
    void open_scope();
    void close_scope();
    void insert_data_type();

    void printSymbolTable();

    void check_declaration();

    extern int line_num;

    struct  dataType{
        char *name, *value, *dataType;
        char type;
        bool is_initizalized, is_const;
        int token_scope;
        int par_scopes[10];
        int line_no;
    }; 
    struct dataType symbolTable[100];

    char *dtype, *yytext;
    int current_scope_idx = 0, next_scope = 2;

    int scopes_stack[100];
    char errors[50][100];
    int error_count = 0;
%}

%union {
    int INTGR;
    char *STR;
    char *ID;
    float FLT;
    int bval;
}

%token <INTGR> INTEGER
%token <FLT> FLOAT 
%token <STR> STRING 
%token <ID> VARIABLE
%token <bval> BOOLEAN
%token NOT AND OR XOR
%token GE LE EQ NE '>' '<'
%token INTTYPE BOOLTYPE STRINGTYPE FLOATTYPE CONST
%token IF ELSE WHILE REPEAT UNTIL FOR PRINT ENDIF
%token SWITCH CASE DEFAULT BREAK 

/* %nonassoc ENDIF 
%nonassoc ELSE */

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
    '{' '}'
    | '{' {open_scope();} statement_list '}' {close_scope();}
    ;
    
statement_list: 
    statement 
    | block
    | statement_list statement
    | statement_list block
    ;

statement: 
    PRINT {insert(false, false, 'K');} expr ';' 

    | var_definition ';'
    | declared_var '=' expr ';' {init_var();}

    | WHILE {insert(false, false, 'K');} '(' expr ')' body 
    | REPEAT {insert(false, false, 'K');} body UNTIL {insert(false, false, 'K');} '(' expr ')' ';'
    | FOR {insert(false, false, 'K');} for_header  for_body
    
    | IF {insert(false, false, 'K');}  '(' expr ')' body else

    | BREAK {insert(false, false, 'K');} ';'

    | SWITCH {insert(false, false, 'K');} '(' declared_var ')' '{' case_list '}'

    | ';'
    ; 

else:
    ELSE {insert(false, false, 'K');} body
    | ENDIF {insert(false, false, 'K');} ';'
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
    BOOLEAN {insert(false, false, 'C');}
    | INTEGER {insert(false, false, 'C');}
    | FLOAT {insert(false, false, 'C');}
    | STRING {insert(false, false, 'C');}

var_definition:
    type VARIABLE {insert(false, false, 'V'); }
    | CONST type VARIABLE {insert(false, true, 'V'); }
    | type VARIABLE  {insert(true, false, 'V'); } '=' expr 
    | CONST type VARIABLE  {insert(true, true, 'V'); } '=' expr
    ;

for_var:
    var_definition
    | declared_var '=' expr {init_var();}
    |
    ;

for_cond:
    expr
    |
    ;

for_expr:
    declared_var '=' expr {init_var();}
    |
    ;

case_list: 
    case_list case_statement
    | 
    ;

case_statement:
    CASE {insert(false, false, 'K');} case_switch_val ':' body 
    | DEFAULT {insert(false, false, 'K');} ':' body 
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
    | declared_var
    ; 
declared_var:
    VARIABLE {check_declaration();}
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

    for(int i=0;i<error_count;i++) {
        printf("%s\n", errors[i]);
    }

    return 0; 
}

void insert_data_type() {
    dtype=strdup(yytext);
}

void insert(bool is_init, bool is_const, char type) {
    int dup_idx = type == 'V' ? is_duplicated(yylval.ID):0;

    if(type != 'V' || !dup_idx) {
        struct dataType *entry = &symbolTable[sym_table_idx];
        if(type == 'V') {
            entry->name = strdup(yylval.ID);
            entry->dataType = dtype;
        } else {
            entry->name = strdup(yytext);
            entry->dataType = strdup("N/A");
        }

        entry->type = type;
        entry->is_initizalized = is_init;
        entry->is_const = is_const;
        entry->line_no = line_num;
        entry->token_scope = scopes_stack[current_scope_idx];

        for(int i=0;i<=current_scope_idx;i++) {
            entry->par_scopes[i] = scopes_stack[i];
        }

        sym_table_idx ++;
    } else {
        sprintf(errors[error_count++], "Line %d: Variable \"%s\" already declared at line %d\n", line_num, yylval.ID, symbolTable[dup_idx-1].line_no);
    }   
}


void init_var() {
    int idx = is_duplicated(yytext)-1;
    symbolTable[idx].is_initizalized = true;
}

void open_scope() {
    current_scope_idx ++;
    scopes_stack[current_scope_idx] = next_scope++;
}

void close_scope() {
    current_scope_idx --;
}

int is_duplicated(char *name) {
	for(int i=sym_table_idx-1; i>=0; i--) {
		if(strcmp(symbolTable[i].name, strdup(name))==0 && symbolTable[i].token_scope == scopes_stack[current_scope_idx]) {
			return i+1;
		}
	}
	return 0;
}

void printSymbolTable() {
    // write symbol table to file
    FILE *fp = fopen("symbol_table.txt", "w");
    if(fp == NULL) {
        printf("Error opening file!\n");
        exit(1);
    }

    fprintf(fp, "\nName\tData Type\tScope\tType\tLine\tConst\tInitialized \n");

    for(int i=0; i<sym_table_idx; i++) {
        struct dataType *entry = &symbolTable[i];

        fprintf(fp, "%4s\t%9s\t%5d\t%4c\t%4d\t%3d\t%10d\n", entry->name, entry->dataType, entry->token_scope, entry->type, entry->line_no,entry->is_const, entry->is_initizalized); 
    }
}


void check_declaration() {
    bool error_flag = true;
    for(int i=0;i<sym_table_idx && error_flag; i++) {
        if(strcmp(symbolTable[i].name, strdup(yytext))==0) {
            for(int j=0;j<=current_scope_idx && error_flag; j++) {
                if(symbolTable[i].token_scope == scopes_stack[j]) {
                    error_flag = false;
                }
            }
        }
    }

    if(error_flag) {
        sprintf(errors[error_count++], "Line %d: Variable \"%s\" not declared before usage!\n", line_num, yytext);
    }
}
