%{
#include<stdlib.h>
#include<stdio.h>
%}
%token ID NUM WHILE FOR IF THEN ELSE SWITCH CASE BREAK DEFAULT LE GE EQ NE OR AND
%right "=" 
%left OR AND
%left '>' '<'  
%left '+' '-' /* priority from left to right */
%left '*' '/'
%right UMINUS
%left '!'

%%

/*- Semantic action for different constructs are shown in the program (in comments) -- */

S : IF '(' E ')'{lab11();} THEN S|E ';'{lab21();} ELSE S|E ';' {lab31();} ';' /* SDT for accepting the IF-THEN-ELSE construct */| |  WHILE{lab1();} '(' E ')'{lab2();} '{' S|E  {lab3();}  '}' /* SDT for accepting the WHILE construct */ |FOR '(' E ';'{lab14();} E {lab24();}';' W {lab34();}')' '{' S|E';' {lab44();} '}' S|E ';' /* SDT for accepting the FOR construct */ | S1 /* SDT for accepting the SWITCH construct */
	;
T : IF '(' E ')'{lab11();} THEN S|E ';'{lab21();} ELSE S|E ';' {lab31();} ';'   |  WHILE{lab1();} '(' E ')'{lab2w();} '{' S|E  {lab3();}  '}' |FOR '(' E ';'{lab14();} E {lab2f();}';' W {lab34();}')' '{' S|E';' {lab44();} '}' S|E ';'
	;

S1:   SWITCH '(' E ')' '{' B '}' /*Switch*/
         ;
   
B       :    C
        |    C    D
        ;
   
C       :    C    C
        |    CASE E {lab12();} ':' T|E  {lab22();} ';' BREAK ';' /*Switch Cases*/
 	|    BREAK ';'
        ;

D       :    DEFAULT ':' T|E ';' {lab22();}  {lab44();} /*Default*/ 
        ;

//---------------------------------------------------------------------

/*For the evaluation of expressions*/
E :V '='{push();} E{gen_assign();}
  | E '+'{push();} E{gen();}
  | E '-'{push();} E{gen();}
  | E '*'{push();} E{gen();}
  | E '/'{push();} E{gen();}
  | E '&'{push();} E{gen();} /*SDT for bitwise operators(&,|)*/
  | E '|'{push();} E{gen();}
  | E '>'{push();} E{gen();} /*SDT for comparison operators(>,<)*/
  | E '<'{push();} E{gen();}
  | '(' E ')'
  | '-'{push();} E{gen_umin();} %prec UMINUS
  | V
  | NUM{push();} /*left side of expression is a number*/
  ;

W :V '='{push();} W{gen_assign();}
  | W '+'{push();} '=' W{gen1();} {gen_assign();} /*SDT for shorthand notations*/
  | W '-'{push();} '=' W{gen1();} {gen_assign();}
  | W '*'{push();} W{gen();}
  | W '/'{push();} W{gen();}
  | W '>'{push();} W{gen();}
  | W '<'{push();} W{gen();}
  | '(' W ')'
  | '-'{push();} W{gen_umin();} %prec UMINUS
  | V
  | NUM{push();}
  ;

V : ID {push();} /*left side of expression is an identifier*/
  ;

%%

#include "lex.yy.c"
#include<ctype.h>

char st[100][10]; /*2-D Character array for storing the operands and operators (FUNCTIONING AS A STACK)*/ 
int top=0; 
char i_[2]="0";
char temp[4]="t";
char tm='t';
int tc=0;
char temp2[2]="t";
int label[20]; /*For storing the labels*/
int start=0,last=0;
int lnum=0;
int ltop=0;
int s=0;
char st1[100][10];
char i_1[2]="0";
char temp1[2]="r";
int top1=0;
int label1[20];
int lnum1=0;
int ltop1=0;
int next=8;
int extra[10];int e=0;
char buffer[2];

/*Function for converting integer to string*/
void tostring(char str[], int num)
{
    int i, rem, len = 0, n;
    n = num;

    while (n != 0)
    {
        len++;
        n /= 10;
    }

    for (i = 0; i < len; i++)
    {
        rem = num % 10;
        num = num / 10;
        str[len - (i + 1)] = rem + '0';
    }

    str[len] = '\0';
}

/*Main Function*/
main(int argc,char *argv[])
{
    if(argc>1)
	{
		FILE *fp=fopen(argv[1],"r");
		if(!fp)
		{
			printf("error\n");
			exit(1);	
		}
		yyin=fp;
	}
    yyparse();
}

/*Push function for stack(st array declared above)*/
push()
{
   strcpy(st[++top],yytext); 
}
/*used to print out the pushed element in the stack*/
gen()
{
  printf("%c%d = %s %s %s\n",tm,tc,st[top-2],st[top-1],st[top]);
  tostring(buffer,tc);
  strcpy(st[top],temp2);
  strcat(st[top],buffer);
  tc++;
}

/*used to print out the pushed element in the stack*/
gen1()
{
  printf("%c%d = %s %s %s\n",tm,tc,st[top-2],st[top-1],st[top]);
  tostring(buffer,tc);
  strcpy(st[top],temp2);
  strcat(st[top],buffer);
  tc++;
}

/*for unary opertor minus*/
gen_umin()
{
  printf("%c%d = -%s\n",tm,tc,st[top]);
  top--;
  tostring(buffer,tc);
  strcpy(st[top],temp2);
  strcat(st[top],buffer);
  tc++;
}

/*used to pop from the stack*/
gen_assign()
{
  printf("%s = %s\n",st[top-2],st[top]);
  top-=2;
}

/*-----------------------IF-THEN-ELSE------------------------------*/

/*Semantic action for THEN part of IF statement*/ 
lab11()
{
  s=1;
  lnum++;
  printf("%c%d = not %s\n",tm,tc,st[top]);
  printf("if %c%d goto L%d\n",tm,tc,lnum);
  tc++;
  label[++ltop]=lnum;
  return;
}

/*Semantic action for ELSE part of IF statement*/
lab21()
{
 int x;
 lnum++;
 x=label[ltop--];
 printf("goto N%d\n",next);
 printf("L%d: \n",x);
 label[++ltop]=lnum;
 return;
}

/*Semantic action for jumping to the next*/ 
lab31()
{
 int y;
 y=label[ltop--];
 printf("N%d: \n",next);
 return ;
}

/*----------END OF IF-THEN-ELSE --------------------------------*/

/*--------------------SWITCH-------------------------------------*/

/*Semantic Action for checking the case constants*/
lab12()
{
 s=1;
 lnum1++;
 int x;
 printf("r%d: \n",lnum1-1);
 printf("%c%d = not %s\n",tm,tc,st[top]);
 printf("if %c%d goto r%d\n",tm,tc,lnum1);
 tc++;
 label1[++ltop1]=lnum1;
 return;
}

 /*Semantic Action for assigning the labels(to the end of each switch case)*/
lab22()
{
 int x;
 lnum1++;
 x=label1[ltop1--];
 printf("goto N%d\n",next);
 printf("r%d: \n",x);
 label1[++ltop1]=lnum1;
 return;
}

/*Semantic action for assigning label to the end of switch*/
lab32()
{
 int y;
 y=label1[ltop1--];
 printf("N%d: \n",next);
 return ;
}

int sat;int p=0;

/*-----------------------END OF SWITCH-------------------------*/

/*----------------------WHILE-----------------------------------*/

/*Semantic action for the assignment of labels to the beginning of WHILE loop*/
lab1()
{	
	p=1;
	lnum++;
    printf("L%d: \n",lnum);
	extra[e]=lnum;
	e++;
	sat=lnum;
}
/*Semantic Action for checking the conditions */
lab2()
{
    printf("%c%d = not %s\n",tm,tc,st[top]); 
    printf("if %c%d\n",tm,tc);
    tc++;
    label[++ltop]=lnum;
    lnum++;
    printf("goto L%d\n",lnum);
    label[++ltop]=lnum;
	++lnum;
    printf("L%d: \n",lnum);
    return;
}

lab2w()
{
    printf("%c%d = not %s\n",tm,tc,st[top]);
    printf("if %c%d\n",tm,tc);
    tc++;
    label[++ltop]=lnum;
    lnum++;
    printf("goto N%d\n",next);
    label[++ltop]=lnum;
	++lnum;
    printf("L%d: \n",lnum);
    return;
}

/*Semantic Action to assign label to the end of While Loop*/
lab3()
{
    int x;
    x=label[ltop--];
    printf("goto L%d \n",start);
    printf("L%d: \n",x);
    return;
}

/*------------------------END OF WHILE-------------------------*/

/*----------------------FOR-------------------------------*/

/*Semantic action after FOR is encountered in the input*/
lab14()
{
	start=lnum;
    printf("L%d: \n",lnum++);
}

/*Semantic action for the assignment of labels and  checking the conditions*/
lab24()
{
    printf("%c%d = not %s\n",tm,tc,st[top]);
    printf("if %c%d goto L%d\n",tm,tc,lnum);
    tc++;
    label[++ltop]=lnum;
    lnum++;
    printf("goto L%d\n",lnum);
    label[++ltop]=lnum;
    ++lnum;
    printf("L%d: \n",lnum);
	return;
 }

lab2f()
{
    printf("%c%d = not %s\n",tm,tc,st[top]);
    printf("if %c%d goto N%d\n",tm,tc,next);
    tc++;
    label[++ltop]=lnum;
    lnum++;
    printf("goto L%d\n",lnum);
    label[++ltop]=lnum;
    ++lnum;
    printf("L%d: \n",lnum);	
	return;
}

/*Semantic Action for updation */
lab34()
{
    int x;
    x=label[ltop--];
    printf("goto L%d \n",start);
    printf("L%d: \n",x);
    return;
}

/*Semantic Action to assign label to the end of FOR Loop*/
lab44()
{
    int x;
    x=label[ltop--];
	if(p==1)
    {
		printf("goto L%d \n",extra[e-1]);
		e--;
    }
	else
    printf("goto L%d \n",lnum);
	return;
}
//-----------------END OF FOR--------------------------*/
