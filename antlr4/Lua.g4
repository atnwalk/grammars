/*

// This grammar was adopted from the Nautilus project and transformed into the ANTLR4 format.
// see: Aschermann, Cornelius, et al. "NAUTILUS: Fishing for Deep Bugs with Grammars." NDSS. 2019.

// Copyright (C) 2023  Maik Betka
// Copyright (C) 2020  Daniel Teuchert, Cornelius Aschermann, Sergej Schumilo

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.

// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

grammar Lua;

start: program;

program: (statement '\n')+;

statement:
    'break'
    | var ' = ' expr
    | 'local ' varlist ' = ' exprlist
    | function
    | coroutine
    | conditional
    | loop
    | 'return ' exprlist
    | 'goto ' LABELNAME
    | '::' LABELNAME '::'
;

LABELNAME:
    'labela'
    | 'labelb'
;

function: funcdef ' (' functionargs ') ' program '\nend'
;

funcdef:
    'function ' var '.' IDENTIFIER
    | 'function ' var ':' IDENTIFIER
    | 'function ' IDENTIFIER
;

lambda: 'function (' functionargs ') ' program '\nend'
;

functionargs: functionarglist?
;

functionarglist:
    var ', ' functionarglist
    | var
    | '...'
;

coroutine:
    var ' = coroutine.create(' lambda ')'
    | var ' = coroutine.wrap(' lambda ')'
    | 'coroutine.resume(' var ', ' args ')'
    | 'coroutine.yield(' args ')'
;

// functioncall:
//     IDENTIFIER ' ' args
//     | expr ':' IDENTIFIER ' ' args
//     | expr '.' IDENTIFIER ' ' args
// ;

args:
    '(' exprlist ')'
    | tableconstructor
    | literalstring
;

conditional:
    'if ' expr ' then\n' program '\nend'
    | 'if ' expr ' then\n' program '\nelse' program '\nend'
;

loop:
    'while (' expr ')\ndo\n' program '\nend'
    | 'for ' var '=' expr ', ' expr ', ' expr '\ndo\n' program '\nend'
    | 'repeat\n' program '\nuntil (' expr ')'
;

exprlist:
    expr ', ' exprlist
    | expr
;

expr:
    '(nil)'
    | '(false)'
    | '(true)'
    | '(' NUMERAL ')'
    | literalstring
    | tableconstructor
    | '(' var '[' expr '])'
    | '(' expr binop expr ')'
    | '(' unop expr ')'
    | lambda
    | var
    | IDENTIFIER ' ' args
    | expr ':' IDENTIFIER ' ' args
    | expr '.' IDENTIFIER ' ' args
    | '(' expr ')'
    | '...'
;

binop:
    '+'
    | '-'
    | '*'
    | '/'
    | '//'
    | '^'
    | '%'
    | '&'
    | '~'
    | '|'
    | '>>'
    | '<<'
    | ' .. '
    | '<'
    | '<='
    | '>'
    | '>='
    | '=='
    | '~='
    | ' and '
    | ' or '
;

unop:
    '-'
    | ' not '
    | '#'
    | '~'
;

tableconstructor:
    '{' fieldlist '}'
;

metatable: var ' = setmetatable(' var ', ' tableconstructor ')'
;

fieldlist:
    field ',' fieldlist
    | field
;

field:
    '[' expr ']=' expr
    | IDENTIFIER '=' expr
    | expr
;

varlist:
    var ', ' varlist
    | var
;

var:
    'a'
    | 'b'
    | 'c'
    | 'd'
    | 'e'
    | 'coroutine'
    | 'math'
    | 'io'
    | 'os'
    | 'package'
    | 'string'
    | 'table'
    | 'utf8'
    | 'self'
;

literalstring:
    '"' string '"'
    | '[[' string ']]'
;

string:
    STRCHR*
;

STRCHR: 
    NEWLINE
    | '\r'
    | ' '
    | '\t'
    | '0'
    | '/'
    | '.'
    | '$'
    | ESCAPESEQUENCE
;

ESCAPESEQUENCE:
    '\\a'
    | '\\b'
    | '\\f'
    | '\\n'
    | '\\r'
    | '\\t'
    | '\\v'
    | '\\z'
    | NEWLINE
    | '\\x' HEXADECIMAL
    | '\\u{' HEXADECIMAL '}'
;

NEWLINE: '\n'
;

NUMERAL:
    DECIMAL
    | '0x' HEXADECIMAL
;

DECIMAL:
    DECIMALDIGIT+ (('.' DECIMALDIGIT+)? ('e' | 'e-') DECIMALDIGIT+)?
;

HEXADECIMAL:
    HEXDIGIT+ (('.' HEXDIGIT+)? ('p' | 'p-') HEXDIGIT+)?
;

DECIMALDIGIT: '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
;

HEXDIGIT: 'a' | 'b' | 'c' | 'd' | 'e' | 'f' | 'A' | 'B' | 'C' | 'D' | 'E' | 'F' | DECIMALDIGIT
;

IDENTIFIER:
    'abs'
    | 'acos'
    | '__add'
    | 'asin'
    | 'assert'
    | 'atan'
    | 'byte'
    | '__call'
    | 'ceil'
    | 'char'
    | 'charpattern'
    | 'clock'
    | 'close'
    | 'codepoint'
    | 'codes'
    | 'collectgarbage'
    | '__concat'
    | 'concat'
    | 'config'
    | 'coroutine'
    | 'cos'
    | 'cpath'
    | 'create'
    | 'date'
    | 'debug'
    | 'deg'
    | 'difftime'
    | '__div'
    | 'dofile'
    | 'dump'
    | '__eq'
    | 'error'
    | 'exit'
    | 'exp'
    | 'find'
    | 'floor'
    | 'flush'
    | 'fmod'
    | 'format'
    | 'G'
    | 'getenv'
    | 'gethook'
    | 'getinfo'
    | 'getlocal'
    | 'getmetatable'
    | 'getregistry'
    | 'getupvalue'
    | 'getuservalue'
    | 'gmatch'
    | 'gsub'
    | 'huge'
    | '__index'
    | 'input'
    | 'insert'
    | 'io'
    | 'ipairs'
    | 'isyieldable'
    | '__le'
    | 'len'
    | 'lines'
    | 'load'
    | 'loaded'
    | 'loadfile'
    | 'loadlib'
    | 'log'
    | 'lower'
    | '__lt'
    | 'match'
    | 'math'
    | 'max'
    | 'maxinteger'
    | 'min'
    | 'mininteger'
    | '__mod'
    | 'modf'
    | 'move'
    | '__mul'
    | '__newindex'
    | 'next'
    | 'offset'
    | 'open'
    | 'os'
    | 'output'
    | 'pack'
    | 'package'
    | 'packsize'
    | 'pairs'
    | 'path'
    | 'pcall'
    | 'pi'
    | 'popen'
    | 'preload'
    | 'print'
    | 'rad'
    | 'random'
    | 'randomseed'
    | 'rawequal'
    | 'rawget'
    | 'rawlen'
    | 'rawset'
    | 'read'
    | 'remove'
    | 'rename'
    | 'rep'
    | 'require'
    | 'resume'
    | 'reverse'
    | 'running'
    | 'searchers'
    | 'searchpath'
    | 'seek'
    | 'select'
    | 'self'
    | 'sethook'
    | 'setlocal'
    | 'setlocale'
    | 'setmetatable'
    | 'setupvalue'
    | 'setuservalue'
    | 'setvbuf'
    | 'sin'
    | 'sort'
    | 'sqrt'
    | 'status'
    | 'stderr'
    | 'stdin'
    | 'stdout'
    | 'string'
    | '__sub'
    | 'sub'
    | 'table'
    | 'tan'
    | 'time'
    | 'tmpfile'
    | 'tmpname'
    | 'tointeger'
    | 'tonumber'
    | '__tostring'
    | 'tostring'
    | 'traceback'
    | 'type'
    | 'ult'
    | '__unm'
    | 'unpack'
    | 'upper'
    | 'upvalueid'
    | 'upvaluejoin'
    | 'utf8'
    | '_VERSION'
    | 'wrap'
    | 'write'
    | 'xpcall'
    | 'yield'
;

