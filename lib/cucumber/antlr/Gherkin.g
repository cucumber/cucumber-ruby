grammar Gherkin;

options {
  language = Java;
}

table	:	table_line+;

table_line	:	(NEWLINE) => NEWLINE | 
		BAR (table_cell BAR)+ (NEWLINE|EOF)
		;

table_cell	: (f=CELL_VALUE
	  | // nothing
	  );

NEWLINE	:	'\r'? '\n';

BAR	:	( WS* '|' WS*);

WS	:	(' ' | '\t');

CELL_VALUE
	:	~('\r' | '\n' | '|' | ' ')+;
