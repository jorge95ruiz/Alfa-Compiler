/**
 * @file tablasimbolos.h
 * @author Juan Carlos Pereira, Jorge Ruiz
 * @brief Cabeceras de las funciones asociadas a la tabla de simbolos
 */
#include "tablahash.h"

typedef struct Tablas_Simbolos {

	Hashtable *global;
	Hashtable *local;

}TablaSimbolos;

void tscreartabla(TablaSimbolos *ts, int size);
int tsinsertar(TablaSimbolos *ts, Clave k[MAX_LENGHT], Categoria categoria, Clase clase, Tipo tipo, int num_variables, int pos_variable, int numero_parametro, int pos_parametro, int tamanho);
Valor* tsbuscar(TablaSimbolos* ts,Clave k[MAX_LENGHT], int * posicion);
void tscrealocal(TablaSimbolos *ts, int size);
Boolean tseliminarlocal(TablaSimbolos *ts);
Boolean tseliminar(TablaSimbolos *ts);

