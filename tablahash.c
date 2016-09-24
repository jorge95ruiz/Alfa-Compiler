/**
 * @file tablahash.c
 * @author Juan Carlos Pereira, Jorge Ruiz
 * @brief Funciones (desarrolladas) asociadas a la tabla hash.
 */


#include "tablahash.h"

/**
 * @brief Calcula la direccion (HashCode) en la que se hara la insercion del elemento.
 * @param k Clave que se usa para acceder a su valor asociado.
 * @param tam Tamaño de la tabla hash.
 * @return Devuelve un entero con la posición en la que se puede almacenar el valor.
 */

int hcalculadir(Clave k[MAX_LENGHT], unsigned int tam) {
    int i, sum =0 ;
    for(i = 0; i < strlen(k); i++){
        sum+=k[i];
    }
    sum = sum % tam;
    return sum;
}
/**
 * @brief Crea una tabla hash, reservando memoria para la misma e inicializandola.
 * @param t Tabla hash que se va a crear.
 * @param size Tamaño de la tabla hash que se va a crear.
 */

void hcreartabla(Hashtable* t, int size){
    int i;
    t->tam = size;
    t->espacios = (Espacio *) malloc(sizeof(Espacio)* size);
    if(t->espacios == NULL){
        printf("ERROR EN LA RESERVA DE MEMORIA DE LA TABLA HASH\n");
        return;
    }
    for(i=0; i <size; i++){
        strcpy(t->espacios[i].clave ,"");
    }
}



/**
 * @brief Redimensiona una tabla hash, reservando memoria para la misma e inicializandola.
 * @param t Tabla hash que se va a redimensionar.
 */

void redimensionartabla(Hashtable* t){
    int i, size;

    Hashtable* re = NULL;
	re = (Hashtable*) malloc (sizeof(Hashtable));

    if(t == NULL || re == NULL){
        printf("ERROR EN LA REDIMENSION DE LA TABLA\n");
        return;
    }
    
    if(t->espacios == NULL) {
         printf("ERROR EN LA REDIMENSION DE LA TABLA\n");
         return;
    }

	size = t->tam*2;
    hcreartabla(re, size);
    for(i=0; i < t->tam ; i++){
        hinsertar(re, t->espacios[i].clave, t->espacios[i].valor);
    }
		
    free(t->espacios);
    t->espacios = re->espacios;
    t->tam = re->tam;
    free(re);
	return;
}
/**
 * @brief Inserta un valor en un espacio de la tabla hash asociandolo a una clave.
 * @param t Tabla hash en la que se realiza la insercion.
 * @param k Clave que se usa para acceder a su valor asociado.
 * @param v Valor asociado a la clave k.
 * @return FALSE en caso de no haberse podido realizar la insercion, TRUE en caso contrario.
 */
Boolean hinsertar(Hashtable* t, Clave k[MAX_LENGHT], Valor v){
    int dir = 0, i = 0;
    /*La clave no puede ser una cadena vacia*/
    
    if(strlen(k) == 0 || t == NULL){
        return FALSE;
    }
    dir = hcalculadir(k, t->tam);

    /*Estableceremos una clave para un valor en caso de que no la haya y si la hay se sustituye */
    if(strlen(t->espacios[dir].clave) == 0 || strcmp(t->espacios[dir].clave, k) == 0 ){
    	strcpy(t->espacios[dir].clave,k);
        t->espacios[dir].valor = v;
        return TRUE;
    } else if (strcmp(k,t->espacios[dir].clave) != 0){

    /*En caso de que el codigo hash sea el mismo pero la clave diferente, buscamos en otras posiciones de la tabla*/
        for(i = 0; i < t->tam ; i++ ){
        	/*Se realiza una busqueda lineal pero hay que comprobar que no haya un valor asociado a la nueva clave*/
        	if(strcmp(t->espacios[i].clave,k) == 0){
			strcpy(t->espacios[i].clave,k);
               		 t->espacios[i].valor = v;
        		return TRUE;
        	}
            if(strcmp(t->espacios[i].clave,"") == 0){
            	strcpy(t->espacios[i].clave,k);
                t->espacios[i].valor = v;
                return TRUE;
            }
        }
        /*redimensionartabla(t);*/
        return hinsertar(t, k, v);

    }
    
    return FALSE;
}

/**
 * @brief Permite saber si la clave tiene un valor asociado.
 * @param t Tabla hash.
 * @param k Clave a comprobar si se encuentra disponible.
 * @return FALSE en caso de no estar ocupada la clave, TRUE en caso contrario.
 */
int hasociada(Hashtable* t,Clave k[MAX_LENGHT]){
    int dir= 0;
    if(t == NULL || strlen(k) == 0){
        return -1;
    }
    
    dir = hcalculadir(k, t->tam);
    if(strcmp(t->espacios[dir].clave, k) == 0){
        return dir;
    }
    
    return -1;
}

/**
 * @brief Obtiene el valor asociado a una clave.
 * @param t Tabla hash.
 * @param k Clave que se usara para obtener su valor asociado.
 * @return Valor asociado a una clave.
 */

Valor* hbuscar(Hashtable* t,Clave k[MAX_LENGHT]){
    int dir = 0;
    int i = 0;

    if(t == NULL || strlen(k) == 0){
        return NULL;
    }
    
    /*Puede darse el caso de que la direccion no este asociada con esa clave exactamente por ello se realiza la comprobacion*/
    dir = hasociada(t,k);
    if(dir != -1){
    	return &(t->espacios[dir].valor);
    }
    /*En caso de no estar asociada se realiza una busqueda lineal*/
    for(i= 0; i<t->tam;i++){
        if(strcmp(t->espacios[i].clave,k) == 0){
    	    return &(t->espacios[i].valor);
    	}
    }

    return NULL;
}
/**
 * @brief Elimina la tabla hash liberando toda la memoria reservada.
 * @param t Tabla hash.
 * @return TRUE en caso de haber eliminado satisfactoriamente la tabla hash, FALSE en caso contrario.
 */
Boolean heliminar(Hashtable* t) {
	if(t == NULL){
		return FALSE;
	}

	free(t->espacios);
	return TRUE;
}
