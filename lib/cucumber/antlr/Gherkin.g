grammar Gherkin;

options {
  output = AST;
  language = Java;
}

tokens {
  STEP;
  TABLE;
  TABLE_ROW;
  TABLE_CELL;
}

steps : step+;

step : STEP_KEYWORD WS line_to_eol -> ^(STEP STEP_KEYWORD line_to_eol);

line_to_eol : (options {greedy=false;} : .)* (NEWLINE|EOF)!;

table	:	table_row+ -> ^(TABLE table_row+);

table_row	:	(NEWLINE) => NEWLINE | 
		BAR (table_cell BAR)+ (NEWLINE|EOF) -> ^(TABLE_ROW table_cell+)
		;

table_cell	: CELL_VALUE -> ^(TABLE_CELL CELL_VALUE);

NEWLINE	:	'\r'? '\n';

BAR	:	WS* '|' WS*;

WS	:	' ' | '\t';

STEP_KEYWORD : 'Given' | 'When';

CELL_VALUE
	:	~('\r' | '\n' | '|' | ' ')+;
