%{ 

#include <stdio.h> 
#include <stdlib.h>
#include "tablasimbolos.h"
#include "alfa.h"





extern int yylex(void);
extern int numero_linea;
extern int numero_caracter;
FILE *fichero_salida;
extern int error_morfologico;
extern TablaSimbolos ts;
extern FILE *yyout;
extern FILE* yyin;
void yyerror(char*s);
Valor * aux_valor;
TablaSimbolos ts;
int tipo_actual, clase_actual, tamanio_vector_actual=0, pos_variable_local_actual_local_actual, num_variables_locales_actual=0, pos_variable_local_actual=0, num_parametros_actual=0
,pos_parametro_actual=1, categoria_actual=0, en_explist=0, num_parametros_llamada_actual; 
int posicion, iterador;
int llamada_dentro_funcion=0;
int salida_parser;
int etiqueta = 0;
int local = 0;
int fn_return = 0;
%} 

%union
{
	tipo_atributos atributos;
}

%token <atributos> TOK_MAIN
%token <atributos> TOK_INT
%token <atributos> TOK_BOOLEAN
%token <atributos> TOK_ARRAY
%token <atributos> TOK_FUNCTION
%token <atributos> TOK_IF
%token <atributos> TOK_ELSE
%token <atributos> TOK_WHILE
%token <atributos> TOK_SCANF
%token <atributos> TOK_PRINTF
%token <atributos> TOK_RETURN
%token <atributos> TOK_PUNTOYCOMA
%token <atributos> TOK_COMA
%token <atributos> TOK_PARENTESISIZQUIERDO
%token <atributos> TOK_PARENTESISDERECHO
%token <atributos> TOK_CORCHETEIZQUIERDO
%token <atributos> TOK_CORCHETEDERECHO
%token <atributos> TOK_LLAVEIZQUIERDA
%token <atributos> TOK_LLAVEDERECHA
%token <atributos> TOK_ASIGNACION
%token <atributos> TOK_MAS
%token <atributos> TOK_MENOS
%token <atributos> TOK_DIVISION
%token <atributos> TOK_ASTERISCO
%token <atributos> TOK_AND
%token <atributos> TOK_OR
%token <atributos> TOK_NOT
%token <atributos> TOK_IGUAL
%token <atributos> TOK_DISTINTO
%token <atributos> TOK_MENORIGUAL
%token <atributos> TOK_MAYORIGUAL
%token <atributos> TOK_MENOR
%token <atributos> TOK_MAYOR
%token <atributos> TOK_IDENTIFICADOR
%token <atributos> TOK_CONSTANTE_ENTERA
%token <atributos> TOK_TRUE
%token <atributos> TOK_FALSE



%left TOK_MAS TOK_MENOS TOK_OR
%left TOK_ASTERISCO TOK_DIVISION TOK_AND
%left TOK_NOT
%right MENOSU
%start programa

%type <atributos> exp
%type <atributos> programa
%type <atributos> inicioTabla
%type <atributos> escritura_TS
%type <atributos> declaraciones
%type <atributos> declaracion
%type <atributos> clase
%type <atributos> clase_escalar
%type <atributos> clase_vector
%type <atributos> tipo
%type <atributos> identificadores
%type <atributos> identificador
%type <atributos> constante_logica
%type <atributos> constante
%type <atributos> constante_entera
%type <atributos> elemento_vector
%type <atributos> comparacion
%type <atributos> if_exp
%type <atributos> condicional
%type <atributos> while_exp
%type <atributos> while
%type <atributos> fn_declaration
%type <atributos> fn_name
%type <atributos> idf_llamada_funcion
%% 
programa: inicioTabla TOK_MAIN TOK_LLAVEIZQUIERDA declaraciones escritura_TS funciones escritura_main sentencias TOK_LLAVEDERECHA {
	fprintf(fichero_salida,";R1:	<programa> ::= main { <declaraciones> <funciones> <sentencias> }\n");
	fprintf(yyout, "mov esp, ebp\n");
	fprintf(yyout,"\tjmp near fin\n");
	fprintf(yyout, "error_1: push dword mensaje_1\n");
	fprintf(yyout, "call print_string\n");
	fprintf(yyout, "add esp, 4\n");
	fprintf(yyout, "jmp near fin\n");

	fprintf(yyout, "error_2: push dword mensaje_2\n");
	fprintf(yyout, "call print_string\n");
	fprintf(yyout, "mov esp, ebp\n");
	fprintf(yyout, "jmp near fin\n");
	fprintf(yyout, "mov esp, ebp\n");
	fprintf(yyout, "fin:ret\n");


tseliminar(&ts);

};
inicioTabla: {
		tscreartabla(&ts, TABLATAM);
		if(ts.global==NULL){
		printf("****Error No se ha podido crear la tabla\n");
			return(-1);
		}

	
};

escritura_TS: {
	fprintf(yyout, "segment .data\n");
	fprintf(yyout, "mensaje_1 db \"Indice fuera de rango\" , 0\n");
	fprintf(yyout, "mensaje_2 db \"División por cero\" , 0\n");



	fprintf(yyout, "segment .bss\n");
	for(iterador = 0; iterador < ts.global->tam; iterador++){
		if(strlen(ts.global->espacios[iterador].clave) > 0){
			if(ts.global->espacios[iterador].valor.tamanho > 0){
				fprintf(yyout, "_%s resd %d\n",ts.global->espacios[iterador].valor.lexema,ts.global->espacios[iterador].valor.tamanho);
				
			}else{
				fprintf(yyout, "_%s resd 1\n",ts.global->espacios[iterador].valor.lexema);

			}
		}
		
	}

	fprintf(yyout, "segment .text\n");
	fprintf(yyout, "global main\n");
	fprintf(yyout, "extern scan_int, scan_boolean\n");
	fprintf(yyout, "extern print_int, print_boolean, print_string, print_blank, print_endofline\n");
};

escritura_main :{

	fprintf(yyout,"main: \n");
	fprintf(yyout, "mov ebp, esp\n");

}


declaraciones: declaracion {fprintf(fichero_salida,";R2:\t<declaraciones> ::=	<declaracion>\n");};
			  |declaracion declaraciones {fprintf(fichero_salida,";R3:	<declaraciones> ::=	<declaracion> <declaraciones>\n");};

declaracion: clase identificadores TOK_PUNTOYCOMA { 
 tipo_actual = $1.tipo;
  
  /*insertar variable en tabla hash*/  
  fprintf(fichero_salida,";R4:	<declaracion> ::= <clase> <identificadores> ;\n");};

clase: clase_escalar {
		$$.tipo = $1.tipo;
		clase_actual = ESCALAR;
		
		 fprintf(fichero_salida,";R5:	<clase> ::= <clase_escalar>\n");};
	  |clase_vector {
	  		$$.tipo = $1.tipo;
	  		clase_actual = VECTOR;
	 
		 
			fprintf(fichero_salida,";R7:	<clase> ::= <clase_vector>\n");};

clase_escalar: tipo	{$$.tipo = $1.tipo; fprintf(fichero_salida,";R9:	<clase_escalar> ::= <tipo>\n");};

tipo: TOK_INT { $$.tipo = INT; tipo_actual = INT;   fprintf(fichero_salida,";R10:	<tipo> ::= int\n");};
	 |TOK_BOOLEAN {  $$.tipo= BOOLEAN; tipo_actual = BOOLEAN; fprintf(fichero_salida,";R11:	<tipo> ::= boolean\n");};

clase_vector: TOK_ARRAY tipo TOK_CORCHETEIZQUIERDO constante_entera TOK_CORCHETEDERECHO {
		$$.tipo = $2.tipo;
		tamanio_vector_actual = $4.valor_entero;
		if( (tamanio_vector_actual < 1 ) || (tamanio_vector_actual > MAX_TAMANIO_VECTOR) ){
			printf("****Error semantico en lin %d: El tamanyo del vector <%s> excede los limites permitidos (1,64)\n",numero_linea, $1.lexema);
			return -1;
			}


	fprintf(fichero_salida,";R15:	<clase_vector> ::= array <tipo> [ <constante_entera> ]\n");



};

identificadores: identificador {
				$$.tipo=$1.tipo;
	fprintf(fichero_salida,";R18:	<identificadores> ::= <identificador>\n");};
				|identificador TOK_COMA identificadores {

						$$.tipo=$1.tipo;
					fprintf(fichero_salida,";R19:	<identificadores>  ::= <identificador> , <identificadores>\n");};


funciones: funcion funciones {



			fprintf(fichero_salida,";R20:	<funciones> ::= <funcion> <funciones>\n");};
		  |	{fprintf(fichero_salida,";R21:	<funciones> ::= \n");};
funcion: fn_declaration sentencias TOK_LLAVEDERECHA {

		
		if(tseliminarlocal(&ts)==FALSE){
			printf("****Error al eliminar la tabla local de %s\n", $1.lexema);
			return -1;
		}
		if(tsinsertar(&ts, $1.lexema, FUNCION, clase_actual, $1.tipo,num_variables_locales_actual, pos_variable_local_actual, num_parametros_actual, pos_parametro_actual, 0)==-1){
				printf("****ERROR: Fallo al actualizar la funcion %s en el ámbito global\n", $1.lexema);
				return -1;
		}
		if (fn_return == 0) {
			printf("****Error semantico en lin %d: Funcion <%s> sin sentencia de retorno.\n",numero_linea, $1.lexema);
			return -1;
		
		}

		fn_return=0;

		fprintf(yyout, "\tmov esp, ebp\n");
		fprintf(yyout, "\tpop ebp\n");
		fprintf(yyout, "\tret \n\n\n");

		fprintf(fichero_salida,";R22:	<funcion> ::= function <tipo> <identificador> ( <parametros_funcion> ) {<declaraciones_funcion> <sentencias> }\n");
		local = 0;
	};
fn_declaration : fn_name TOK_PARENTESISIZQUIERDO parametros_funcion TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA declaraciones_funcion {


		

			if(tsinsertar(&ts, $1.lexema, FUNCION, clase_actual, $1.tipo, 
					 	num_variables_locales_actual, pos_variable_local_actual, num_parametros_actual, pos_parametro_actual, 0)==-1){
				printf("****ERROR: Fallo al declarar la funcion en el ámbito local %s\n", $1.lexema);
					}
	
			strcpy($$.lexema,$1.lexema);
			fprintf(yyout, "\n\n\t_%s:\n",$1.lexema);
			fprintf(yyout, "\tpush ebp\n");
			fprintf(yyout, "\tmov ebp, esp\n");
			fprintf(yyout, "\tsub esp, %d\n", num_variables_locales_actual*4);
			$$.tipo= $1.tipo;

};
fn_name : TOK_FUNCTION tipo TOK_IDENTIFICADOR {

			
			aux_valor = tsbuscar(&ts,$3.lexema, &posicion);
			if( aux_valor != NULL){
			printf("****Error semantico en lin %d: Declaracion duplicada\n", numero_linea);
			return -1;}
			
			fn_return = 0;
			num_variables_locales_actual = 0;
			pos_variable_local_actual = 1;
			num_parametros_actual = 0;
			pos_parametro_actual = 0;
			$$.tipo = $2.tipo;

			local=1;

		if(tsinsertar(&ts, $3.lexema, categoria_actual, FUNCION, $2.tipo, 
					 	num_variables_locales_actual, pos_variable_local_actual, num_parametros_actual, pos_parametro_actual, 0)==-1){
				printf("ERROR: Fallo al declarar la funcion %s\n", $3.lexema);
					}

			tscrealocal(&ts,TABLATAM);
			local = 1;

				if(tsinsertar(&ts, $3.lexema, categoria_actual, FUNCION, $2.tipo, 
					 	num_variables_locales_actual, pos_variable_local_actual, num_parametros_actual, pos_parametro_actual, 0)==-1){
				printf("ERROR: Fallo al declarar la funcion en el ambito local %s\n", $3.lexema);
					}


			strcpy($$.lexema,$3.lexema);






};


parametros_funcion: parametro_funcion resto_parametros_funcion {fprintf(fichero_salida,";R23:	<parametros_funcion> ::= <parametro_funcion> <resto_parametros_funcion>\n");};
				   | {fprintf(fichero_salida,";R24:	<parametros_funcion> ::= \n");};
resto_parametros_funcion: TOK_PUNTOYCOMA parametro_funcion resto_parametros_funcion {fprintf(fichero_salida,";R25:	<resto_parametros_funcion> ::= ; <parametro_funcion> <resto_parametros_funcion>\n");};
						 | {fprintf(fichero_salida,";R26:	<resto_parametros_funcion> ::= \n");};
parametro_funcion: tipo idpf{

			

			fprintf(fichero_salida,";R27:	<parametro_funcion> ::= <tipo> <identificador>\n");
		};

idpf: TOK_IDENTIFICADOR{

			aux_valor = tsbuscar(&ts,$1.lexema, &posicion);
			if(( aux_valor != NULL && posicion==2 )){
			printf("****Error semantico en lin %d: Declaracion duplicada.\n", numero_linea);
			return -1;}

			if(tsinsertar(&ts, $1.lexema, PARAMETRO, ESCALAR, tipo_actual, 
					 	num_variables_locales_actual, pos_variable_local_actual, num_parametros_actual, pos_parametro_actual, 0)==-1){
				printf("****ERROR: Fallo al insertar parametro %s de funcion\n", $1.lexema);
					}
		num_parametros_actual++;
		pos_parametro_actual++;
				};
declaraciones_funcion: declaraciones {fprintf(fichero_salida,";R28:	<declaraciones_funcion> ::= <declaraciones>\n");};
					  |	{fprintf(fichero_salida,";R29:	<declaraciones_funcion> ::= \n");};
sentencias: sentencia {fprintf(fichero_salida,";R30:	<sentencias> ::= <sentencia>\n");};
		   |sentencia sentencias {fprintf(fichero_salida,";R31:	<sentencias> ::= <sentencia> <sentencias>\n");};
sentencia: sentencia_simple TOK_PUNTOYCOMA {fprintf(fichero_salida,";R32:	<sentencia> ::= <sentencia_simple> ;\n");};
		  |bloque {fprintf(fichero_salida,";R33:	<sentencia> ::= <bloque>\n");};
sentencia_simple: asignacion {fprintf(fichero_salida,";R34:	<sentencia_simple> ::= <asignacion>\n");};
				 |lectura {fprintf(fichero_salida,";R35:	<sentencia_simple> ::= <lectura>\n");};
				 |escritura {fprintf(fichero_salida,";R36:	<sentencia_simple> ::= <escritura>\n");};
				 |retorno_funcion {fprintf(fichero_salida,";R38:	<sentencia_simple> ::= <retorno_funcion>\n");};
bloque: condicional {fprintf(fichero_salida,";R40:	<bloque> ::= <condicional>\n");};
	   |bucle {fprintf(fichero_salida,";R41:	<bloque> ::= <bucle>\n");};
asignacion: TOK_IDENTIFICADOR TOK_ASIGNACION exp {


		aux_valor = tsbuscar(&ts,$1.lexema, &posicion);
	if(local==0){
		if( aux_valor == NULL || posicion == 2){
			printf("****Error semantico en lin %d: Acceso a variable no declarada(<%s>).\n", numero_linea, $1.lexema);
			return -1;
		}
		else if(aux_valor->categoria == FUNCION){
			printf("****Error semantico en lin %d: Asignacion incompatible", numero_linea);
			return -1;

		}

		else if(aux_valor->clase != ESCALAR){
		printf("****Error semantico en lin %d: Asignacion incompatible", numero_linea);
			return -1;

		}

		else if(aux_valor->tipo != $3.tipo){

		printf("%d %d\n", aux_valor->tipo, $3.tipo);
		printf("****Error semantico en lin %d: Asignacion incompatible", numero_linea);
			return -1;

		}

		fprintf(yyout,"\tpop dword eax\n");
		if($3.es_direccion == 1)
		fprintf(yyout,"\tmov dword eax, [eax]\n");
	
		fprintf(yyout,"\tmov dword [_%s],eax\n",$1.lexema);
		


	}else{

		if( aux_valor == NULL){
			printf("****Error semantico en lin %d: Acceso a variable no declarada(<%s>).\n", numero_linea, $1.lexema);
			return -1;
		}
		else if(aux_valor->categoria == FUNCION){
			printf("****Error semantico en lin %d: Asignacion incompatible", numero_linea);
			return -1;

		}

		else if(aux_valor->clase != ESCALAR){
		printf("****Error semantico en lin %d: Asignacion incompatible", numero_linea);
			return -1;

		}

		else if(aux_valor->tipo != $3.tipo){
		printf("****Error semantico en lin %d: Asignacion incompatible", numero_linea);
			return -1;

		}

			/*Variable global*/
		if(posicion ==1 ){
			fprintf(yyout,"\tpop dword eax\n");
		if($3.es_direccion == 1)
		fprintf(yyout,"\tmov dword eax, [eax]\n");
	
		fprintf(yyout,"\tmov dword [_%s],eax\n",$1.lexema);

			/*Variable local*/
		}else if(posicion == 2){

		
		if(llamada_dentro_funcion == 0){
		  if(aux_valor->categoria == PARAMETRO){
          	fprintf(yyout, "lea eax, [ebp+%d]\n",4+4*(num_parametros_actual - aux_valor->pos_parametro));
          	fprintf(yyout, "push dword eax\n");
     	  }else{
          	fprintf(yyout, "lea eax, [ebp-%d]\n",4*aux_valor->pos_variable);
          	fprintf(yyout, "push dword eax\n");

          }
         }else{
         	 if(aux_valor->categoria == PARAMETRO){
          	fprintf(yyout, "lea eax, [ebp+%d]\n",4+4*(num_parametros_actual - aux_valor->pos_parametro));
          	fprintf(yyout, "push dword [eax]\n");
     	  }else{
          	fprintf(yyout, "lea eax, [ebp-%d]\n",4*aux_valor->pos_variable);
          	fprintf(yyout, "push dword [eax]\n");

          }
         }

		fprintf(yyout,"pop dword ebx\n");
  		fprintf(yyout,"pop dword eax\n");
  		if ($3.es_direccion == 1){
   		fprintf(yyout,"mov dword eax , [eax]\n");
  			}
  		fprintf(yyout,"; Hacer la asignación efectiva\n");
  		fprintf(yyout,"mov dword [ebx] , eax\n");
		

	}

	}


	fprintf(fichero_salida,";R43:	<asignacion> ::= <identificador> = <exp>\n");};

		   |elemento_vector TOK_ASIGNACION exp {

		   		if($1.tipo != $3.tipo){
					printf("****Error semantico en lin X: Asignacion incompatible.");
					return -1;	}

			fprintf(yyout,"\tpop dword eax\n");
			if($3.es_direccion == 1){
				fprintf(yyout,"\tmov dword eax, [eax]\n");

			}

			fprintf(yyout,"\tpop dword edx\n");
			fprintf(yyout,"\tmov dword [edx], eax\n");

		   	fprintf(fichero_salida,";R44:	<asignacion> ::= <elemento_vector> = <exp>\n");};

elemento_vector: TOK_IDENTIFICADOR TOK_CORCHETEIZQUIERDO exp TOK_CORCHETEDERECHO {
		
		aux_valor = tsbuscar(&ts,$1.lexema, &posicion);
		if( aux_valor == NULL){
			printf("****Error semantico en lin %d: Acceso a variable no declarada(<%s>).", numero_linea ,$1.lexema);
			return -1;
		}

		
		else if(aux_valor->clase != VECTOR){
		printf("****Error semantico en lin %d: Intento de indexacion de una variable que no es de tipo vector",numero_linea);
			return -1;

		}

		else if($3.tipo != INT ){
		printf("****Error semantico en lin %d: El indice en una operacion de indexacion tiene que ser de tipo entero.", numero_linea);
			return -1;

		}
		fprintf(yyout,"\tpop dword eax\n");
		if($3.es_direccion == 1){
			fprintf(yyout,"\tmov dword eax , [eax]\n");
			
		}
		fprintf(yyout,"\tcmp eax,0\n");
		fprintf(yyout,"\tjl near error_1\n");
		fprintf(yyout,"\tcmp eax, %d\n", aux_valor->tamanho - 1);
		fprintf(yyout,"\tjg near error_1\n");

		fprintf(yyout,"; Cargar en edx la dirección de inicio del vector\n");
		fprintf(yyout,"\tmov dword edx, _%s\n",$1.lexema);
		fprintf(yyout,"; Cargar en eax la dirección del elemento indexado\n");
		fprintf(yyout,"\tlea eax, [edx + eax*4]\n");
		fprintf(yyout,"; Apilar la dirección del elemento indexado\n");
		if(en_explist ==1){
		fprintf(yyout,"\tpush dword [eax]\n");
		}else{
		fprintf(yyout,"\tpush dword eax\n");
		}


		$$.tipo = aux_valor->tipo;
		$$.es_direccion = 1;
	fprintf(fichero_salida,";R48:	<elemento_vector> ::= <identificador> [ <exp> ] \n");

};
condicional: if_exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA  sentencias TOK_LLAVEDERECHA{

				fprintf(yyout, "fin_si%d:\n", $1.etiqueta);
				fprintf(fichero_salida,";R50:	<condicional> ::= if ( <exp> ) { <sentencias> }\n");
			};


			|if_exp TOK_PARENTESISDERECHO TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {
				fprintf(yyout, "jmp near fin_sino%d\n", $1.etiqueta);
				fprintf(yyout, "fin_si%d:\n", $1.etiqueta);} 
			TOK_ELSE TOK_LLAVEIZQUIERDA sentencias TOK_LLAVEDERECHA {
				fprintf(yyout, "fin_sino%d:\n", $1.etiqueta);
				fprintf(fichero_salida,";R51:	<condicional> ::= if ( <exp> ) { <sentencias> } else { <sentencias> }\n");
			};

if_exp : TOK_IF TOK_PARENTESISIZQUIERDO exp {
	if ($3.tipo != BOOLEAN ) {
		printf("****Error semantico en lin %d: Condicional con condicion de tipo int.\n", numero_linea);
		return -1;
	}

	$$.etiqueta = etiqueta; 
	etiqueta++;
	fprintf(yyout, "\tpop eax\n");
	if ($3.es_direccion == 1) {
		fprintf(yyout, "\tmov eax , [eax]\n");
	}
	
	fprintf(yyout, "\tcmp eax, 0\n");
	fprintf(yyout, "\tje near fin_si%d\n",$$.etiqueta);
};

bucle: while_exp sentencias TOK_LLAVEDERECHA{

	fprintf(yyout, "jmp near inicio_while%d\n", $1.etiqueta);
	fprintf(yyout, "fin_while%d:\n", $1.etiqueta);

	fprintf(fichero_salida,";R52:	<bucle> ::= while ( <exp> ) { <sentencias> }\n");
};




while_exp : while exp TOK_PARENTESISDERECHO  TOK_LLAVEIZQUIERDA {

	if ($2.tipo != BOOLEAN ) {
		printf("****Error semantico en lin %d: Condicional con condicion de tipo int.\n", numero_linea);
		return -1;
	}
	$$.etiqueta = $1.etiqueta;
	fprintf(yyout, "pop eax\n");
	if($2.es_direccion == 1){
		fprintf(yyout, "mov eax , [eax]\n");
	}
	fprintf(yyout, "cmp eax, 0\n");
	fprintf(yyout, "je near fin_while%d\n", $$.etiqueta);
};
while: TOK_WHILE TOK_PARENTESISIZQUIERDO {

	$$.etiqueta = etiqueta;
	etiqueta++;
	fprintf(yyout, "inicio_while%d:\n", $$.etiqueta);
};

lectura: TOK_SCANF TOK_IDENTIFICADOR {

			aux_valor = tsbuscar(&ts,$2.lexema, &posicion);

	if(local == 0){
		if( aux_valor == NULL || posicion == 2){
			printf("****Error semantico en lin %d: Acceso a variable no declarada (<%s>).",numero_linea,  $2.lexema);
			return -1;
		}
		else if(aux_valor->categoria == FUNCION){
			printf("****Error semantico en lin %d: No esta permitido el uso de llamadas a funciones como parametros de otras funciones.",numero_linea);
			return -1;

		}

		else if(aux_valor->clase != ESCALAR){
		printf("****Error semantico en lin %d: Parametro de funcion de tipo no escalar",numero_linea);
			return -1;

		}

		
			/*generacion de codigo*/
			fprintf(yyout,";se apila la direccion de memoria destino\n");
			fprintf(yyout,"\tpush dword  _%s\n", $2.lexema);

			if(aux_valor->tipo == INT){
			 fprintf(yyout,"\t call scan_int\n");
			}else if(aux_valor->tipo == BOOLEAN){
			 fprintf(yyout,"\t call scan_boolean\n");
			}

			fprintf(yyout,"\tadd esp, 4\n");
	}else{

		if( aux_valor == NULL){
			printf("****Error semantico en lin %d: Acceso a variable no declarada (<%s>).", numero_linea ,$2.lexema);
			return -1;
		}
		else if(aux_valor->categoria == FUNCION){
			printf("****Error semantico en lin %d: No esta permitido el uso de llamadas a funciones como parametros de otras funciones.", numero_linea);
			return -1;

		}

		else if(aux_valor->clase != ESCALAR){
		printf("****Error semantico en lin %d: Parametro de funcion de tipo no escalar", numero_linea);
			return -1;

		}

			/*Variable local*/
		if(posicion == 2){
			
		if(llamada_dentro_funcion == 0){
		  if(aux_valor->categoria == PARAMETRO){
          	fprintf(yyout, "lea eax, [ebp+%d]\n",4+4*(num_parametros_actual - aux_valor->pos_parametro));
          	fprintf(yyout, "push dword eax\n");
     	  }else{
          	fprintf(yyout, "lea eax, [ebp-%d]\n",4*aux_valor->pos_variable);
          	fprintf(yyout, "push dword eax\n");

          }
         }else{
         	 if(aux_valor->categoria == PARAMETRO){
          	fprintf(yyout, "lea eax, [ebp+%d]\n",4+4*(num_parametros_actual - aux_valor->pos_parametro));
          	fprintf(yyout, "push dword [eax]\n");
     	  }else{
          	fprintf(yyout, "lea eax, [ebp-%d]\n",4*aux_valor->pos_variable);
          	fprintf(yyout, "push dword [eax]\n");

          }

         }

			if(aux_valor->tipo == INT){
				 fprintf(yyout,"call scan_int\n");
			}else if(aux_valor->tipo == BOOLEAN){
				 fprintf(yyout,"call scan_boolean\n");
			}
				 fprintf(yyout,"add esp, 4\n");
			/*Variable global*/
		}else if(posicion == 1){

				/*generacion de codigo*/
			fprintf(yyout,";se apila la direccion de memoria destino\n");
			fprintf(yyout,"\tpush dword  _%s\n", $2.lexema);

			if(aux_valor->tipo == INT){
			 fprintf(yyout,"\t call scan_int\n");
			}else if(aux_valor->tipo == BOOLEAN){
			 fprintf(yyout,"\t call scan_boolean\n");
			}

			fprintf(yyout,"\tadd esp, 4\n");
		}








	}

	fprintf(fichero_salida,";R54:	<lectura> ::= scanf <identificador>\n");};
escritura: TOK_PRINTF exp {

				if($2.es_direccion == 1){

					fprintf(yyout,"\tpop dword eax\n");
					fprintf(yyout,"\tmov dword eax, [eax]\n");
					fprintf(yyout,"\tpush dword eax\n");
				}

				
				if($2.tipo == INT){

					fprintf(yyout,"\tcall print_int\n");
				}

				if($2.tipo == BOOLEAN){

					fprintf(yyout,"\tcall print_boolean\n");
				}

			
				fprintf(yyout,"\tadd esp,4\n");
				fprintf(yyout,"\tcall print_endofline\n");



	fprintf(fichero_salida,";R56:	<escritura> ::= printf <exp>\n");};

retorno_funcion: TOK_RETURN exp {
	
	fprintf(yyout, "\tpop dword eax\n");
	if($2.es_direccion == 1) {
		fprintf(yyout, "\tmov eax , [eax]\n");
	}
	fprintf(yyout, "\tmov dword esp, ebp\n");
	fprintf(yyout, "\tpop dword ebp\n");
	fprintf(yyout, "\tret\n");

	fn_return++;
	fprintf(fichero_salida,";R61:	<retorno_funcion> ::= return <exp>\n");

};

exp: exp TOK_MAS exp {fprintf(fichero_salida,";R72:\t<exp> ::= <exp> + <exp>\n");

		if(($1.tipo == INT) && ($3.tipo==$1.tipo)) {
			$$.tipo = $1.tipo;
			$$.es_direccion = 0;
				
				fprintf(yyout,"; cargar el segundo operando en edx\n");
				fprintf(yyout,"\tpop dword edx\n");

				if($3.es_direccion == 1){

					
					fprintf(yyout,"\tmov dword edx, [edx]\n");
				}

					fprintf(yyout,"; cargar el primer operando en eax\n");
					fprintf(yyout,"\tpop dword eax\n");


					if($1.es_direccion == 1){

					
					fprintf(yyout,"\tmov dword eax, [eax]\n");
				}
					
					

					fprintf(yyout,"; realizar la suma y dejar el resultado en eax\n");
					fprintf(yyout,"\tadd eax, edx\n");
					fprintf(yyout,"; apilar el resultado\n");
					fprintf(yyout,"\tpush dword eax\n");

				




		}else{
printf("****Error semantico en lin %d: Operacion aritmetica con operandos boolean", numero_linea);}}

	|exp TOK_MENOS exp {fprintf(fichero_salida,";R73:\t<exp> ::= <exp> - <exp>\n");

		if(($1.tipo ==INT) && ($3.tipo==$1.tipo)){
			$$.tipo=$1.tipo;
			$$.es_direccion = 0;

				fprintf(yyout,"; cargar el segundo operando en edx\n");
				fprintf(yyout,"\tpop dword edx\n");



		if($3.es_direccion == 1){

					
					fprintf(yyout,"\tmov dword edx, [edx]\n");
				}

					fprintf(yyout,"; cargar el primer operando en eax\n");
					fprintf(yyout,"\tpop dword eax\n");


					if($1.es_direccion == 1){

					
					fprintf(yyout,"\tmov dword eax, [eax]\n");
				}
					
					

					fprintf(yyout,"; realizar la resta y dejar el resultado en eax\n");
					fprintf(yyout,"\tsub eax, edx\n");
					fprintf(yyout,"; apilar el resultado\n");
					fprintf(yyout,"\tpush dword eax\n");
				
		}else{
printf("****Error semantico en lin %d: Operacion aritmetica con operandos boolean", numero_linea);}}

	|exp TOK_DIVISION exp {fprintf(fichero_salida,";R74:\t<exp> ::= <exp> / <exp>\n");
		

		if(($1.tipo ==INT) && ($3.tipo==$3.tipo)){
			
			$$.tipo=$1.tipo;
			$$.es_direccion = 0;


				fprintf(yyout,"; cargar el segundo operando en edx\n");
				fprintf(yyout,"\tpop dword ecx\n");




		if($3.es_direccion == 1){

					
					fprintf(yyout,"\tmov dword ecx, [ecx]\n");
				}

					fprintf(yyout,"\tcmp ecx, 0\n");
					fprintf(yyout,"\tje near error_2\n");

					fprintf(yyout,"; cargar el primer operando en eax\n");
					fprintf(yyout,"\tpop dword eax\n");


					if($1.es_direccion == 1){

					
					fprintf(yyout,"\tmov dword eax, [eax]\n");
				}
					
					
					fprintf(yyout,"\tcdq\n");

					fprintf(yyout,"; realizar la division y dejar el resultado en eax\n");
					fprintf(yyout,"\tidiv ecx\n");
					fprintf(yyout,"; apilar el resultado\n");
					fprintf(yyout,"\tpush dword eax\n");


		
		}else{
printf("****Error semantico en lin %d: Operacion aritmetica con operandos boolean", numero_linea);}}

	|exp TOK_ASTERISCO exp {fprintf(fichero_salida,";R75:\t<exp> ::= <exp> * <exp>\n");
		
		if(($1.tipo ==INT) && ($3.tipo==$3.tipo)) {
			$$.tipo=$1.tipo;
			$$.es_direccion = 0;	


			fprintf(yyout,"; cargar el segundo operando en edx\n");
				fprintf(yyout,"\tpop dword eax\n");

		if($3.es_direccion == 1){

					
					fprintf(yyout,"\tmov dword eax, [eax]\n");
				}

					fprintf(yyout,"; cargar el primer operando en eax\n");
					fprintf(yyout,"\tpop dword edx\n");


					if($1.es_direccion == 1){

					
					fprintf(yyout,"\tmov dword edx, [edx]\n");
				}
					
					
					

					fprintf(yyout,"; realizar la multiplicacion y dejar el resultado en eax\n");
					fprintf(yyout,"\timul edx\n");
					fprintf(yyout,"; apilar el resultado\n");
					fprintf(yyout,"\tpush dword eax\n");
		
		}else{
printf("****Error semantico en lin %d: Operacion aritmetica con operandos boolean", numero_linea);}}

	|TOK_MENOS exp %prec MENOSU {fprintf(fichero_salida,";R76:\t<exp> ::= - <exp>\n");
		if($2.tipo==INT){
			$$.tipo=$2.tipo;
			$$.es_direccion = 0;



			fprintf(yyout,"; cargar el  operando en eax\n");
				fprintf(yyout,"\tpop dword eax\n");

		if($2.es_direccion == 1){

					
					fprintf(yyout,"\tmov dword eax, [eax]\n");
				}


					fprintf(yyout,"; realizar la negacion\n");
					fprintf(yyout,"\tneg eax\n");
					fprintf(yyout,"; apilar el resultado en eax\n");
					fprintf(yyout,"\tpush dword eax\n");

		}else{printf("****Error semantico en lin %d: Operacion aritmetica con operandos boolean.\n", numero_linea);
				return -1;
	}}

	|exp TOK_AND exp {fprintf(fichero_salida,";R77:\t<exp> ::= <exp> && <exp>\n");

		if(($1.tipo == BOOLEAN) && ($3.tipo==$1.tipo)) {
					$$.tipo = BOOLEAN;
					$$.es_direccion = 0;

					fprintf(yyout,"; cargar el segundo operando en edx\n");
					fprintf(yyout,"\tpop dword edx\n");

					if($3.es_direccion == 1){
					fprintf(yyout,"\tmov dword edx, [edx]\n");
					}

					fprintf(yyout,"; cargar el primer operando en eax\n");
					fprintf(yyout,"\tpop dword eax\n");

					if($1.es_direccion == 1){
					fprintf(yyout,"\tmov dword eax, [eax]\n");
					}

					fprintf(yyout,"; realizar la conjunción\n");
					fprintf(yyout,"\tand eax, edx\n");

					fprintf(yyout,"; apilar el resultado\n");
					fprintf(yyout,"\tpush dword eax\n");



			}else{printf("****Error semantico en lin %d: Operacion logica con operandos int", numero_linea);
					}}
	|exp TOK_OR exp {fprintf(fichero_salida,";R78:\t<exp> ::= <exp> || <exp>\n");


		if(($1.tipo == BOOLEAN) && ($3.tipo== $1.tipo)) {
					$$.tipo = BOOLEAN;
					$$.es_direccion = 0;

					fprintf(yyout,"; cargar el segundo operando en edx\n");
					fprintf(yyout,"\tpop dword edx\n");

					if($3.es_direccion == 1){
					fprintf(yyout,"\tmov dword edx, [edx]\n");
					}

					fprintf(yyout,"; cargar el primer operando en eax\n");
					fprintf(yyout,"\tpop dword eax\n");

					if($1.es_direccion == 1){
					fprintf(yyout,"\tmov dword eax, [eax]\n");
					}

					fprintf(yyout,"; realizar la disyunjunción\n");
					fprintf(yyout,"\tor eax, edx\n");

					fprintf(yyout,"; apilar el resultado\n");
					fprintf(yyout,"\tpush dword eax\n");


					
			}else{printf("****Error semantico en lin %d: Operacion logica con operandos int", numero_linea);
					}}
	|TOK_NOT exp {if($2.tipo ==BOOLEAN) {
					$$.tipo = BOOLEAN;
					$$.es_direccion = 0;

					fprintf(yyout,"; cargar el operando en eax\n");
					fprintf(yyout,"\tpop dword eax\n");

					if($2.es_direccion == 1){
					fprintf(yyout,"\tmov dword eax, [eax]\n");
					}

					fprintf(yyout,"; ver si eax es 0 y en ese caso negar_falso\n");
					fprintf(yyout,"\tor eax, eax\n");
					fprintf(yyout,"\tjz near negar_falso%d\n",etiqueta);

					fprintf(yyout,"; cargar 0 en eax (negación de verdadero) y saltar al final\n");
					fprintf(yyout,"\tmov dword eax, 0\n");
					fprintf(yyout,"\tjmp near fin_negacion%d\n",etiqueta);
				

					fprintf(yyout,"; cargar 1 en eax (negacion de falso)\n");
					fprintf(yyout,"\tnegar_falso%d:\n\tmov dword eax,1 \n",etiqueta);
					fprintf(yyout,"\tfin_negacion%d:\n",etiqueta);
					etiqueta++;
					fprintf(yyout,"; apilar el resultado\n");
					fprintf(yyout,"\tpush dword eax\n");

					fprintf(fichero_salida,";R79:\t<exp> ::= ! <exp>\n");



					
			}else{printf("****Error semantico en lin %d: Operacion logica con operandos int", numero_linea);
					}}
	|TOK_IDENTIFICADOR {
	

		aux_valor = tsbuscar(&ts,$1.lexema, &posicion);
		

	if(local==0){
		if( aux_valor == NULL || posicion == 2){
			printf("****Error semantico en lin %d: Acceso a variable no declarada(%s)", numero_linea, $1.lexema);
			return -1;
		}
		else if(aux_valor->categoria == FUNCION){
			printf("Error expresion de categoria funcion");
			return -1;

		}

		else if(aux_valor->clase != ESCALAR){
		printf("****Error semantico en lin %d: Asignacion incompatible.", numero_linea);
			return -1;

		}
			$$.tipo = aux_valor->tipo;
			if (en_explist==1){
			fprintf(yyout,"\tpush dword [_%s]\n",$1.lexema);
			}else{
			fprintf(yyout,"\tpush dword _%s\n",$1.lexema);	
			}
	}else{

		if(aux_valor == NULL){
			printf("****Error semantico en lin %d: Acceso a variable no declarada(%s)", numero_linea, $1.lexema);
			return -1;
		}
		else if(aux_valor->categoria == FUNCION){
			printf("****Error semantico en lin: %d No esta permitido el uso de llamadas afunciones como parametros de otras funciones.", numero_linea);
			return -1;

		}

		else if(aux_valor->clase != ESCALAR){

		printf("****Error semantico en lin %d: Asignacion incompatible.", numero_linea);
			return -1;

		}


		if(posicion==1){

			if (en_explist==1){
			fprintf(yyout,"\tpush dword [_%s]\n",$1.lexema);
			}else{
			fprintf(yyout,"\tpush dword _%s\n",$1.lexema);	
			}

		}else if(posicion==2){

		if(llamada_dentro_funcion == 0){
		  if(aux_valor->categoria == PARAMETRO){
          	fprintf(yyout, "lea eax, [ebp+%d]\n",4+4*(num_parametros_actual - aux_valor->pos_parametro));
          	fprintf(yyout, "push dword eax\n");
     	  }else{
          	fprintf(yyout, "lea eax, [ebp-%d]\n",4*aux_valor->pos_variable);
          	fprintf(yyout, "push dword eax\n");

          }
         }else{
         	 if(aux_valor->categoria == PARAMETRO){
          	fprintf(yyout, "lea eax, [ebp+%d]\n",4+4*(num_parametros_actual - aux_valor->pos_parametro));
          	fprintf(yyout, "push dword [eax]\n");
     	  }else{
          	fprintf(yyout, "lea eax, [ebp-%d]\n",4*aux_valor->pos_variable);
          	fprintf(yyout, "push dword [eax]\n");

          }


         }

		}




	}	$$.tipo = aux_valor->tipo;

		
		$$.es_direccion=1;
		
		
		fprintf(fichero_salida,";R80:	<exp> ::= <identificador>\n");




	}
	|constante {

						$$.tipo = $1.tipo;
						$$.es_direccion = $1.es_direccion;


		fprintf(fichero_salida,";R81:	<exp> ::= <constante>\n");}
	|TOK_PARENTESISIZQUIERDO exp TOK_PARENTESISDERECHO {

						$$.tipo = $2.tipo;
						$$.es_direccion = $2.es_direccion;

		fprintf(fichero_salida,";R82:	<exp> ::= ( <exp> )\n");

	}
	|TOK_PARENTESISIZQUIERDO comparacion TOK_PARENTESISDERECHO {

						$$.tipo = $2.tipo;
						$$.es_direccion = $2.es_direccion;


		fprintf(fichero_salida,";R83:	<exp> ::= ( <comparacion> )\n");
	}
	|elemento_vector {

						$$.tipo = $1.tipo;
						$$.es_direccion = $1.es_direccion;

		fprintf(fichero_salida,";R85:	<exp> ::= <elemento_vector>\n");}
	|idf_llamada_funcion TOK_PARENTESISIZQUIERDO lista_expresiones TOK_PARENTESISDERECHO {
			aux_valor = tsbuscar(&ts,$1.lexema, &posicion);
				llamada_dentro_funcion=0;
					if( aux_valor->num_parametro != num_parametros_llamada_actual){
					printf("Error llamada argumentos\n");
					return -1;
					}

				
				en_explist = 0;

				$$.tipo=aux_valor->tipo;

				$$.es_direccion = 0;

			fprintf(yyout, "\tcall _%s\n",$1.lexema);
			fprintf(yyout, "\tadd esp, %d\n",num_parametros_llamada_actual * 4);
			fprintf(yyout, "\tpush dword eax\n");
			fprintf(fichero_salida,";R88:	<exp> ::= <identificador> ( <lista_expresiones> )\n");
		};

lista_expresiones: exp resto_lista_expresiones {
			fprintf(fichero_salida,";R89:	<lista_expresiones> ::= <exp> 	<resto_lista_expresiones>\n");
				num_parametros_llamada_actual++;


;}
				  | {fprintf(fichero_salida,";R90:	<lista_expresiones> ::= \n");};


idf_llamada_funcion: TOK_IDENTIFICADOR{
			aux_valor = tsbuscar(&ts,$1.lexema, &posicion);
			llamada_dentro_funcion=0;
			if(aux_valor == NULL){
			printf("****Error semantico en lin %d: Acceso a variable no declarada(<%s>)\n",numero_linea, $1.lexema);
			}
			if(aux_valor->categoria != FUNCION){
			printf("****Error  %s no es una función \n", $1.lexema);
			return -1;
			}

			if(en_explist == 1){
			printf("****Error semantico en lin %d: No esta permitido el uso de llamadas afunciones como parametros de otras funciones\n", numero_linea);
			return -1;
			}
			llamada_dentro_funcion=1;
			num_parametros_llamada_actual = 0;
			en_explist = 1;
			strcpy($$.lexema, $1.lexema);
};	



resto_lista_expresiones: TOK_COMA exp resto_lista_expresiones	{


			num_parametros_llamada_actual++;
fprintf(fichero_salida,";R91:	<resto_lista_expresiones> ::= , <exp> <resto_lista_expresiones>\n");

};
						| {fprintf(fichero_salida,";R92:	<resto_lista_expresiones> ::= \n");};

comparacion: exp TOK_IGUAL exp {if( ($1.tipo==INT) && $3.tipo==$1.tipo) {
				$$.tipo=BOOLEAN;
				$$.es_direccion = 0;

			fprintf(yyout, "; cargar la segunda expresion en edx\n");
			fprintf(yyout, "\tpop dword edx\n");

			if($3.es_direccion == 1){
			fprintf(yyout, "\tmov dword edx, [edx]\n");
			}

			fprintf(yyout, "; cargar la primera expresion en eax\n");
			fprintf(yyout, "\tpop dword eax\n");

			if($1.es_direccion == 1){
			fprintf(yyout, "\tmov dword eax, [eax]\n");
			}	

			fprintf(yyout, "; comparar y apilar el resultado\n");
			fprintf(yyout, "\tcmp eax, edx\n");
			fprintf(yyout, "\tje near igual%d\n",etiqueta);
			fprintf(yyout, "\tpush dword 0\n");
			fprintf(yyout, "\tjmp near fin_igual%d\n",etiqueta);
			fprintf(yyout, "\tigual%d: push dword 1\n",etiqueta);
			fprintf(yyout, "\tfin_igual%d:\n",etiqueta);
			etiqueta++;


			}else{printf("****Error semantico en lin %d: Comparacion con operandos boolean", numero_linea);
					}}
			|exp TOK_DISTINTO exp {if( ($1.tipo==INT) && $3.tipo==$1.tipo) {
				$$.tipo=BOOLEAN;
				$$.es_direccion = 0;


			fprintf(yyout, "; cargar la segunda expresion en edx\n");
			fprintf(yyout, "\tpop dword edx\n");

			if($3.es_direccion == 1){
			fprintf(yyout, "\tmov dword edx, [edx]\n");
			}

			fprintf(yyout, "; cargar la primera expresion en eax\n");
			fprintf(yyout, "\tpop dword eax\n");

			if($1.es_direccion == 1){
			fprintf(yyout, "\tmov dword eax, [eax]\n");
			}	

			fprintf(yyout, "; comparar y apilar el resultado\n");
			fprintf(yyout, "\tcmp eax, edx\n");
			fprintf(yyout, "\tjne near distinto%d\n",etiqueta);
			fprintf(yyout, "\tpush dword 0\n");
			fprintf(yyout, "\tjmp near fin_distinto%d\n",etiqueta);
			fprintf(yyout, "\tdistinto%d: push dword 1\n",etiqueta);
			fprintf(yyout, "\tfin_distinto%d:\n",etiqueta);
			etiqueta++;
					
			}else{printf("****Error semantico en lin %d: Comparacion con operandos boolean", numero_linea);
					}}
			|exp TOK_MENORIGUAL exp {if( ($1.tipo==INT) && $3.tipo==$1.tipo){
				$$.tipo=BOOLEAN;
				$$.es_direccion = 0;

			fprintf(yyout, "; cargar la segunda expresion en edx\n");
			fprintf(yyout, "\tpop dword edx\n");

			if($3.es_direccion == 1){
			fprintf(yyout, "\tmov dword edx, [edx]\n");
			}

			fprintf(yyout, "; cargar la primera expresion en eax\n");
			fprintf(yyout, "\tpop dword eax\n");

			if($1.es_direccion == 1){
			fprintf(yyout, "\tmov dword eax, [eax]\n");
			}	

			fprintf(yyout, "; comparar y apilar el resultado\n");
			fprintf(yyout, "\tcmp eax, edx\n");
			fprintf(yyout, "\tjle near menorigual%d\n",etiqueta);
			fprintf(yyout, "\tpush dword 0\n");
			fprintf(yyout, "\tjmp near fin_menorigual%d\n",etiqueta);
			fprintf(yyout, "\tmenorigual%d: push dword 1\n",etiqueta);
			fprintf(yyout, "\tfin_menorigual%d:\n",etiqueta);
			etiqueta++;
			}else{printf("****Error semantico en lin %d: Comparacion con operandos boolean", numero_linea);
					}}
			|exp TOK_MAYORIGUAL exp {if(($1.tipo==INT) && $3.tipo==$1.tipo){
				$$.tipo=BOOLEAN;
				$$.es_direccion = 0;

			fprintf(yyout, "; cargar la segunda expresion en edx\n");
			fprintf(yyout, "\tpop dword edx\n");

			if($3.es_direccion == 1){
			fprintf(yyout, "\tmov dword edx, [edx]\n");
			}

			fprintf(yyout, "; cargar la primera expresion en eax\n");
			fprintf(yyout, "\tpop dword eax\n");

			if($1.es_direccion == 1){
			fprintf(yyout, "\tmov dword eax, [eax]\n");
			}	

			fprintf(yyout, "; comparar y apilar el resultado\n");
			fprintf(yyout, "\tcmp eax, edx\n");
			fprintf(yyout, "\tjge near mayorigual%d\n",etiqueta);
			fprintf(yyout, "\tpush dword 0\n");
			fprintf(yyout, "\tjmp near fin_mayorigual%d\n",etiqueta);
			fprintf(yyout, "\tmayorigual%d: push dword 1\n",etiqueta);
			fprintf(yyout, "\tfin_mayorigual%d:\n",etiqueta);
			etiqueta++;
			}else{printf("****Error semantico en lin %d: Comparacion con operandos boolean", numero_linea);
					}}
			|exp TOK_MENOR exp {if( ($1.tipo==INT) && $3.tipo==$1.tipo) {
				$$.tipo=BOOLEAN;
				$$.es_direccion = 0;


			fprintf(yyout, "; cargar la segunda expresion en edx\n");
			fprintf(yyout, "\tpop dword edx\n");

			if($3.es_direccion == 1){
			fprintf(yyout, "\tmov dword edx, [edx]\n");
			}

			fprintf(yyout, "; cargar la primera expresion en eax\n");
			fprintf(yyout, "\tpop dword eax\n");

			if($1.es_direccion == 1){
			fprintf(yyout, "\tmov dword eax, [eax]\n");
			}	

			fprintf(yyout, "; comparar y apilar el resultado\n");
			fprintf(yyout, "\tcmp eax, edx\n");
			fprintf(yyout, "\tjl near menor%d\n",etiqueta);
			fprintf(yyout, "\tpush dword 0\n");
			fprintf(yyout, "\tjmp near fin_menor%d\n",etiqueta);
			fprintf(yyout, "\tmenor%d: push dword 1\n",etiqueta);
			fprintf(yyout, "\tfin_menor%d:\n",etiqueta);
			etiqueta++;
					
			}else{printf("****Error semantico en lin %d: Comparacion con operandos boolean", numero_linea);
					}}
			|exp TOK_MAYOR exp {if( ($1.tipo==INT) && $3.tipo==$1.tipo){
				$$.tipo=BOOLEAN;
				$$.es_direccion = 0;

			fprintf(yyout, "; cargar la segunda expresion en edx\n");
			fprintf(yyout, "\tpop dword edx\n");

			if($3.es_direccion == 1){
			fprintf(yyout, "\tmov dword edx, [edx]\n");
			}

			fprintf(yyout, "; cargar la primera expresion en eax\n");
			fprintf(yyout, "\tpop dword eax\n");

			if($1.es_direccion == 1){
			fprintf(yyout, "\tmov dword eax, [eax]\n");
			}	

			fprintf(yyout, "; comparar y apilar el resultado\n");
			fprintf(yyout, "\tcmp eax, edx\n");
			fprintf(yyout, "\tjg near mayor%d\n",etiqueta);
			fprintf(yyout, "\tpush dword 0\n");
			fprintf(yyout, "\tjmp near fin_mayor%d\n",etiqueta);
			fprintf(yyout, "\tmayor%d: push dword 1\n",etiqueta);
			fprintf(yyout, "\tfin_mayor%d:\n",etiqueta);
			etiqueta++;

			}else{
printf("****Error semantico efunction int potencia ( int x; int left ) {n lin %d: Comparacion con operandos boolean", numero_linea);}};

constante: constante_logica {
			/*  análisis semántico */
			$$.tipo = $1.tipo;
			$$.es_direccion = $1.es_direccion;
			fprintf(fichero_salida,";R99:	<constante> ::= <constante_logica>\n");}

		  |constante_entera {
			$$.tipo = $1.tipo;	
			$$.valor_entero = $1.valor_entero;
			fprintf(fichero_salida,";R100:<constante> ::= <constante_entera>\n");};

constante_logica: TOK_TRUE {
		/*  análisis semántico */
			$$.tipo = BOOLEAN;
			$$.es_direccion = 0;
			/* generación de código */
			fprintf(yyout, "; numero_linea %d\n",numero_linea);
			fprintf(yyout, "\tpush dword 1\n");


	fprintf(fichero_salida,";R102:	<constante_logica> ::= true\n");}
		 |TOK_FALSE {

		 		/*  análisis semántico */
				$$.tipo = BOOLEAN;
				$$.es_direccion = 0;
				/* generación de código */
				fprintf(yyout, "; numero_linea %d\n",
				 numero_linea);
				fprintf(yyout, "\tpush dword 0\n");



		 	fprintf(fichero_salida,";R102:	<constante_logica> ::= false\n");};

constante_entera: TOK_CONSTANTE_ENTERA {

				/*  análisis semántico */
				$$.tipo = INT;
				$$.es_direccion = 0;
				/* generación de código */
				fprintf(yyout, "; numero_linea %d\n", numero_linea);
				fprintf(yyout, "\tpush dword %d\n", $1.valor_entero);
				fprintf(fichero_salida,";R104:	<constante_entera> ::= constante_entera\n");
			};

identificador: TOK_IDENTIFICADOR {
	if(local==0){
		if (tsbuscar(&ts,$1.lexema, &posicion) == NULL) {
			
			if(clase_actual == ESCALAR){
					if((tsinsertar(&ts, $1.lexema, categoria_actual, clase_actual, tipo_actual, 
					 	num_variables_locales_actual, pos_variable_local_actual, num_parametros_actual, pos_parametro_actual, 0)) == -1){
							return -1;
						}
				}
				else if(clase_actual == VECTOR){
					if((tsinsertar(&ts, $1.lexema, categoria_actual, clase_actual, tipo_actual, 
					 	num_variables_locales_actual, pos_variable_local_actual, num_parametros_actual, pos_parametro_actual, tamanio_vector_actual)) == -1){
							return -1;
						}
				}
			
		}else{
			printf("****Error semantico en lin %d: Declaracion duplicada.\n", numero_linea);
			return -1;

		}
	}else {
			if(tsbuscar(&ts,$1.lexema, &posicion) == NULL || posicion !=2){
					if(clase_actual == ESCALAR){
						if((tsinsertar(&ts, $1.lexema, categoria_actual, clase_actual, tipo_actual, 
					 		num_variables_locales_actual, pos_variable_local_actual, num_parametros_actual, pos_parametro_actual, 0)) == -1){
							return -1;
						}
				}
					else if(clase_actual == VECTOR){
						if((tsinsertar(&ts, $1.lexema, categoria_actual, clase_actual, tipo_actual, 
					 	num_variables_locales_actual, pos_variable_local_actual, num_parametros_actual, pos_parametro_actual, tamanio_vector_actual)) == -1){
							return -1;
						}
				}

							pos_variable_local_actual++;
							num_variables_locales_actual++;
			}

	}

			
		
		strcpy($$.lexema,$1.lexema);	
		fprintf(fichero_salida,";R108:	<identificador> ::= TOK_IDENTIFICADOR\n");
};


%% 

int main(int argc, char* argv[])
{


if (argc != 3)
{
	printf("ERROR DE INVOCACION\n");
   return 1;
}

yyin = fopen(argv[1], "r");
if (yyin == NULL)
{
	printf("ERROR EN LA APERTURA DEL FICHERO DE ENTRADA\n");
   return 1;
}
yyout = fopen(argv[2], "w");
if (yyout  == NULL)
{
	printf("ERROR EN LA APERTURA DEL FICHERO DE SALIDA\n");
   return 1;
}

fichero_salida = fopen("sentencias.txt", "w");
if (fichero_salida == NULL)
{
	printf("ERROR EN LA APERTURA DEL FICHERO DE SALIDA\n");
   return 1;
}




salida_parser = yyparse();

fclose(yyin);
fclose(yyout);
fclose(fichero_salida);
return salida_parser;

}

void yyerror(char *s) { 
	if(error_morfologico == 0){
		fprintf(stderr,"\nERROR SINTACTICO: %d:%d\n",numero_linea,numero_caracter);
	}

		if(ts.global!=NULL){
		tseliminar(&ts);
}
  
} 
