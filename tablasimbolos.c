/**
 * @file tablasimbolos.c
 * @author Juan Carlos Pereira, Jorge Ruiz
 * @brief Funciones (desarrolladas) asociadas a la tabla de simbolos.
 */

#include "tablasimbolos.h"

/**
 * @brief Crea una de simbolos, reservando para la tabla global y dejando a NULL la tabla local.
 * @param ts Tabla de simbolos que se va a crear.
 */
void tscreartabla(TablaSimbolos *ts, int size){
	if(ts == NULL){
		return;
	}
	ts->global = (Hashtable*) malloc(sizeof(Hashtable));
	if(ts->global == NULL) {
		printf("ERROR AL RESERVAR MEMORIA EN LA TABLA GLOBAL\n");
		return;
	}
	hcreartabla(ts->global, size);
	ts->local = NULL;
}

/**
 * @brief Inserta un valor en la tabla de simbolos, en la local en caso de haber una, en caso contrario en la global.
 * @param ts Tabla de simbolos en la que se realiza la insercion.
 * @param k Clave que se usa para acceder a su valor asociado.
 * @param v Valor asociado a la clave k.
 * @return 2 en caso de insertar en la tabla local, 1 en la global y -1 en caso de error.
 */


int tsinsertar(TablaSimbolos *ts, Clave k[MAX_LENGHT], Categoria categoria, Clase clase, 
	Tipo tipo, int num_variables, int pos_variable, int numero_parametro, int pos_parametro, int tamanho){
	Valor v;
	if(ts == NULL ){
		return -1;
	}
	strcpy(v.lexema,k);
	v.categoria = categoria;
	v.clase = clase;
	v.tipo = tipo;
	v.num_variables = num_variables;
	v.pos_variable = pos_variable;
	v.num_parametro = numero_parametro;
	v.pos_parametro = pos_parametro;
	v.tamanho = tamanho;

	if(ts->local != NULL){
	return	hinsertar(ts->local, k,  v)== FALSE ? -1 : 2;

	}else {

		return	hinsertar(ts->global, k,  v)== FALSE ? -1 : 1;
	}


}
/**
 * @brief Obtiene el valor asociado a una clave primero comprobando la tabla local y luego la global.
 * @param ts Tabla de simbolos.
 * @param k Clave que se usara para obtener su valor asociado.
 * @return Valor asociado a una clave.
 */

Valor* tsbuscar(TablaSimbolos* ts,Clave k[MAX_LENGHT], int * posicion){
	Valor* valor = NULL;
	/*1 Global*/
	/*2 Local*/
	if(ts == NULL || posicion == NULL){
		return NULL;
	}

	if(ts->local != NULL){
        valor = hbuscar(ts->local,k);
	}
	if(valor == NULL){

		*posicion = 1;
		return hbuscar(ts->global,k);
	}
	*posicion = 2;
	return valor;

}

/**
 * @brief Inicializa la tabla a nivel local
 * @param ts Tabla de simbolos.
 */

void tscrealocal(TablaSimbolos *ts, int size){
	if(ts == NULL){
		return;
	} else if(ts->local != NULL){
		return;
	} else{
		ts->local = (Hashtable*) malloc(sizeof(Hashtable));
		if(ts->local == NULL){
		printf("ERROR AL RESERVAR MEMORIA EN LA TABLA LOCAL\n");
				return;
		}
		hcreartabla(ts->local, size);
		return;
	}

}

/**
 * @brief Elimina la tabla a nivel local
 * @param ts Tabla de simbolos.
 */

Boolean tseliminarlocal(TablaSimbolos *ts) {
	Boolean b;
	if(ts == NULL){
		return FALSE;
	} else if(ts->local == NULL){
		return FALSE;
	} else{
		b = heliminar(ts->local);
		if(b){
			free(ts->local);
		}
		ts->local = NULL;
		return b;
	}
}

/**
 * @brief Elimina la tabla de simbolos liberando toda la memoria reservada para la misma
 * @param ts Tabla de simbolos a ser eliminada.
 * @return TRUE en caso de haberse eliminado correctamente, FALSE en caso contrario.
 */

Boolean tseliminar(TablaSimbolos *ts) {
	Boolean b,a;
	if(ts == NULL){
		return FALSE;
	}

	if(ts->local != NULL){

		a = tseliminarlocal(ts);
	}

	if(ts->global != NULL){
		b = heliminar(ts->global);
		free(ts->global);
		
	}

		if(b == TRUE && a == TRUE) {
		    return b;

		}
		
	return FALSE;
}






