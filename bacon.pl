/*
  Proyecto 2 de Lab. De Lenguajes: (PROLOG)

      INTEGRANTES GRUPO 14:
		    Hector Dominguez  09-10241 
		    Miguel Fagundez   09-10264 
*/

/* Predicado Cliente */
brainfk:-
  write('Ingrese nombre de archivo: '),
  read(Archivo),
  cargar(Archivo,Contenido),
  write('Ingrese la longitud de la cinta: '),
  read(TamCinta),
  ejecutar(TamCinta,Contenido).

/* Predicado que inicializa una lista con K-1 ceros */
ceros(1,[]).
ceros(K,[0|Resto]):-
  K > 1,
  N is K-1,
  ceros(N,Resto).

/* Predicado que carga de un archivo los caracteres a una lista */
cargar(Archivo,Lista):-
  read_file_to_codes(Archivo,Lista,[]).

/* Ejecutar que inicializa la cinta:

K: Tamaño de la Cinta a utilizar
I: Lista de instrucciones bien formada */
ejecutar(K,I):- 
  ceros(K,L),
  ejecutar(0,estado([],0,L),I,_),!.


/* Ejecutar que lleva a cabo la ejecucion del programa:

NIVEL: Nivel en el que se esta ejecutando el programa
EI:    Estado inicial 
I:     Lista de instrucciones bien formadas
EFN:   Estado final */
ejecutar(_,EI,[],EI):- !.
ejecutar(NIVEL,EI,I,EFN):-
  ejecutarinstr(I,EI,EF,IS,NIVEL),
  ejecutar(NIVEL,EF,IS,EFN).


/* Predicados auxiliares que ejecutan cada instruccion */

/* Incremento y Decremento:

43:    ASCII para + 
45:    ASCII para -
IS:    Lista de instrucciones
ANT:   Lista que representa la cinta anterior al apuntador
ACT:   Valor que representa la casilla apuntada
NUACT: Valor que representa la NUEVA casilla apuntada
POST:  Lista que representa la cinta posterior al apuntador
*/
ejecutarinstr([43|IS],estado(ANT,ACT,POST),estado(ANT,NUACT,POST),IS,_):-
  NUACT is ACT+1. %Incremento
ejecutarinstr([45|IS],estado(ANT,ACT,POST),estado(ANT,NUACT,POST),IS,_):- 
  NUACT is ACT-1. %Decremento

/* Avance y retroceso:

62:    ASCII para >
60:    ASCII para <
IS:    Lista de instrucciones
ANT:   Lista que representa la cinta anterior al apuntador
NANT:  NUEVA Lista que representa la cinta anterior al apuntador
ACT:   Valor que representa la casilla apuntada
POST:  Lista que representa la cinta posterior al apuntador
NPOST: NUEVA Lista que representa la cinta posterior al apuntador
*/
ejecutarinstr([62|IS],estado(ANT,ACT,[]),estado(ANT,ACT,[]),IS,_).%Avance
ejecutarinstr([62|IS],estado(ANT,ACT,[POST|POSTS]),estado(NANT,POST,POSTS),IS,_):- 
  append(ANT,[ACT],NANT).%Avance

ejecutarinstr([60|IS],estado([],ACT,POST),estado([],ACT,POST),IS,_).%Retroceso
ejecutarinstr([60|IS],estado(ANT,ACT,POST),estado(NANT,X,NPOST),IS,_):- 
  buscarUlt(ANT,X), 
  append(NANT,[X],ANT),
  append([ACT],POST,NPOST).%Retroceso

/*Lectura y escritura:

44:    ASCII para ,
46:    ASCII para .
IS:    Lista de instrucciones
ANT:   Lista que representa la cinta anterior al apuntador
ACT:   Valor que representa la casilla apuntada
NUACT: NUEVO Valor que representa la casilla apuntada
POST:  Lista que representa la cinta posterior al apuntador
NPOST: NUEVA Lista que representa la cinta posterior al apuntador
*/
ejecutarinstr([44|IS],estado(ANT,_,POST),estado(ANT,NUACT,POST),IS,_):- 
  get_code(NUACT). %Lectura
ejecutarinstr([46|IS],estado(ANT,ACT,POST),estado(ANT,ACT,POST),IS,_):- 
  put_code(ACT).%Escritura

/* Iteracion:

91:    ASCII para \[ 
IS:    Lista de instrucciones
ANT:   Lista que representa la cinta anterior al apuntador
ACT:   Valor que representa la casilla apuntada
POST:  Lista que representa la cinta posterior al apuntador
IF:    Lista de instrucciones (Corresponde a instrucciones luego de ])
NIVEL: Nivel en el que se esta ejecutando el programa
NNIVEL:NUEVO Nivel en el que se esta ejecutando el programa
L:     Lista de instrucciones correspondientes SOLO al nivel actual
EF:    Corresponde al estado final luego de ejecutar ejecutainstr
*/
ejecutarinstr([91|IS],estado(ANT,0,POST),estado(ANT,0,POST),IF,_):- %CasoActual0
  omitirit(0,IS,IF).

ejecutarinstr([91|IS],estado(ANT,ACT,POST),EF,[91|IS],NIVEL):- %CasoIterar
  ACT > 0,
  NNIVEL is NIVEL +1,
  hacerlista(0,IS,L),
  ejecutar(NNIVEL,estado(ANT,ACT,POST),L,EF).

/* Caso Base: Cualquier otro caracter tomado como comentario */
ejecutarinstr([_|IS],estado(ANT,ACT,POST),estado(ANT,ACT,POST),IS,_).

/* buscarUlt: busca el ultimo elemento de una lista:

X:  Ultimo elemento de la lista
LS: Lista
*/
buscarUlt([L|LS],X):- LS = [], X = L.
buscarUlt([_|LS],X):- buscarUlt(LS, X).

/* hacerlista: 

91:    ASCII para \[       
93:    ASCII para ] 
NIVEL: Numero de \[ encontrados
NNIVEL:NUEVO Numero de \[ encontrados
L:     Lista de instrucciones
IS:    Lista de instrucciones
*/
hacerlista(0,[93|_],[93]).
hacerlista(NIVEL,[93|IS],[93|L]):- 
  NNIVEL is NIVEL -1, 
  hacerlista(NNIVEL,IS,L).

hacerlista(NIVEL,[91|IS],[91|L]):- 
  NNIVEL is NIVEL + 1, 
  hacerlista(NNIVEL,IS,L).

hacerlista(NIVEL,[I|IS],[I|L]):- 
  hacerlista(NIVEL,IS,L).

/* omitirit: omite todas las instrucciones hasta encontrar un ]

NIVEL:     Numero de \[ encontrados
NIVELELEM: NUEVO Numero de \[ encontrados
IS:        Lista de instrucciones
IF:        Lista de instrucciones (Corresponde a instrucciones luego de ])
*/
omitirit(NIVEL,[91|IS],IF):-
  NIVELELEM is NIVEL+1,
  omitirit(NIVELELEM,IS,IF).

omitirit(0,[93|IS],IS):- !.

omitirit(NIVEL,[93|IS],IF):-  
  NIVELELEM is NIVEL- 1,
  omitirit(NIVELELEM,IS,IF).

omitirit(NIVEL,[_|IS],IF):- 
  omitirit(NIVEL,IS,IF). 
