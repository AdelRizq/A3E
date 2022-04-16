%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "dragon_compiler.tab.h"
%}

%% 

"if" return IF;
"else" return ELSE;
"endif" return ENDIF;

"do" return DO;
"for" return FOR;
"while" return WHILE;

"case" return CASE;
"break" return BREAK;
"switch" return SWITCH;
"default" return DEFAULT;

"print" return PRINT; 

"int" return INTTYPE;
"const" return CONST;
"bool" return BOOLTYPE;
"string" return STRINGTYPE;


-?[0-9]+ { 
    printf("Integer: %s\n", yytext); 
    // yylval.iValue = atoi(yytext); 
    return INTEGER; 
}

(true|false) {
    printf("Boolean: %s\n", yytext);
    // yylval.iValue = atoi(yytext);
    return BOOLEAN;
}

\"[^\"]*\" { 
    printf("String: %s\n", yytext); 
    // yylval.iValue = yytext; 
    return STRING; 
}

[a-zA-Z_][a-zA-Z0-9_]* { 
    printf("Variable: %s\n", yytext);
    // yylval.iValue = yytext;
    return VARIABLE; 
} 

[+-/*] { 
    printf("Operator: %s\n", yytext); 
    // return OPERATOR; 
    return *yytext;
}

[()<>=;{}:\n] { 
    printf("Others: %s\n", yytext); 
    return *yytext; 
}

[ \t] { 
    /* Skip Whitespaces and Tabs */
    // printf("Whitespaces: %s\n", yytext); 
    // return *yytext; 
}

"!" return NOT;
"^" return XOR;
"||" return OR;
"&&" return AND;

">=" return GE; 
"<=" return LE; 
"==" return EQ; 
"!=" return NE;

%%

int yywrap(void) { 
    printf("Exhausted ya beh");
    return 1; 
} 