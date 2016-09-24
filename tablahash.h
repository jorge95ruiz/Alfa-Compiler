/**
 * @file tablahash.h
 * @author Juan Carlos Pereira, Jorge Ruiz
 * @brief Cabeceras de las funciones asociadas a la tabla hash
 * <br/> al igual que  constantes, enumeraciones y estructuras asociadas a la tabla.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LENGHT 50
#define TABLATAM 100
#define Clave char
#define Valor Identificiador
typedef enum Categorias {VARIABLE = 1, PARAMETRO = 2, FUNCION= 3} Categoria;
typedef enum Tipos {INT=1, BOOLEAN = 2} Tipo;
typedef enum Clases {ESCALAR = 1, VECTOR = 2} Clase;
/* True  si es vector y false si no lo es*/
typedef enum Booleanos {TRUE = 1, FALSE = 0} Boolean;

/**
 * @brief Estructura de las identificadores del lenguaje Alpha.
 *
 */
typedef struct Identificiadores {
	char lexema[MAX_LENGHT];
	Categoria categoria;
	Clase clase;
	Tipo tipo;
	int tamanho;
	int num_variables;
	int pos_variable;
	int num_parametro;
	int pos_parametro;

} Identificiador;


/**
 * @brief Estructura de cada uno de los espacios de la tabla hash.
 *
 * 2 variables dentro de la estructura: una clave y el valor asociado a la clave.
 **/
typedef struct Espacios {
	Clave clave[MAX_LENGHT];
	Valor valor;
} Espacio;

/**
 * @brief Estructura de la tabla hash.
 *
 * 3 variables dentro de la estructura: los espacios en los que se almacenaran claves y <br/>
 * valores y por otro lado el tamaño de la tabla (un entero).
 **/

typedef struct TablaHash {
   Espacio *espacios;
   unsigned int tam;
} Hashtable;

void redimensionartabla(Hashtable* t);
void hcreartabla(Hashtable* t, int size);
int hcalculadir(Clave k[MAX_LENGHT], unsigned int tam);
Boolean hinsertar(Hashtable* t, Clave k[MAX_LENGHT], Valor v);
int hasociada(Hashtable* t,Clave k[MAX_LENGHT]);
Valor* hbuscar(Hashtable* t,Clave k[MAX_LENGHT]);
Boolean heliminar(Hashtable* t);
