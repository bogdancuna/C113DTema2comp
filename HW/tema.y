%{
	#include <stdio.h>
	#include <string.h>
    int EsteCorecta = 1;

	int yylex();
	int yyerror(const char *msg);
	char msg[500];

		class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;

%}

%union { char* sir; int val; }

%token T_PROGRAM T_VAR T_BEGIN T_END T_INTEGER T_READ T_WRITE T_FOR T_DO T_TO
%token T_MUL T_DIV T_PLUS T_MINUS T_ATTR
%token T_ERR

%token <val> T_INT
%token <sir> T_ID

%type <val> E
%type <val> F
%type <val> T

%start prog

%%

prog :
	T_PROGRAM T_ID T_VAR dec_list T_BEGIN stmt_list T_END '.'
	|
	error
	{  EsteCorecta=0; }
	;
dec_list:
	|
	dec
	|
	dec_list ';' dec
	;
dec:
	|
	id_list_dec ':' T_INTEGER
	;
id_list_read:
	|
	id_read
	|
	id_list_read ',' id_read
	;
id_read:
	|
	T_ID
	{
		if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
		int a;
		scanf("%d", &a);
	    ts->setValue($1, a);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;
	}
      }
	;
id_list_dec:
	|
	T_ID
	 {
	if(ts != NULL)
	{
	  if(ts->exists($1) == 0)
	  {
	    ts->add($1);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  ts = new TVAR();
	  ts->add($1);
	}
      }
	|
	id_list_dec ',' T_ID
	 {
	if(ts != NULL)
	{
	  if(ts->exists($3) == 0)
	  {
	    ts->add($3);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, $3);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  ts = new TVAR();
	  ts->add($3);
	}
      }
	;
id_list:
	|
	varfolosita
	|
	id_list ',' varfolosita
	;
varfolosita:
	|
	T_ID
	 {
	if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    if(ts->getValue($1) == -1)
	    {
	      sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, $1);
	      yyerror(msg);
	      YYERROR;
	    }
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;
	}
      }
	;
stmt_list:
	|
	stmt
	|
	stmt_list ';' stmt
	;
stmt:
	|
	T_ID T_ATTR E
	{
		if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    ts->setValue($1, $3);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;
	}
      }
	|
	T_READ '(' id_list_read ')'
	|
	T_WRITE '(' id_list ')'
	|
	T_FOR index_exp E T_DO body
	;
E:	T { $$ = $1; }
	|
	E T_PLUS T {$$ = $1 + $3; }
	|
	E T_MINUS T {$$ = $1 - $3; }
	;
T:	F { $$ = $1; }
	|
	T T_MUL F { $$ = $1 * $3; }
	|
	T T_DIV F 
	{ 
	if($3 == 0) 
	{ 
	    sprintf(msg,"%d:%d Eroare semantica: Impartire la zero!", @1.first_line, @1.first_column);
	    yyerror(msg);
	    YYERROR;
	} 
	else { $$ = $1 / $3; } 
	}
	;
F:	T_ID
	      {
	if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    if(ts->getValue($1) == -1)
	    {
	      sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, $1);
	      yyerror(msg);
	      YYERROR;
	    }
	    else
	    {
	      $$ = ts->getValue($1);
	    }
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;
	}
      }
	|
	T_INT { $$ = $1; }
	|
	'(' E ')' { $$ = $2; }
	;
index_exp:
	|
	T_ID T_ATTR E T_TO
	{
		if(ts != NULL)
	{
	  if(ts->exists($1) == 0)
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;
	}
    }
	;
body:
	stmt
	|
	T_BEGIN stmt_list T_END
	;
%%

int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}	

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}
