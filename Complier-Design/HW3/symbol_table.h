#pragma once
#include "base.h"
#include "decl_array.h"
#include "symbol_entry.h"

typedef struct symboltable {
    int level;
    SymbolEntry_t** entries;
    int size;
    int capacity;
} SymbolTable_t;

SymbolTable_t* newSymbolTable(int level);
void pushSTVarArray(SymbolTable_t* st, DeclArray_t* da, Type_t type);
SymbolEntry_t* findST(SymbolTable_t* st, char* name);
void printST(SymbolTable_t* st);
void freeST(SymbolTable_t* st);
