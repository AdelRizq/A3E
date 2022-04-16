%{
    #include <stdio.h>
%}

%% 


[a-zA-Z_][a-zA-Z0-9_]* { 
    /* VARIABLES - IDENTIFIERS*/
    printf("Variable: %s\n", yytext);
    // yylval.iValue = yytext;
    // return VARIABLE; 
} 
    
[0-9]+ { 
    /* CONSTANTS - NUMBERS*/
    printf("Number: %s\n", yytext); 
    // yylval.iValue = atoi(yytext); 
    // return NUMBER; 
}

\"[^\"]*\" { 
    /* STRINGS */
    printf("String: %s\n", yytext); 
    // yylval.iValue = yytext; 
    // return STRING; 
}

[+-/*] { 
    /* MATHEMATICAL OPERATORS */
    printf("Operator: %s\n", yytext); 
    // return OPERATOR; 
}

[()<>=;{}] { 
    /* Brackets and others */
    printf("Brackets, equal and semicolon: %s\n", yytext); 
    return *yytext; 
}

[ \t\n]* { 
    /* Whitespace */
    printf("Whitespaces: %s\n", yytext); 
    // return *yytext; 
}


%%

int yywrap(void) { 
    printf("Exausted ya beh");
    return 1; 
} 

int main(int argc, char *argv[]) { 
    yyin = fopen(argv[1], "r"); 
    yylex(); 
    fclose(yyin); 
}