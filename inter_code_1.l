alpha [A-Za-z]
digit [0-9]

%%

"<="         return LE;
">="         return GE;
"=="         return EQ;
"!="         return NE;
"||"         return OR;
"&&"         return AND;
for          return FOR;
while        return WHILE;
if           return IF;
then         return THEN;
else         return ELSE;
switch       return SWITCH;
case         return CASE;
break 	     return BREAK;
default      return DEFAULT;

{digit}+    { return NUM;}
{alpha}({alpha}|{digit})* return ID;

[ \t\n]        ;
.            return yytext[0];

%%

