%{ 
    #include<string.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <ctype.h>
    #include <stdbool.h>
    #include <sys/types.h>
    #define YYERROR_VERBOSE

    int mkdir(const char *pathname, mode_t mode);

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
    void check_initialized();
    void check_const();
    void checkDefualtNums();

    void set_used();

    // Quads helper functions
    void push();
    void pushVal(char *val);
    void pop(char *dst);
    void quad1OperandGen(char *opr);
    void quad2OperandsGen(char *opr);

    // Labels helper methods
    void addLabel();
    void popLabels(int num);
    void JZ(bool addLabelFlag);
    void JMP(bool addLabelFlag, int labelOffset);
    void printLabel(bool addLabelFlag, int labelOffset);
    void JMPBREAK();

    // type functions
    struct nodeType* intNode(); 
    struct nodeType* floatNode();
    struct nodeType* boolNode();
    struct nodeType* stringNode();

    struct nodeType* dupNode(struct nodeType* node, struct nodeType* type);

    struct nodeType* getVarType(char* id);

    struct nodeType* checkType(struct nodeType *op1, struct nodeType *op2, char *op);
    struct nodeType* checkNotType(struct nodeType *op1);
    void checkConditionType(struct nodeType* node);
    
    extern int line_num;

    struct dataType {
        char *name, *value, *dataType;
        char type;
        bool is_initizalized, is_const, is_used;
        int token_scope;
        int par_scopes[10];
        int line_no;
    }; 
    struct dataType symbolTable[1000];

    char *dtype, *yytext, *varType;
    int current_scope_idx = 0, next_scope = 2;

    int scopes_stack[1000];
    char errors[500][100];
    int error_count = 0;

    int quadTop = 0;
    char quadStack[1000][20];

    char quads[1000][100];
    int quadCount = 0;

    int regCount = 0;

    int labelCount = 0;
    int labelTop = 0;
    char labelStack[1000][20];

    int defualtNumStack[200];
    int defualtNumTop = 0;

    struct nodeType {
        char *type;              /* type of node */
        char *expr_type;
    };

    char *switchCaseVar = NULL;
%}

%union {
    int INTGR;
    char *STR;
    char *ID;
    float FLT;
    int bval;

    struct nodeType* node_type;
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

%type <node_type> expr value declared_var var_definition type

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
    | statement_list error 
    | error
    ;

statement: 
    PRINT {insert(false, false, 'K');} expr ';' 

    | var_definition ';'
    | declared_var {check_const(); strcpy(quadStack[quadTop++], yylval.ID);} '=' expr ';' {init_var(); pop(quadStack[quadTop-2]);}

    | WHILE {insert(false, false, 'K'); printLabel(true, 1); } '(' expr ')' {JZ(true);} body {JMP(false, 2); printLabel(false, 1); popLabels(2); checkConditionType($4);}
    | REPEAT {insert(false, false, 'K'); printLabel(true, 1); } body UNTIL {insert(false, false, 'K');} '(' expr ')' ';' {JZ(false); popLabels(1); checkConditionType($7);}
    | FOR {insert(false, false, 'K');} for_header  for_body { JMP(false, 2); printLabel(false, 1); popLabels(2);}
    
    | IF {insert(false, false, 'K');} '(' expr ')' {JZ(true);} body else {checkConditionType($4);}

    | BREAK {insert(false, false, 'K');} ';' {JMPBREAK();}

    | SWITCH {insert(false, false, 'K');} '(' declared_var {check_initialized(); set_used(); switchCaseVar = strdup(yytext);} ')' '{' {open_scope(); defualtNumStack[defualtNumTop++]=0;} case_list '}' {checkDefualtNums(); close_scope();}

    | ';'
    ; 

else:
    {JMP(true, 1); printLabel(false, 1);} ELSE {insert(false, false, 'K');} body {printLabel(false, 1); popLabels(2);}
    | ENDIF {insert(false, false, 'K');} ';' {printLabel(false, 1); popLabels(1);}
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
    '(' {open_scope();} for_var ';' { printLabel(true, 1); } for_cond {JZ(true);} ';' for_expr ')' {close_scope();}

type:
    INTTYPE { insert_data_type(); $$=intNode();}
    | BOOLTYPE { insert_data_type(); $$=boolNode();}
    | STRINGTYPE { insert_data_type(); $$=stringNode();}
    | FLOATTYPE { insert_data_type(); $$=floatNode();}

value:
    BOOLEAN {insert(false, false, 'C'); push(); $$=boolNode();}
    | INTEGER {insert(false, false, 'C'); push(); $$=intNode();}
    | FLOAT {insert(false, false, 'C'); push(); $$=floatNode();}
    | STRING {insert(false, false, 'C'); push(); $$=stringNode();}

var_definition:
    type VARIABLE {insert(false, false, 'V'); }
    | type VARIABLE  {insert(true, false, 'V'); strcpy(quadStack[quadTop++], yylval.ID);} '=' expr {pop(quadStack[quadTop-2]); $$ = dupNode($5, $1);}
    | CONST type VARIABLE  {insert(true, true, 'V'); strcpy(quadStack[quadTop++], yylval.ID);} '=' expr {pop(quadStack[quadTop-2]); $$ = dupNode($6, $2);}
    ;

for_var:
    |var_definition
    | declared_var {check_const(); strcpy(quadStack[quadTop++], yylval.ID);} '=' expr {init_var(); pop(quadStack[quadTop-2]);};

for_cond:
    |expr {checkConditionType($1);};

for_expr:
    |declared_var {check_const(); strcpy(quadStack[quadTop++], yylval.ID);} '=' expr {init_var(); pop(quadStack[quadTop-2]); };

case_list: 
    case_list case_statement
    | 
    ;

case_statement:
    CASE {insert(false, false, 'K');} case_switch_val {pushVal(switchCaseVar); push(); sprintf(quads[quadCount++], "EQ %s, %s", quadStack[quadTop-2], quadStack[quadTop-1]);} ':' {JZ(true);} body {printLabel(false, 1);}
    | DEFAULT {insert(false, false, 'K');} ':' body {defualtNumStack[defualtNumTop-1]++;}
    ;

case_switch_val: 
    INTEGER | STRING | BOOLEAN;

expr:
    value { $$ = $1; }
    | NOT expr {quad1OperandGen("!"); $$ = checkNotType($2);}
    | expr OR  expr {quad2OperandsGen("||"); $$ = checkType($1, $3, "||");}
    | expr XOR expr {quad2OperandsGen("^"); $$ = checkType($1, $3, "^");}
    | expr AND expr {quad2OperandsGen("&&"); $$ = checkType($1, $3, "&&");}
    | expr GE  expr {quad2OperandsGen(">="); $$ = checkType($1, $3, ">=");}
    | expr LE  expr {quad2OperandsGen("<="); $$ = checkType($1, $3, "<=");}
    | expr EQ  expr {quad2OperandsGen("=="); $$ = checkType($1, $3, "==");}
    | expr NE  expr {quad2OperandsGen("!="); $$ = checkType($1, $3, "!=");}
    | expr '+' expr {quad2OperandsGen("+"); $$ = checkType($1, $3, "+");}
    | expr '-' expr {quad2OperandsGen("-"); $$ = checkType($1, $3, "-");}
    | expr '*' expr {quad2OperandsGen("*"); $$ = checkType($1, $3, "*");}
    | expr '/' expr {quad2OperandsGen("/"); $$ = checkType($1, $3, "/");}
    | expr '%' expr {quad2OperandsGen("%"); $$ = checkType($1, $3, "%");}
    | expr '>' expr {quad2OperandsGen(">"); $$ = checkType($1, $3, ">");}
    | expr '<' expr {quad2OperandsGen("<"); $$ = checkType($1, $3, "<");}
    | '(' expr ')' { $$ = $2; }
    | declared_var {check_initialized(); set_used(); push(); $$ = $1;}
    ; 

declared_var:
    VARIABLE {check_declaration(); $$ = getVarType(yylval.ID);}
    ;
%%
int sym_table_idx = 0;

void yyerror(char *s) { 
    sprintf(errors[error_count++],"Line %d: %s\n",line_num, s);
} 

int main() {  
    // create output folder if not exists
    mkdir("output", 0777);

    scopes_stack[0] = 1;
    yyparse();
    printSymbolTable();

    for(int i=0; i<sym_table_idx; i++) {
        if(symbolTable[i].type == 'V' && symbolTable[i].is_used == false) {
            sprintf(errors[error_count++], "Line %d: Variable \"%s\" is not used\n", symbolTable[i].line_no, symbolTable[i].name);
        } 
    }

    FILE *fp = fopen("output/errors.txt", "w");
    if(fp == NULL) {
        printf("Error opening output/errors.txt file!\n");
        exit(1);
    }

    for(int i=0;i<error_count;i++) {
        fprintf(fp, "%s", errors[i]);
    }

    fclose(fp);

    // print quadruples to file
    FILE *fp2 = fopen("output/quads.txt", "w");
    if(fp2 == NULL) {
        printf("Error opening output/quads.txt file!\n");
        exit(1);
    }
    
    for (int i=0; i<quadCount; i++) {
        fprintf(fp2, "%s\n", quads[i]);
    }
    
    fclose(fp2);

    return 0; 
}
//------------------------------------------------------------------------------- 
// Symbol Table functions
//------------------------------------------------------------------------------- 
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
    sprintf(quads[quadCount++], "B%d:", scopes_stack[current_scope_idx]);
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
    FILE *fp = fopen("output/symbol_table.txt", "w");
    if(fp == NULL) {
        printf("Error opening symbol_table.txt file!\n");
        exit(1);
    }

    fprintf(fp, "\nName\tData Type\tScope\tType\tLine\tConst\tInitialized \n");

    for(int i=0; i<sym_table_idx; i++) {
        struct dataType *entry = &symbolTable[i];

        fprintf(fp, "%4s\t%9s\t%5d\t%4c\t%4d\t%3d\t%10d\n", entry->name, entry->dataType, entry->token_scope, entry->type, entry->line_no,entry->is_const, entry->is_initizalized); 
    }
}

//------------------------------------------------------------------------------- 
// Errors checking functions
//------------------------------------------------------------------------------- 
void check_declaration() {
    bool error_flag = true;
    bool found = false;

    for(int i=0;i<sym_table_idx && error_flag; i++) {
        if(strcmp(symbolTable[i].name, yytext)==0) {
            found = true;
            for(int j=0;j<=current_scope_idx && error_flag; j++) {
                if(symbolTable[i].token_scope == scopes_stack[j]) {
                    error_flag = false;
                }
            }
        }
    }

    if(found) {
        if(error_flag) {
            sprintf(errors[error_count++], "Line %d: Variable \"%s\" used out of scope\n", line_num, yytext);
        }
    } else {
        sprintf(errors[error_count++], "Line %d: Variable \"%s\" used without declaration\n", line_num, yytext);
    }
}

void check_initialized() {
    for(int i=sym_table_idx-1;i>=0;i--) {
        if(strcmp(symbolTable[i].name, yytext)==0) {
            if(symbolTable[i].is_initizalized == false) {
                sprintf(errors[error_count++], "Line %d: Variable \"%s\" used without initialization\n", line_num, yytext);
            }
        }
    }
}

void set_used() {
    for(int i=sym_table_idx-1;i>=0;i--) {
        if(strcmp(symbolTable[i].name, yytext)==0) {
            symbolTable[i].is_used = true;
            break;
        }
    }
}

void check_const() {
    int idx = is_duplicated(yytext)-1;
    if(symbolTable[idx].is_const) {
        sprintf(errors[error_count++], "Line %d: Variable \"%s\" is a constant\n", line_num, yytext);
    }
}

void checkDefualtNums() {
    if(defualtNumStack[defualtNumTop-1] == 0) {
        sprintf(errors[error_count++], "Line %d: missing default case\n", line_num, yytext);
    } else if (defualtNumStack[defualtNumTop-1] > 1) {
        sprintf(errors[error_count++], "Line %d: multiple default cases\n", line_num, yytext);
    }
    --defualtNumTop;
}
//------------------------------------------------------------------------------- 
// Quadruple functions
//-------------------------------------------------------------------------------  
void push() {
    strcpy(quadStack[quadTop++], yytext);
    sprintf(quads[quadCount++], "PUSH %s", yytext);
}

void pushVal(char *val) {
    strcpy(quadStack[quadTop++], val);
    sprintf(quads[quadCount++], "PUSH %s", val);
}

void pop(char *dst) {
    --quadTop;
    sprintf(quads[quadCount++], "POP %s", dst);
}

void quad1OperandGen(char *opr) {
    char *op1 = strdup(quadStack[quadTop-1]);

    --quadTop; // pop wihtout creating quad
    
    char tempReg[10];
    sprintf(tempReg, "R%d", regCount++);
    strcpy(quadStack[quadTop++], tempReg);
    
    if (strcmp(opr, "!") == 0) sprintf(quads[quadCount++], "NOT %s, %s", op1, quadStack[quadTop-1]);

}

void quad2OperandsGen(char *opr) {
    char *op1 = strdup(quadStack[quadTop-2]);
    char *op2 = strdup(quadStack[quadTop-1]);

    --quadTop; // pop wihtout creating quad
    --quadTop; // pop wihtout creating quad
    
    char tempReg[10];
    sprintf(tempReg, "R%d", regCount++);
    strcpy(quadStack[quadTop++], tempReg);
    
    if (strcmp(opr, "+") == 0)       sprintf(quads[quadCount++], "ADD %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "-") == 0)  sprintf(quads[quadCount++], "SUB %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "*") == 0)  sprintf(quads[quadCount++], "MUL %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "/") == 0)  sprintf(quads[quadCount++], "DIV %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "%") == 0)  sprintf(quads[quadCount++], "MOD %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "<") == 0)  sprintf(quads[quadCount++], "LT %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, ">") == 0)  sprintf(quads[quadCount++], "GT %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "^") == 0)  sprintf(quads[quadCount++], "XOR %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "<=") == 0) sprintf(quads[quadCount++], "LE %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, ">=") == 0) sprintf(quads[quadCount++], "GE %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "==") == 0) sprintf(quads[quadCount++], "EQ %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "!=") == 0) sprintf(quads[quadCount++], "NE %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "&&") == 0) sprintf(quads[quadCount++], "AND %s, %s, %s", op1, op2, quadStack[quadTop-1]);
    else if (strcmp(opr, "||") == 0) sprintf(quads[quadCount++], "OR %s, %s, %s", op1, op2, quadStack[quadTop-1]);
}

void popLabels(int num) {
    labelTop -= num;
}

void addLabel() {
    char tempLabel[10];
    sprintf(tempLabel, "L%d", ++labelCount);
    strcpy(labelStack[labelTop++], tempLabel);
}

void JZ(bool addLabelFlag) {
    if(addLabelFlag) {
        addLabel();
    }

    sprintf(quads[quadCount++], "JZ %s", labelStack[labelTop-1]);
}

void JMP(bool addLabelFlag, int labelOffset) {
    if(addLabelFlag) {
        addLabel();
    }

    sprintf(quads[quadCount++], "JMP %s", labelStack[labelTop-labelOffset]);
}

void JMPBREAK() {
    sprintf(quads[quadCount++], "JMP B%d", scopes_stack[current_scope_idx-1]);
}

void printLabel(bool addLabelFlag, int labelOffset) {
    if(addLabelFlag) {
        addLabel();
    }

    sprintf(quads[quadCount++], "%s:", labelStack[labelTop-labelOffset]);
}
//------------------------------------------------------------------------------- 
// Type checking functions 
//-------------------------------------------------------------------------------  
struct nodeType* intNode() {
    struct nodeType* p = malloc(sizeof(struct nodeType));;
    
	p->type = "int";
    return p;
}

struct nodeType* floatNode() {
    struct nodeType* p = malloc(sizeof(struct nodeType));;
    
    p->type = "float";
    return p;
}

struct nodeType* boolNode() {
    struct nodeType* p = malloc(sizeof(struct nodeType));;
    
    p->type = "bool";
    return p;
}

struct nodeType* stringNode() {
    struct nodeType* p = malloc(sizeof(struct nodeType));;
    
    p->type = "string";
    return p;
}

struct nodeType* checkType(struct nodeType *op1, struct nodeType *op2, char *op) {
    if (strcmp(op1->type, op2->type) != 0) {
        sprintf(errors[error_count++], "Line %d: type mismatch, operation %s cannot be done between %s and %s\n", line_num, op, op1->type, op2->type);
    }

    struct nodeType *p = malloc(sizeof(struct nodeType));
    
    if (strcmp(op, "+") == 0 || strcmp(op, "-") == 0 || strcmp(op, "*") == 0 || 
        strcmp(op, "/") == 0 || strcmp(op, "%") == 0 || strcmp(op, "^") == 0) 
        p->type = op1->type;
    else 
        p->type = "bool";

    return p;
}

struct nodeType* checkNotType(struct nodeType *op1) {
    if (strcmp(op1->type, "bool") != 0) {
        sprintf(errors[error_count++], "Line %d: type mismatch, not operation requires bool, not %s \n", line_num, op1->type);
    }

    struct nodeType *p = malloc(sizeof(struct nodeType));
    
    p->type = "bool";

    return p;
}

struct nodeType* dupNode(struct nodeType* node, struct nodeType* type) {

    if (strcmp(node->type, type->type) != 0) {
        sprintf(errors[error_count++], "Line %d: type mismatch, assignment cannot be %s to %s\n", line_num, node->type, type->type);
    }

    struct nodeType *p = malloc(sizeof(struct nodeType));
    p->type = node->type;
    return p;
}

struct nodeType* getVarType(char* id) {
    bool error_flag = true;

    int i;
    for(i = sym_table_idx - 1; i >= 0; i--) {
        if(strcmp(symbolTable[i].name, id) == 0) {
            for(int j = 0; j <= current_scope_idx && error_flag; j++) {
                if(symbolTable[i].token_scope == scopes_stack[j]) {
                    error_flag = false;
                }
            }
        }
        if (!error_flag) break;
    }

    struct nodeType *p = malloc(sizeof(struct nodeType));

    if (i < 0) {
        p->type = "undefined";
    } else {
        p->type = symbolTable[i].dataType;
    }
    
    return p;
}

void checkConditionType(struct nodeType* node) {
    if (strcmp(node->type, "bool") != 0) {
        sprintf(errors[error_count++], "Line %d: type mismatch, condition must be bool\n", line_num);
    }

    struct nodeType *p = malloc(sizeof(struct nodeType));
    
    p->type = "bool";
}
