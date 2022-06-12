%{
    #include<string.h>
    #include "a3e.tab.h"

    int line_num=1;
%}

%% 

"if" return IF;
"else" return ELSE;
"endif" return ENDIF;

"for" return FOR;
"while" return WHILE;

"case" return CASE;
"break" return BREAK;
"switch" return SWITCH;
"default" return DEFAULT;

"repeat" return REPEAT;
"until" return UNTIL;

"print" return PRINT; 

"int" return INTTYPE;
"const" return CONST;
"bool" return BOOLTYPE;
"string" return STRINGTYPE;
"float" return FLOATTYPE;


[0-9]+ { 
    printf("Integer: %s - line %d\n", yytext, line_num); 
    yylval.INTGR = atoi(yytext);
    return INTEGER; 
}

[0-9]+\.[0-9]+ {
    printf("Float: %s - line %d\n", yytext, line_num);
    yylval.FLT = atof(strdup(yytext));
    return FLOAT;
}

(true|false) {
    printf("Boolean: %s - line %d\n", yytext, line_num);
    yylval.bval = yytext[0] == 't';
    return BOOLEAN;
}

\"[^\"]*\" { 
    printf("String: %s - line %d\n", yytext, line_num);
    yylval.STR = strdup(yytext);
    return STRING; 
}

[a-zA-Z_][a-zA-Z0-9_]* { 
    printf("Variable: %s - line %d\n", yytext, line_num);
    yylval.ID = strdup(yytext);
    return VARIABLE; 
} 

[/+*%-] { 
    printf("Operator: %s - line %d\n", yytext, line_num);
    return *yytext;
}

[()<>=;{}:] { 
    printf("Others: %s - line %d\n", yytext, line_num);
    return *yytext; 
}

\n line_num++;
\r ;
\t ;
" " ;

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
    return 1; 
} 
