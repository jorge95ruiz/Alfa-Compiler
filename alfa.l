%{

 /* Includes */
 #include "alfa.h"
#include "y.tab.h"

#include <stdio.h>
#define  TOK_ERROR -1
extern FILE* fichero_salida;
int numero_linea=1, numero_caracter=1, error_morfologico =0;  



%}



%option noyywrap


%%

"//".*	{numero_caracter=1;}
"main" 	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_MAIN; }

"int"	{numero_caracter+=yyleng;
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		 return TOK_INT;}
"boolean" {numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_BOOLEAN; }

"array" 	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_ARRAY; }

"function" 	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_FUNCTION; }

"if" 	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_IF;}

"else" 	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_ELSE;}

"while" 	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_WHILE;}

"scanf"	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_SCANF;}

"printf"	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_PRINTF;}

"return"	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_RETURN;}



[ \t\r]* 	{numero_caracter+=yyleng;}
"\n"		{numero_linea++; numero_caracter=1;} 
";"		{numero_caracter+=yyleng; return TOK_PUNTOYCOMA; }
","		{numero_caracter+=yyleng; return TOK_COMA; }
"("		{numero_caracter+=yyleng; return TOK_PARENTESISIZQUIERDO;}
")"		{numero_caracter+=yyleng; return TOK_PARENTESISDERECHO;}
"["		{numero_caracter+=yyleng; return TOK_CORCHETEIZQUIERDO;}
"]"		{numero_caracter+=yyleng; return TOK_CORCHETEDERECHO;}
"{"		{numero_caracter+=yyleng; return TOK_LLAVEIZQUIERDA;}
"}"		{numero_caracter+=yyleng; return TOK_LLAVEDERECHA;}
"=="	{numero_caracter+=yyleng; return TOK_IGUAL;}
"="		{numero_caracter+=yyleng; return TOK_ASIGNACION;}
"+"		{numero_caracter+=yyleng; return TOK_MAS;}
"-"		{numero_caracter+=yyleng; return TOK_MENOS;}
"/"		{numero_caracter+=yyleng; return TOK_DIVISION;}
"*"		{numero_caracter+=yyleng; return TOK_ASTERISCO;}
"&&"	{numero_caracter+=yyleng; return TOK_AND;}
"||"	{numero_caracter+=yyleng; return TOK_OR;}
"!="	{numero_caracter+=yyleng; return TOK_DISTINTO;}
"!"		{numero_caracter+=yyleng; return TOK_NOT;}
"<="	{numero_caracter+=yyleng; return TOK_MENORIGUAL;}
">="	{numero_caracter+=yyleng; return TOK_MAYORIGUAL;}
"<"		{numero_caracter+=yyleng; return TOK_MENOR;}
">"		{numero_caracter+=yyleng; return TOK_MAYOR;}


"true" 	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_TRUE;}

"false" {numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_FALSE;}

[A-Za-z]([A-Za-z0-9])*	{numero_caracter+=yyleng; 
		strcpy(yylval.atributos.lexema, yytext);
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		return TOK_IDENTIFICADOR ;}



[0-9]+	{numero_caracter+=yyleng; 
		fprintf(fichero_salida," ; D: <%s> \n", yytext);
		yylval.atributos.valor_entero = atoi(yytext);
		return TOK_CONSTANTE_ENTERA;}



.	{numero_caracter+=yyleng; 
	printf("Error Morfologico \n");
	error_morfologico =1;
	return TOK_ERROR;}
	


%%
