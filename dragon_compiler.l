%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "dragon_compiler.tab.h"
%}

%% 

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

[()<>=;{}\n] { 
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

%%

int yywrap(void) { 
    printf("Exausted ya beh");
    return 1; 
} 
