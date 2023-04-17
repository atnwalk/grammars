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

grammar JavaScript;

start: program
;

program: (statement '\n')+
;

object: 
    IDENTIFIER 
    | '{' objmember '}' 
    | '{}'
;

objmember: VAR ': ' literal (', ' objmember)?
;

VAR:
    'a'
    | 'b'
    | 'c'
    | 'd'
    | 'e'
    | 'f'
    | 'g'
    | 'h'
;

METHODNAME:
    IDENTIFIER
    | 'eval'
    | 'uneval'
    | 'isFinite'
    | 'isNaN'
    | 'parseFloat'
    | 'parseInt'
    | 'decodeURI'
    | 'decodeURIComponent'
    | 'encodeURI'
    | 'encodeURIComponent'
    | 'escape'
    | 'unescape'
    | 'assign'
    | 'create'
    | 'defineProperty'
    | 'defineProperties'
    | 'entries'
    | 'freeze'
    | 'getOwnPropertyDescriptor'
    | 'getOwnPropertyDescriptors'
    | 'getOwnPropertyNames'
    | 'getOwnPropertySymbols'
    | 'getPrototypeOf'
    | 'is'
    | 'isExtensible'
    | 'isFrozen'
    | 'isSealed'
    | 'keys'
    | 'preventExtensions'
    | 'seal'
    | 'setPrototypeOf'
    | 'values'
    | 'delete'
    | '__defineGetter__'
    | '__defineSetter__'
    | '__lookupGetter__'
    | '__lookupSetter__'
    | HASOWNPROPERTY
    | 'isPrototypeOf'
    | 'propertyIsEnumerable'
    | 'toSource'
    | 'toString'
    | 'unwatch'
    | 'valueOf'
    | 'watch'
    | 'apply'
    | 'bind'
    | 'call'
    | 'isGenerator'
    | 'for'
    | 'keyFor'
    | 'stringify'
    | 'isInteger'
    | 'isSafeInteger'
    | 'toInteger'
    | 'toExponential'
    | 'toFixed'
    | 'toPrecision'
    | 'abs'
    | 'acos'
    | 'acosh'
    | 'asin'
    | 'asinh'
    | 'atan'
    | 'atanh'
    | 'atan2'
    | 'cbrt'
    | 'ceil'
    | 'clz32'
    | 'cos'
    | 'cosh'
    | 'exp'
    | 'expm1'
    | 'floor'
    | 'fround'
    | 'hypot'
    | 'imul'
    | 'log'
    | 'log1p'
    | 'log10'
    | 'log2'
    | 'max'
    | 'min'
    | 'pow'
    | 'random'
    | 'round'
    | 'sign'
    | 'sin'
    | 'sinh'
    | 'sqrt'
    | 'tan'
    | 'tanh'
    | 'trunc'
    | 'now'
    | 'parse'
    | 'UTC'
    | 'getDate'
    | 'getDay'
    | 'getFullYear'
    | 'getHours'
    | 'getMilliseconds'
    | 'getMinutes'
    | 'getMonth'
    | 'getSeconds'
    | 'getTime'
    | 'getTimezoneOffset'
    | 'getUTCDate'
    | 'getUTCDay'
    | 'getUTCFullYear'
    | 'getUTCHours'
    | 'getUTCMilliseconds'
    | 'getUTCMinutes'
    | 'getUTCMonth'
    | 'getUTCSeconds'
    | 'getYear'
    | 'setDate'
    | 'setFullYear'
    | 'setHours'
    | 'setMilliseconds'
    | 'setMinutes'
    | 'setMonth'
    | 'setSeconds'
    | 'setTime'
    | 'setUTCDate'
    | 'setUTCFullYear'
    | 'setUTCHours'
    | 'setUTCMilliseconds'
    | 'setUTCMinutes'
    | 'setUTCMonth'
    | 'setUTCSeconds'
    | 'setYear'
    | 'toDateString'
    | 'toISOString'
    | 'toJSON'
    | 'toGMTString'
    | 'toLocaleDateString'
    | 'toLocaleFormat'
    | 'toLocaleString'
    | 'toLocaleTimeString'
    | 'toTimeString'
    | 'toUTCString'
    | 'indexOf'
    | 'substring'
    | 'charAt'
    | 'strcmp'
    | 'fromCharCode'
    | 'fromCodePoint'
    | 'raw'
    | 'charCodeAt'
    | 'slice'
    | 'codePointAt'
    | 'concat'
    | 'includes'
    | 'endsWith'
    | 'lastIndexOf'
    | 'localeCompare'
    | 'match'
    | 'normalize'
    | 'padEnd'
    | 'padStart'
    | 'quote'
    | 'repeat'
    | 'replace'
    | 'search'
    | 'split'
    | 'startsWith'
    | 'substr'
    | 'toLocaleLowerCase'
    | 'toLocaleUpperCase'
    | 'toLowerCase'
    | 'toUpperCase'
    | 'trim'
    | 'trimleft'
    | 'trimright'
    | 'anchor'
    | 'big'
    | 'blink'
    | 'bold'
    | 'fixed'
    | 'fontcolor'
    | 'fontsize'
    | 'italics'
    | 'link'
    | 'small'
    | 'strike'
    | 'sub'
    | 'sup'
    | 'compile'
    | 'exec'
    | 'test'
    | 'from'
    | 'isArray'
    | 'of'
    | 'copyWithin'
    | 'fill'
    | 'pop'
    | 'push'
    | 'reverse'
    | 'shift'
    | 'sort'
    | 'splice'
    | 'unshift'
    | 'join'
    | 'every'
    | 'filter'
    | 'findIndex'
    | 'forEach'
    | 'map'
    | 'reduce'
    | 'reduceRight'
    | 'some'
    | 'move'
    | 'getInt8'
    | 'getUint8'
    | 'getInt16'
    | 'getUint16'
    | 'getInt32'
    | 'getUint32'
    | 'getFloat32'
    | 'getFloat64'
    | 'setInt8'
    | 'setUint8'
    | 'setInt16'
    | 'setUint16'
    | 'setInt32'
    | 'setUint32'
    | 'setFloat32'
    | 'setFloat64'
    | 'isView'
    | 'transfer'
    | 'clear'
    | 'get'
    | 'has'
    | 'set'
    | 'add'
    | 'splat'
    | 'check'
    | 'extractLane'
    | 'replaceLane'
    | 'load'
    | 'load1'
    | 'load2'
    | 'load3'
    | 'store'
    | 'store1'
    | 'store2'
    | 'store3'
    | 'addSaturate'
    | 'div'
    | 'mul'
    | 'neg'
    | 'reciprocalApproximation'
    | 'reciprocalSqrtApproximation'
    | 'subSaturate'
    | 'shuffle'
    | 'swizzle'
    | 'maxNum'
    | 'minNum'
    | 'select'
    | 'equal'
    | 'notEqual'
    | 'lessThan'
    | 'lessThanOrEqual'
    | 'greaterThan'
    | 'greaterThanOrEqual'
    | 'and'
    | 'or'
    | 'xor'
    | 'not'
    | 'shiftLeftByScalar'
    | 'shiftRightByScalar'
    | 'allTrue'
    | 'anyTrue'
    | 'fromFloat32x4'
    | 'fromFloat32x4Bits'
    | 'fromFloat64x2Bits'
    | 'fromInt32x4'
    | 'fromInt32x4Bits'
    | 'fromInt16x8Bits'
    | 'fromInt8x16Bits'
    | 'fromUint32x4'
    | 'fromUint32x4Bits'
    | 'fromUint16x8Bits'
    | 'fromUint8x16Bits'
    | 'compareExchange'
    | 'exchange'
    | 'wait'
    | 'wake'
    | 'isLockFree'
    | 'all'
    | 'race'
    | 'reject'
    | 'resolve'
    | 'catch'
    | 'then'
    | 'finally'
    | 'next'
    | 'return'
    | 'throw'
    | 'close'
    | 'send'
    | 'construct'
    | 'deleteProperty'
    | 'ownKeys'
    | 'getCanonicalLocales'
    | 'supportedLocalesOf'
    | 'resolvedOptions'
    | 'formatToParts'
    | 'instantiate'
    | 'instantiateStreaming'
    | 'compileStreaming'
    | 'validate'
    | 'customSections'
    | 'exports'
    | 'imports'
    | 'grow'
    | 'super'
    | 'void'
    | 'in'
    | 'instanceof'
    | 'print'
;

methodparameters:
    expr
    | VAR '=' expr
    | expr ',' methodparameters
    | VAR '=' expr ',' methodparameters
;

methodcall:
    object property methodcall1
    | METHODNAME args methodcall1
    | 'SIMD.' simdtype '.' simdfunction args methodcall1
;

methodcall1:
    (METHODNAME args methodcall1 | simdfunction args methodcall1)?
;

property:
    '.length' property?
    | '.prototype' property?
    | '.constructor' property?
    | '.__proto__' property?
    | '.__noSuchMethod__' property?
    | '.__count__' property?
    | '.__parent__' property?
    | '.arguments' property?
    | '.arity' property?
    | '.caller' property?
    | '.name' property?
    | '.displayName' property?
    | '.iterator' property?
    | '.asyncIterator' property?
    | '.match' property?
    | '.replace' property?
    | '.search' property?
    | '.split' property?
    | '.hasInstance' property?
    | '.isConcatSpreadable' property?
    | '.unscopables' property?
    | '.species' property?
    | '.toPrimitive' property?
    | '.toStringTag' property?
    | '.fileName' property?
    | '.lineNumber' property?
    | '.columnNumber' property?
    | '.message' property?
    | '.name' property?
    | '.EPSILON' property?
    | '.MAX_SAFE_INTEGER' property?
    | '.MAX_VALUE' property?
    | '.MIN_SAFE_INTEGER' property?
    | '.MIN_VALUE' property?
    | '.NaN' property?
    | '.NEGATIVE_INFINITY' property?
    | '.POSITIVE_INFINITY' property?
    | '.E' property?
    | '.LN2' property?
    | '.LN10' property?
    | '.LOG2E' property?
    | '.LOG10E' property?
    | '.PI' property?
    | '.SQRT1_2' property?
    | '.SQRT2' property?
    | '.flags' property?
    | '.global' property?
    | '.ignoreCase' property?
    | '.multiline' property?
    | '.source' property?
    | '.sticky' property?
    | '.unicode' property?
    | '[' DECIMALNUMBER ']' property?
    | '[' string ']' property?
    | '.buffer' property?
    | '.byteLength' property?
    | '.byteOffset' property?
    | '.BYTES_PER_ELEMENT' property?
    | '.compare' property?
    | '.format' property?
    | '.callee' property?
    | '.caller' property?
    | '.memory' property?
    | '.exports' property?
;

args:
    '()'
    | '(' expr (',' expr)* ')'
;

identifierlist:
    IDENTIFIER ', ' identifierlist
    | '(' identifierlist '),' identifierlist
    | IDENTIFIER
;

statement:
    expr ';'
    | VAR ':'
    | declaration
    | 'void ' expr ';'
    | 'return ' expr ';'
    | classdef
    | functiondef
    | 'async ' functiondef
    | 'export ' expr ';'
    | 'export ' functiondef
    | 'export ' declaration
    | 'import ' importname ' as ' METHODNAME ' from ' string
;

declaration:
    declarationtype ' ' VAR ' = ' expr ';'
    | declarationtype ' ' VAR property ' = ' expr ';'
    | declarationtype ' ' VAR '[' DECIMALNUMBER ']' ' = ' expr ';'
    | declarationtype ' ' '{' args '}' ' = ' expr ';'
;

declarationtype:
    'var'
    | 'let'
    | 'const'
;

importname:
    '*'
    | METHODNAME
;

classdef:
    'class ' IDENTIFIER '{\n' classcontent '\n}\n'
    | 'class ' IDENTIFIER 'extends ' IDENTIFIER '{\n' classcontent '\n}\n'
;

classcontent:
    (methoddef '\n' classcontent)?
;

functiondef:
    'function ' IDENTIFIER functionargs '{\n' functionbody '\n}\n'
    | IDENTIFIER ' => ' expr
    | IDENTIFIER ' => ' '{\n' functionbody '\n}'
    | functionargs ' => ' expr
    | functionargs ' => ' '{\n' functionbody '\n}'
;

methoddef:
    IDENTIFIER functionargs '{\n' functionbody '\n}\n'
;

functionbody:
    program
;

functionargs:
    '()'
    | '(' identifierlist ')'
;

expr:
    '(' expr ')'
    | '{' objmember '}'
    | VAR
    | '...' VAR
    | 'delete ' expr
    | 'new ' IDENTIFIER args
    | 'await ' expr
    | literal
    | IDENTIFIER
    | expr '=' expr
    | expr '+=' expr
    | expr '-=' expr
    | expr '*=' expr
    | expr '/=' expr
    | expr '%=' expr
    | expr '**=' expr
    | expr '<<=' expr
    | expr '>>=' expr
    | expr '>>>=' expr
    | expr '&=' expr
    | expr '^=' expr
    | expr '|=' expr
    | methodcall
    | '(' arithmeticoperation ')'
    | '(' comparisonoperation ')'
    | '(' bytewiseoperation ')'
    | '(' logicaloperation ')'
    | '(' expr ' ? ' expr ' : ' expr ')'
    | expr '[' expr ']'
;

arithmeticoperation:
    expr '/' expr
    | expr '*' expr
    | expr '+' expr
    | expr '-' expr
    | expr '%' expr
    | expr '**' expr
    | expr '++'
    | '++' expr
    | '--' expr
    | expr '--'
;

bytewiseoperation:
    expr ' & ' expr
    | expr ' | ' expr
    | expr ' ^ ' expr
    | '~' expr
    | expr ' << ' expr
    | expr ' >> ' expr
    | expr ' >>> ' expr
;

comparisonoperation:
    expr '<' expr
    | expr '>' expr
    | expr '<=' expr
    | expr '>=' expr
    | expr '==' expr
    | expr '===' expr
    | expr '!=' expr
    | expr '<=>' expr
    | expr '===' expr
;

logicaloperation:
    expr ' && ' expr
    | expr ' || ' expr
    | '!' expr
;

NULL: 'null';

literal:
    NULL
    | BOOLEAN
    | NUMBER
    | string
    | array
    | regex
;

BOOLEAN:
    'true'
    | 'false'
;

ZERO: '0';
ONE: '1';
TWO: '2';
THREE: '3';
FOUR: '4';
FIVE: '5';
SIX: '6';
SEVEN: '7';

BINARYDIGITS:
    ZERO
    | ONE
    | '1010'
    | '1_11'
    | '10_01'
    | '1111111111111111111111111111111'
    | '101010101110101001011010101'
;

OCTALDIGITS:
    ZERO
    | ONE
    | '123'
    | '5_0_2'
    | '324'
    | '5__432'
    | '7777777777777777777777'
    | '1247237465234'
;

OCTALDIGIT:
    ZERO
    | ONE
    | TWO
    | THREE
    | FOUR
    | FIVE
    | SIX
    | SEVEN
;

DECIMALDIGITS:
    ZERO
    | ONE
    | '20'
    | ONETWOTHREEFOUR
    | '66'
    | '234_9'
    | '99999999999999999999'
    | '12345678123456'
;

HEXDIGITS:
    ZERO
    | 'ABCFDFE0_1203453abcd'
    | ONE
    | ONETWOTHREEFOUR
    | '1asdf'
    | 'A1'
    | '1F_F'
    | '4346'
    | 'FE_D983'
    | 'FFFFFFFFFF'
;

ONETWOTHREEFOUR:
    '1234'
;

HEXDIGIT:
    ZERO
    | ONE
    | TWO
    | THREE
    | FOUR
    | FIVE
    | SIX
    | SEVEN
    | '8'
    | '9'
    | 'A'
    | 'B'
    | 'C'
    | 'D'
    | 'E'
    | 'F'
;

BINNUMBER:
    '0b' BINARYDIGITS
    | '0B' BINARYDIGITS
;

EXPONENT:
    'e' DECIMALDIGITS
    | 'e-' DECIMALDIGITS
    | 'E' DECIMALDIGITS
    | 'E-' DECIMALDIGITS
;

DECIMALNUMBER:
    DECIMALDIGITS
    | '0D' DECIMALDIGITS
    | '0d' DECIMALDIGITS
;

HEXNUMBER:
    '0x' HEXDIGITS
    | '0X' HEXDIGITS
;

OCTALNUMBER:
    '0O' OCTALDIGITS
    | '0o' OCTALDIGITS
    | '0' OCTALDIGITS
;

FLOATNUMBER:
    DECIMALNUMBER '.' DECIMALDIGITS
    | OCTALNUMBER '.' OCTALDIGITS
    | HEXNUMBER '.' HEXDIGITS
    | DECIMALNUMBER '.' DECIMALDIGITS EXPONENT
    | OCTALNUMBER '.' OCTALDIGITS EXPONENT
    | HEXNUMBER '.' HEXDIGITS EXPONENT
;

NUMBER:
    OCTALNUMBER
    | FLOATNUMBER
    | HEXNUMBER
    | DECIMALNUMBER
    | BINNUMBER
    | ZERO
    | ONE
    | '1.00'
    | '1/2'
    | '1E2'
    | '1E02'
    | '1E+02'
    | '-1'
    | '-1.00'
    | '-1/2'
    | '-1E2'
    | '-1E02'
    | '-1E+02'
    | '1/0'
    | '0/0'
    | '-2147483648/-1'
    | '-9223372036854775808/-1'
    | '-0'
    | '-0.0'
    | '+0'
    | '+0.0'
    | '0.00'
    | '.'
    | '0,00'
    | '0.0/0'
    | '1.0/0.0'
    | '0.0/0.0'
    | '1,0/0,0'
    | '0,0/0,0'
    | '--1'
    | '999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999'
    | '0x0'
    | '0xffffffff'
    | '0xffffffffffffffff'
    | '0xabad1dea'
    | '123456789012345678901234567890123456789'
    | '1000.00'
    | '1000000.00'
    | '100000.000'
    | '100000000'
    | '01000'
    | '08'
    | '09'
    | '2.2250738585072011e-308'
;


doublequotedstring:
    NAUGHTYSTRING
    | ' ' doublequotedstring
    | NUMBER doublequotedstring
    | ESCAPEDCHARACTERS doublequotedstring
    | '#{' expr '}' doublequotedstring
;

templatestring:
    (doublequotedstring '${' expr '}' templatestring)?
;

string:
    '"' doublequotedstring '"'
    | '\'' doublequotedstring '\''
    | '`' templatestring '`'
;

array:
    '[' arraycontent ']'
    | '[]'
;

arraycontent:
    expr (', ' arraycontent)?
;

regex:
    '/' regexpattern '/'
    | '/' regexpattern '/g'
    | '/' regexpattern '/i'
    | '/' regexpattern '/m'
    | '/' regexpattern '/y'
;

regexpattern:
    doublequotedstring
;

ESCAPEDCHARACTERS:
    '\\\\'
    | '\\\''
    | '\\"'
    | '\\0'
    | '\\a'
    | '\\b'
    | '\\f'
    | '\\n'
    | '\\r'
    | '\\#'
    | '\\t'
    | '\\u' HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT
    | '\\v'
    | '\\0' OCTALDIGIT OCTALDIGIT
    | '\\x' HEXDIGIT HEXDIGIT
;

HASOWNPROPERTY: 'hasOwnProperty';

NAUGHTYSTRING:
    UNDEFINED
    | 'undef'
    | 'en-US'
    | 'year'
    | NULL
    | 'NULL'
    | '(null)'
    | 'nil'
    | 'NIL'
    | BOOLEAN
    | 'True'
    | 'False'
    | 'TRUE'
    | 'FALSE'
    | 'None'
    | HASOWNPROPERTY
    | ',./;\'[]\\-='
    | '<>?:"{}|_+'
    | '!@#$%^&*()`~'
    | ' '
    | '%'
    | '_'
    | '-'
    | '--'
    | '--version'
    | '--help'
    | '$USER'
    | '`ls -al /`'
    | '<<< %s(un=\'%s\') = %u'
    | '+++ATH0'
    | 'CON'
    | 'PRN'
    | 'AUX'
    | 'CLOCK$'
    | 'NUL'
    | 'A:'
    | 'ZZ:'
    | 'COM1'
    | 'LPT1'
    | 'COM2'
    | 'DCC SEND STARTKEYLOGGER 0 0 0'
    | 'https://www.google.com/'
;

IDENTIFIER:
    'Object'
    | VAR
    | 'Function'
    | 'main'
    | 'opt'
    | 'Boolean'
    | 'Symbol'
    | 'JSON'
    | 'Error'
    | 'EvalError'
    | 'RangeError'
    | 'ReferenceError'
    | 'SyntaxError'
    | 'TypeError'
    | 'URIError'
    | 'this'
    | 'Number'
    | 'Math'
    | 'Date'
    | 'String'
    | 'RegExp'
    | 'Array'
    | 'Int8Array'
    | 'Uint8Array'
    | 'Uint8ClampedArray'
    | 'Int16Array'
    | 'Uint16Array'
    | 'Int32Array'
    | 'Uint32Array'
    | 'Float32Array'
    | 'Float64Array'
    | 'DataView'
    | 'ArrayBuffer'
    | 'Map'
    | 'Set'
    | 'WeakMap'
    | 'WeakSet'
    | 'Promise'
    | 'AsyncFunction'
    | 'asyncGenerator'
    | 'Reflect'
    | 'Proxy'
    | 'Intl'
    | 'Intl.Collator'
    | 'Intl.DateTimeFormat'
    | 'Intl.NumberFormat'
    | 'Intl.PluralRules'
    | 'WebAssembly'
    | 'WebAssembly.Module'
    | 'WebAssembly.Instance'
    | 'WebAssembly.Memory'
    | 'WebAssembly.Table'
    | 'WebAssembly.CompileError'
    | 'WebAssembly.LinkError'
    | 'WebAssembly.RuntimeError'
    | 'arguments'
    | 'Infinity'
    | 'NaN'
    | UNDEFINED
    | NULL
    | 'console'
;

UNDEFINED: 'undefined';

simdtype:
    simdtypebool
    | simdtypeint
    | simdtypeuint
    | simdtypefloat
;

simdtypebool:
    'Bool8x16'
    | 'Bool16x8'
    | 'Bool32x4'
    | 'Bool64x2'
;

simdtypeint:
    'Int8x16'
    | 'Int16x8'
    | 'Int32x4'
;

simdtypeuint:
    'Uint8x16'
    | 'Uint16x8'
    | 'Uint32x4'
;

simdtypefloat:
    'Float32x4'
    | 'Float64x2'
;

simdfunction:
    'splat'
    | 'check'
    | 'extractLane'
    | 'replaceLane'
    | 'load'
    | 'load1'
    | 'load2'
    | 'load3'
    | 'store'
    | 'store1'
    | 'store2'
    | 'store3'
    | 'abs'
    | 'add'
    | 'addSaturate'
    | 'div'
    | 'mul'
    | 'sub'
    | 'subSaturate'
    | 'sqrt'
    | 'select'
    | 'neg'
    | 'reciprocalApproximation'
    | 'reciprocalSqrtApproximation'
    | 'shuffle'
    | 'swizzle'
    | 'max'
    | 'maxNum'
    | 'min'
    | 'minNum'
    | 'equal'
    | 'notEqual'
    | 'lessThan'
    | 'lessThanOrEqual'
    | 'greaterThan'
    | 'greaterThanOrEqual'
    | 'and'
    | 'or'
    | 'xor'
    | 'not'
    | 'shiftLeftByScalar'
    | 'shiftRightByScalar'
    | 'allTrue'
    | 'anyTrue'
    | 'fromFloat32x4'
    | 'fromFloat32x4Bits'
    | 'fromFloat64x2Bits'
    | 'fromInt32x4'
    | 'fromInt32x4Bits'
    | 'fromInt16x8Bits'
    | 'fromInt8x16Bits'
    | 'fromUint32x4'
    | 'fromUint32x4Bits'
    | 'fromUint16x8Bits'
    | 'fromUint8x16Bits'
;

