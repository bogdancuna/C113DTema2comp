%{
	#include "y.tab.h"
%}

INT [0-9]*
ID [a-zA-Z][a-zA-Z0-9_]*

%%

[ \t\n\r]+			;
";"			{ return ';'; }
":"			{ return ':'; }
","			{ return ','; }
"."			{ return '.'; }
PROGRAM			{ return T_PROGRAM; }
VAR			{ return T_VAR; }
BEGIN			{ return T_BEGIN; }
END			{ return T_END; }
INTEGER			{ return T_INTEGER; }
READ			{ return T_READ; }
WRITE			{ return T_WRITE; }
FOR			{ return T_FOR; }
DO			{ return T_DO; }
TO 			{ return T_TO; }
"+"			{ return T_PLUS; }
"-"			{ return T_MINUS; }
"*"			{ return T_MUL; }
DIV			{ return T_DIV; }
{INT}			{ yylval.val = atoi(yytext); return T_INT; }
{ID}			{ yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir,yytext); return T_ID; }
":="			{ return T_ATTR; }
"("			{ return '('; }
")"			{ return ')'; }
.			{ return T_ERR; }

%%