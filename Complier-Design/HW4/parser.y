%{
#include "everything.h"
#include "util.h"
#include <stdio.h>
#include <stdlib.h>

extern int linenum;
extern FILE *yyin;
extern char *yytext;
extern char buf[256];
extern TableStack_t* ts;
extern Type_t cur_type;

int yylex();
int yyerror( char *msg );

%}

%token<text>  ID
%token<literal>  INT_CONST
%token<literal>  FLOAT_CONST
%token<literal>  SCIENTIFIC
%token<literal>  STR_CONST

%token  LE_OP
%token  NE_OP
%token  GE_OP
%token  EQ_OP
%token  AND_OP
%token  OR_OP

%token  READ
%token  BOOLEAN
%token  WHILE
%token  DO
%token  IF
%token  ELSE
%token<literal>  TRUE
%token<literal>  FALSE
%token  FOR
%token<type>  INT
%token  PRINT
%token<type>  BOOL
%token  VOID
%token<type>  FLOAT
%token<type>  DOUBLE
%token<type>  STRING
%token  CONTINUE
%token  BREAK
%token  RETURN
%token  CONST

%token  L_PAREN
%token  R_PAREN
%token  COMMA
%token  SEMICOLON
%token  ML_BRACE
%token  MR_BRACE
%token  L_BRACE
%token  R_BRACE
%token  ADD_OP
%token  SUB_OP
%token  MUL_OP
%token  DIV_OP
%token  MOD_OP
%token  ASSIGN_OP
%token  LT_OP
%token  GT_OP
%token  NOT_OP

/*  Program 
    Function 
    Array 
    Const 
    IF 
    ELSE 
    RETURN 
    FOR 
    WHILE
*/

%union {
    char* text;
    Literal_t* literal;
    IntArray_t* iarray;
    DeclItem_t* decl_item;
    DeclArray_t* decl_array;
    Type_t type;
}

%type<iarray> dim dimension;
%type<literal> literal_const;
%type<decl_array> parameter_list;
%type<type> element logical_expression variable_reference logical_term;
%type<type> logical_factor relation_expression arithmetic_expression;
%type<type> term factor sign_literal_const scalar_type;
%start program
%%

program : decl_list funct_def decl_and_def_list 
        ;

decl_list : decl_list var_decl
          | decl_list const_decl
          | decl_list funct_decl
          |
          ;


decl_and_def_list : decl_and_def_list var_decl
                  | decl_and_def_list const_decl
                  | decl_and_def_list funct_decl
                  | decl_and_def_list funct_def
                  | 
                  ;

funct_def : scalar_type ID L_PAREN R_PAREN {
                pushSTFunc(getTopTS(ts), $2, $1, NULL, 0);
            }
            compound_statement 
          | scalar_type ID L_PAREN parameter_list R_PAREN {
                pushSTFunc(getTopTS(ts), $2, $1, $4, 0);
            } L_BRACE {
                pushTS(ts); 
                pushSTParamArray(getTopTS(ts), $4);
            }
            var_const_stmt_list R_BRACE {
                printST(getTopTS(ts));
                popTS(ts);
                freeDeclArray($4);
            }
          | VOID ID L_PAREN R_PAREN {
                pushSTFunc(getTopTS(ts), $2, _void, NULL, 0);
            }
            compound_statement 
          | VOID ID L_PAREN parameter_list R_PAREN {
                pushSTFunc(getTopTS(ts), $2, _void, $4, 0);
            } L_BRACE {
                pushTS(ts);
                pushSTParamArray(getTopTS(ts), $4);
            }
            var_const_stmt_list R_BRACE {
                printST(getTopTS(ts));
                popTS(ts);
                freeDeclArray($4);
            }
          ;

funct_decl : scalar_type ID L_PAREN R_PAREN SEMICOLON { pushSTFunc(getTopTS(ts), $2, $1, NULL, 1); }
           | scalar_type ID L_PAREN parameter_list R_PAREN SEMICOLON { pushSTFunc(getTopTS(ts), $2, $1, $4, 1), freeDeclArray($4); }
           | VOID ID L_PAREN R_PAREN SEMICOLON { pushSTFunc(getTopTS(ts), $2, _void, NULL, 1); }
           | VOID ID L_PAREN parameter_list R_PAREN SEMICOLON { pushSTFunc(getTopTS(ts), $2, _void, $4, 1), freeDeclArray($4); }
           ;

parameter_list : parameter_list COMMA scalar_type ID { $$ = pushDeclArray($1, newDeclItem($4, $3, NULL)); }
               | parameter_list COMMA scalar_type ID dim { $$ = pushDeclArray($1, newDeclItem($4, $3, $5)); }
               | scalar_type ID dim { $$ = pushDeclArray(newDeclArray(), newDeclItem($2, $1, $3)); }
               | scalar_type ID { $$ = pushDeclArray(newDeclArray(), newDeclItem($2, $1, NULL)); }
               ;

var_decl : scalar_type identifier_list SEMICOLON

identifier_list : identifier_list COMMA ID { pushSTVar(getTopTS(ts), $3, NULL); }
                | identifier_list COMMA ID ASSIGN_OP logical_expression { pushSTVar(getTopTS(ts), $3, NULL); }
                | identifier_list COMMA ID dim ASSIGN_OP initial_array { pushSTVar(getTopTS(ts), $3, $4); }
                | identifier_list COMMA ID dim { pushSTVar(getTopTS(ts), $3, $4); }
                | ID dim ASSIGN_OP initial_array { pushSTVar(getTopTS(ts), $1, $2); }
                | ID dim { pushSTVar(getTopTS(ts), $1, $2); }
                | ID ASSIGN_OP logical_expression { pushSTVar(getTopTS(ts), $1, NULL); }
                | ID { pushSTVar(getTopTS(ts), $1, NULL); }
                ;

initial_array : L_BRACE literal_list R_BRACE
              ;

literal_list : literal_list COMMA logical_expression
             | logical_expression
             | 
             ;

const_decl : CONST scalar_type const_list SEMICOLON

const_list : const_list COMMA ID ASSIGN_OP literal_const { pushSTConst(getTopTS(ts), $3, $5); }
           | ID ASSIGN_OP literal_const { pushSTConst(getTopTS(ts), $1, $3); }
           ;

dim : dim ML_BRACE INT_CONST MR_BRACE { $$ = pushIntArray($1, $3->ival); }
    | ML_BRACE INT_CONST MR_BRACE { $$ = pushIntArray(newIntArray(), $2->ival); }
    ;

compound_statement : L_BRACE { pushTS(ts); } var_const_stmt_list R_BRACE { printST(getTopTS(ts)); popTS(ts);}
                   ;

var_const_stmt_list : var_const_stmt_list statement 
                    | var_const_stmt_list var_decl
                    | var_const_stmt_list const_decl
                    |
                    ;

statement : compound_statement
          | simple_statement
          | conditional_statement
          | while_statement
          | for_statement
          | function_invoke_statement
          | jump_statement
          ;     

simple_statement : variable_reference ASSIGN_OP logical_expression SEMICOLON
                 | PRINT logical_expression SEMICOLON
                 | READ variable_reference SEMICOLON
                 ;

conditional_statement : IF L_PAREN logical_expression R_PAREN compound_statement
                      | IF L_PAREN logical_expression R_PAREN 
                            compound_statement
                        ELSE
                            compound_statement
                      ;
while_statement : WHILE L_PAREN logical_expression R_PAREN
                    compound_statement
                | DO compound_statement WHILE L_PAREN logical_expression R_PAREN SEMICOLON
                ;

for_statement : FOR L_PAREN initial_expression_list SEMICOLON control_expression_list SEMICOLON increment_expression_list R_PAREN 
                    compound_statement
              ;

initial_expression_list : initial_expression
                        |
                        ;

initial_expression : initial_expression COMMA variable_reference ASSIGN_OP logical_expression
                   | initial_expression COMMA logical_expression
                   | logical_expression
                   | variable_reference ASSIGN_OP logical_expression

control_expression_list : control_expression
                        |
                        ;

control_expression : control_expression COMMA variable_reference ASSIGN_OP logical_expression
                   | control_expression COMMA logical_expression
                   | logical_expression
                   | variable_reference ASSIGN_OP logical_expression
                   ;

increment_expression_list : increment_expression 
                          |
                          ;

increment_expression : increment_expression COMMA variable_reference ASSIGN_OP logical_expression
                     | increment_expression COMMA logical_expression
                     | logical_expression
                     | variable_reference ASSIGN_OP logical_expression
                     ;

function_invoke_statement : ID L_PAREN logical_expression_list R_PAREN SEMICOLON
                          | ID L_PAREN R_PAREN SEMICOLON
                          ;

jump_statement : CONTINUE SEMICOLON
               | BREAK SEMICOLON
               | RETURN logical_expression SEMICOLON
               ;

variable_reference : ID dimension { $$ = getType(ts, $1, $2, false); }
                   | ID { $$ = getType(ts, $1, NULL, false); }
                   ;


logical_expression : logical_expression OR_OP logical_term { $$ = checkLogic($1, $3); }
                   | logical_term
                   ;

logical_term : logical_term AND_OP logical_factor { $$ = checkLogic($1, $3); }
             | logical_factor
             ;

logical_factor : NOT_OP logical_factor { $$ = checkULogic($2); }
               | relation_expression
               ;

relation_expression : relation_expression relation_operator arithmetic_expression { $$ = checkRelation($1, $3); }
                    | relation_expression NE_OP arithmetic_expression { $$ = checkEQNEQ($1, $3); }
                    | relation_expression EQ_OP arithmetic_expression { $$ = checkEQNEQ($1, $3); }
                    | arithmetic_expression
                    ;

relation_operator : LT_OP
                  | LE_OP
                  | GE_OP
                  | GT_OP
                  ;

arithmetic_expression : arithmetic_expression ADD_OP term { $$ = checkArith($1, $3); }
                      | arithmetic_expression SUB_OP term { $$ = checkArith($1, $3); }
                      | term
                      ;

term : term MUL_OP factor { $$ = checkArith($1, $3); }
     | term DIV_OP factor { $$ = checkArith($1, $3); }
     | term MOD_OP factor { $$ = checkMod($1, $3); }
     | factor
     ;

factor : sign_literal_const
       | element
       ;

element : SUB_OP element { $$ = checkUMinus($2); }
        | variable_reference
        | L_PAREN logical_expression R_PAREN { $$ = $2; }
        | ID L_PAREN logical_expression_list R_PAREN { $$ = getType(ts, $1, NULL, true); }
        | ID L_PAREN R_PAREN { $$ = getType(ts, $1, NULL, true); }
        ;



logical_expression_list : logical_expression_list COMMA logical_expression
                        | logical_expression
                        ;


dimension : dimension ML_BRACE logical_expression MR_BRACE { checkArraySubscript($3), $$ = pushIntArray($1, 0); }
          | ML_BRACE logical_expression MR_BRACE { checkArraySubscript($2), $$ = pushIntArray(newIntArray(), 0); }
          ;



scalar_type : INT { $$ = cur_type = $1; }
            | DOUBLE { $$ = cur_type = $1; }
            | STRING { $$ = cur_type = $1; }
            | BOOL { $$ = cur_type = $1; }
            | FLOAT { $$ = cur_type = $1; }
            ;

sign_literal_const : SUB_OP sign_literal_const { $$ = checkUMinus($2); }
                   | literal_const { $$ = $1->type; }
                   ;

literal_const : INT_CONST
              | FLOAT_CONST
              | SCIENTIFIC
              | STR_CONST
              | TRUE
              | FALSE
              ;


%%

int yyerror( char *msg )
{
    fprintf( stderr, "\n|--------------------------------------------------------------------------\n" );
    fprintf( stderr, "| Error found in Line #%d: %s\n", linenum, buf );
    fprintf( stderr, "|\n" );
    fprintf( stderr, "| Unmatched token: %s\n", yytext );
    fprintf( stderr, "|--------------------------------------------------------------------------\n" );
    exit(-1);
    //  fprintf( stderr, "%s\t%d\t%s\t%s\n", "Error found in Line ", linenum, "next token: ", yytext );
}
