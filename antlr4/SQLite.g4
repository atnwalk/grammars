/*
 * The MIT License (MIT)
 * 
 * SQLite grammar extended with built-in functions and additional syntax rules for fuzzing with ATNwalk by Maik Betka.
 *
 * Copyright (c) 2023 by Maik Betka
 * Copyright (c) 2014 by Bart Kiers
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

grammar SQLite;

start: sql_stmt_list
;

sql_stmt_list:
    sql_stmt (SCOL_T NEWLINE_T sql_stmt)* SCOL_T NEWLINE_T
;

sql_stmt: (EXPLAIN_T (QUERY_T PLAN_T)?)? (
        alter_table_stmt
        | analyze_stmt
        | attach_stmt
        | begin_stmt
        | commit_stmt
        | create_index_stmt
        | create_table_stmt
        | create_trigger_stmt
        | create_view_stmt
        | delete_stmt
        | delete_stmt_limited
        | detach_stmt
        | drop_index_stmt
        | drop_table_stmt
        | drop_trigger_stmt
        | drop_view_stmt
        | insert_stmt
        | pragma_stmt
        | reindex_stmt
        | release_stmt
        | rollback_stmt
        | savepoint_stmt
        | select_stmt
        | update_stmt
        | update_stmt_limited
        | vacuum_stmt
    )
;

alter_table_stmt:
    ALTER_T TABLE_T (schema_name DOT_T)? table_name (
        RENAME_T TO_T new_table_name
        | RENAME_T COLUMN_T? column_name TO_T column_name
        | ADD_T COLUMN_T? column_def
        | DROP_T COLUMN_T? column_name
    )
;

analyze_stmt:
    ANALYZE_T (
        schema_name
        | index_or_table_name
        | schema_name DOT_T index_or_table_name
    )
;

attach_stmt:
    ATTACH_T DATABASE_T? expr AS_T schema_name
;

begin_stmt:
    BEGIN_T (DEFERRED_T | IMMEDIATE_T | EXCLUSIVE_T)? TRANSACTION_T?
;

commit_stmt: (COMMIT_T | END_T) TRANSACTION_T?
;

rollback_stmt:
    ROLLBACK_T TRANSACTION_T? (TO_T SAVEPOINT_T? savepoint_name)?
;

savepoint_stmt:
    SAVEPOINT_T savepoint_name
;

release_stmt:
    RELEASE_T SAVEPOINT_T? savepoint_name
;

create_index_stmt:
    CREATE_T UNIQUE_T? INDEX_T (IF_T NOT_T EXISTS_T)? (schema_name DOT_T)? index_name
    ON_T table_name OPEN_PAR_T indexed_column (COMMA_T indexed_column)* CLOSE_PAR_T (WHERE_T expr)?
;

indexed_column: (column_name | expr) (COLLATE_T collation_name)? (ASC_T | DESC_T)?
;

create_table_stmt:
    CREATE_T (TEMP_T | TEMPORARY_T)? TABLE_T (IF_T NOT_T EXISTS_T)?
    (schema_name DOT_T)? table_name (
        AS_T select_stmt
        | OPEN_PAR_T column_def (COMMA_T column_def)* (table_constraint (COMMA_T table_constraint)*)? CLOSE_PAR_T table_options?
    )
;

table_options:
    (WITHOUT_T ROWID_T | STRICT_T) (COMMA_T (WITHOUT_T ROWID_T | STRICT_T))*
;

column_def:
    column_name type_name? column_constraint*
;

type_name:
    (TYPE_BASE_NAME_T | NULL_T) (
        OPEN_PAR_T signed_number CLOSE_PAR_T
        | OPEN_PAR_T signed_number COMMA_T signed_number CLOSE_PAR_T
    )?
;

column_constraint: (CONSTRAINT_T CONSTRAINT_NAME_T)? (
        (PRIMARY_T KEY_T (ASC_T | DESC_T)? conflict_clause AUTOINCREMENT_T?)
        | NOT_T NULL_T  conflict_clause
        | UNIQUE_T conflict_clause
        | CHECK_T OPEN_PAR_T expr CLOSE_PAR_T
        | DEFAULT_T (OPEN_PAR_T expr CLOSE_PAR_T | literal_value | signed_number)
        | COLLATE_T collation_name
        | foreign_key_clause
        | (GENERATED_T ALWAYS_T)? AS_T OPEN_PAR_T expr CLOSE_PAR_T (STORED_T | VIRTUAL_T)?
    )
;

signed_number: (PLUS_T | MINUS_T)? NUMERIC_LITERAL_T
;

table_constraint: (CONSTRAINT_T CONSTRAINT_NAME_T)? (
        (PRIMARY_T KEY_T | UNIQUE_T) OPEN_PAR_T indexed_column (COMMA_T indexed_column)* CLOSE_PAR_T conflict_clause
        | CHECK_T OPEN_PAR_T expr CLOSE_PAR_T
        | FOREIGN_T KEY_T OPEN_PAR_T column_name (COMMA_T column_name)* CLOSE_PAR_T foreign_key_clause
    )
;

foreign_key_clause:
    REFERENCES_T foreign_table (
        OPEN_PAR_T column_name (COMMA_T column_name)* CLOSE_PAR_T
    )? (
        ON_T (DELETE_T | UPDATE_T) (
            SET_T (NULL_T | DEFAULT_T)
            | CASCADE_T
            | RESTRICT_T
            | NO_T ACTION_T
        )
    )* (NOT_T? DEFERRABLE_T (INITIALLY_T (DEFERRED_T | IMMEDIATE_T))?)?
;

conflict_clause:
    (ON_T CONFLICT_T (
        ROLLBACK_T
        | ABORT_T
        | FAIL_T
        | IGNORE_T
        | REPLACE_T
    ))?
;

create_trigger_stmt:
    CREATE_T (TEMP_T | TEMPORARY_T)? TRIGGER_T (IF_T NOT_T EXISTS_T)?
    (schema_name DOT_T)? trigger_name
    (BEFORE_T | AFTER_T | INSTEAD_T OF_T)? (
        DELETE_T
        | INSERT_T
        | (UPDATE_T (OF_T column_name (COMMA_T column_name)*)?)
    ) ON_T table_name
    (FOR_T EACH_T ROW_T)? (WHEN_T expr)?
    BEGIN_T ((update_stmt | insert_stmt | delete_stmt | select_stmt) SCOL_T)+ END_T
;

create_view_stmt:
    CREATE_T (TEMP_T | TEMPORARY_T)? VIEW_T (IF_T NOT_T EXISTS_T)?
    (schema_name DOT_T)? view_name
    (OPEN_PAR_T column_name (COMMA_T column_name)* CLOSE_PAR_T)?
    AS_T select_stmt
;




common_table_expression:
    table_name (OPEN_PAR_T column_name (COMMA_T column_name)* CLOSE_PAR_T)?
    AS_T (NOT_T? MATERIALIZED_T)? OPEN_PAR_T select_stmt CLOSE_PAR_T
;

delete_stmt:
    (WITH_T RECURSIVE_T? common_table_expression (COMMA_T common_table_expression)*)?
    DELETE_T FROM_T qualified_table_name (WHERE_T expr)? returning_clause?
;

delete_stmt_limited:
    (WITH_T RECURSIVE_T? common_table_expression (COMMA_T common_table_expression)*)?
    DELETE_T FROM_T qualified_table_name
    (WHERE_T expr)?
    returning_clause?
    (ORDER_T BY_T ordering_term (COMMA_T ordering_term)* LIMIT_T expr (OFFSET_T expr | COMMA_T expr)?)?
;

detach_stmt:
    DETACH_T DATABASE_T? schema_name
;

drop_index_stmt:
    DROP_T INDEX_T (IF_T EXISTS_T)? (schema_name DOT_T)? index_name
;

drop_table_stmt:
    DROP_T TABLE_T (IF_T EXISTS_T)? (schema_name DOT_T)? table_name
;

drop_trigger_stmt:
    DROP_T TRIGGER_T (IF_T EXISTS_T)? (schema_name DOT_T)? trigger_name
;

drop_view_stmt:
    DROP_T VIEW_T (IF_T EXISTS_T)? (schema_name DOT_T)? view_name
;

expr:
    literal_value
    | ((schema_name DOT_T)? table_name DOT_T)? column_name
    | unary_operator expr
    | expr (PIPE2_ | R_ARR1_ | R_ARR2_) expr
    | expr ( STAR_T | DIV_T | MOD_T) expr
    | expr ( PLUS_T | MINUS_T) expr
    | expr ( LT2_ | GT2_ | AMP_T | PIPE_T) expr
    | expr ( LT_T | LT_EQ_T | GT_T | GT_EQ_T) expr
    | expr (
        ASSIGN_T
        | EQ_T
        | NOT_EQ1_
        | NOT_EQ2_
        | IS_T
        | IS_T NOT_T
        | IN_T
        | LIKE_T
        | GLOB_T
        | MATCH_T
        | REGEXP_T
    ) expr
    | expr AND_T expr
    | expr OR_T expr
    | function
    | OPEN_PAR_T expr (COMMA_T expr)* CLOSE_PAR_T
    | CAST_T OPEN_PAR_T expr AS_T type_name CLOSE_PAR_T
    | expr COLLATE_T collation_name
    | expr NOT_T? (LIKE_T | GLOB_T | REGEXP_T | MATCH_T) expr (
        ESCAPE_T expr
    )?
    | expr ( ISNULL_T | NOTNULL_T | NOT_T NULL_T)
    | expr IS_T NOT_T? expr
    | expr NOT_T? BETWEEN_T expr AND_T expr
    | expr NOT_T? IN_T (
        OPEN_PAR_T (select_stmt | expr ( COMMA_T expr)*)? CLOSE_PAR_T
        | ( schema_name DOT_T)? table_name
    )
    | ((NOT_T)? EXISTS_T)? OPEN_PAR_T select_stmt CLOSE_PAR_T
    | CASE_T expr? (WHEN_T expr THEN_T expr)+ (ELSE_T expr)? END_T
    | raise_function
;

raise_function:
    RAISE_T OPEN_PAR_T (
        IGNORE_T
        | (ROLLBACK_T | ABORT_T | FAIL_T) COMMA_T error_message
    ) CLOSE_PAR_T
;

literal_value:
    NUMERIC_LITERAL_T
    | STRING_LITERAL_T
    | BLOB_LITERAL_T
    | NULL_T
    | TRUE_T
    | FALSE_T
    | CURRENT_TIME_T
    | CURRENT_DATE_T
    | CURRENT_TIMESTAMP__T
;

insert_stmt:
    (WITH_T (RECURSIVE_T)? common_table_expression (COMMA_T common_table_expression)*)?
    (
        INSERT_T
        | REPLACE_T
        | (INSERT_T OR_T (
                ABORT_T
                | FAIL_T
                | IGNORE_T
                | REPLACE_T
                | ROLLBACK_T
            )
        )
    ) INTO_T (schema_name DOT_T)? table_name (AS_T table_alias)?
    (OPEN_PAR_T column_name (COMMA_T column_name)* CLOSE_PAR_T)?
    (
        (VALUES_T (OPEN_PAR_T expr (COMMA_T expr)* CLOSE_PAR_T) (COMMA_T OPEN_PAR_T expr (COMMA_T expr)* CLOSE_PAR_T)* upsert_clause?)
        | select_stmt upsert_clause?
        | DEFAULT_T VALUES_T
    ) returning_clause?
;

upsert_clause:
    ON_T CONFLICT_T (OPEN_PAR_T indexed_column (COMMA_T indexed_column)* CLOSE_PAR_T (WHERE_T expr)?)?
    DO_T (
        NOTHING_T
        | UPDATE_T SET_T (
            (column_name | column_name_list) ASSIGN_T expr (COMMA_T (column_name | column_name_list) ASSIGN_T expr)*
            (WHERE_T expr)?
        )
    )
;

pragma_stmt:
    PRAGMA_T (schema_name DOT_T)? pragma_name
    (ASSIGN_T pragma_value | OPEN_PAR_T pragma_value CLOSE_PAR_T)?
;

pragma_value:
    signed_number
    | PRAGMA_SPECIAL_VALUE_T
    | DELETE_T
    | EXCLUSIVE_T
    | FULL_T
;

reindex_stmt:
    REINDEX_T (collation_name | ((schema_name DOT_T)? (table_name | index_name)))?
;

select_stmt:
    (
        (WITH_T RECURSIVE_T? common_table_expression (COMMA_T common_table_expression)*)?
        select_core
        (compound_operator select_core)*
        (ORDER_T BY_T ordering_term (COMMA_T ordering_term)*)?
        (LIMIT_T expr ((OFFSET_T | COMMA_T) expr)?)?
    ) | (
    //  'ORDER BY' and 'LIMIT BY' are not permitted with a values_stmt
        (WITH_T RECURSIVE_T? common_table_expression (COMMA_T common_table_expression)*)?
        values_stmt
        (compound_operator values_stmt)*
    )
;

select_core:
    SELECT_T (DISTINCT_T | ALL_T)? result_column (COMMA_T result_column)*
    (FROM_T ((table_or_subquery (COMMA_T table_or_subquery)) | join_clause))?
    (WHERE_T expr)?
    (GROUP_T BY_T expr (COMMA_T expr)* (HAVING_T expr)?)?
    (WINDOW_T window_name AS_T window_defn (COMMA_T window_name AS_T window_defn)*)?
;

values_stmt:
    VALUES_T OPEN_PAR_T expr (COMMA_T expr)* CLOSE_PAR_T (COMMA_T OPEN_PAR_T expr (COMMA_T expr)* CLOSE_PAR_T)*
;

join_clause:
    table_or_subquery (join_operator table_or_subquery join_constraint)*
;

table_or_subquery: (
        (schema_name DOT_T)? table_name (AS_T? table_alias)?
        ((INDEXED_T BY_T index_name) | (NOT_T INDEXED_T))?
    )
    // | (schema_name DOT_T)? table_function_name OPEN_PAR_T expr (COMMA_T expr)* CLOSE_PAR_T (
    //     AS_T? table_alias
    // )?
    | OPEN_PAR_T select_stmt CLOSE_PAR_T (AS_T? table_alias)?
    | OPEN_PAR_T ((table_or_subquery (COMMA_T table_or_subquery)*) | join_clause) CLOSE_PAR_T
;

result_column:
    STAR_T
    | table_name DOT_T STAR_T
    | expr ( AS_T? column_alias)?
;

join_operator:
    COMMA_T
    | NATURAL_T? (LEFT_T OUTER_T? | INNER_T | CROSS_T)? JOIN_T
;

join_constraint:
    (ON_T expr
    | USING_T OPEN_PAR_T column_name (COMMA_T column_name)* CLOSE_PAR_T)?
;

compound_operator:
    (UNION_T ALL_T?)
    | INTERSECT_T
    | EXCEPT_T
;

update_stmt:
    (WITH_T RECURSIVE_T? common_table_expression (COMMA_T common_table_expression)*)?
    UPDATE_T (OR_T (ABORT_T | FAIL_T | IGNORE_T | REPLACE_T | ROLLBACK_T))? qualified_table_name
    SET_T (column_name | column_name_list) ASSIGN_T expr
    (COMMA_T (column_name | column_name_list) ASSIGN_T expr)*
    (FROM_T ((table_or_subquery (COMMA_T table_or_subquery)*) | join_clause))?
    (WHERE_T expr)?
    returning_clause?
;

column_name_list:
    OPEN_PAR_T column_name (COMMA_T column_name)* CLOSE_PAR_T
;

update_stmt_limited:
    (WITH_T RECURSIVE_T? common_table_expression (COMMA_T common_table_expression)*)?
    UPDATE_T (OR_T (ABORT_T | FAIL_T | IGNORE_T | REPLACE_T | ROLLBACK_T))? qualified_table_name
    SET_T (column_name | column_name_list) ASSIGN_T expr
    (COMMA_T (column_name | column_name_list) ASSIGN_T expr)*
    (FROM_T ((table_or_subquery (COMMA_T table_or_subquery)*) | join_clause))?
    (WHERE_T expr)?
    returning_clause?
    (ORDER_T BY_T ordering_term (COMMA_T ordering_term)*)?
    (LIMIT_T expr ((OFFSET_T | COMMA_T) expr)?)?
;

qualified_table_name: (schema_name DOT_T)? table_name (AS_T alias)?
    (INDEXED_T BY_T index_name | NOT_T INDEXED_T)?
;

vacuum_stmt:
    // fuzzing in-memory, no filename
    VACUUM_T schema_name? // (INTO_T filename)?
;

filter_clause:
    FILTER_T OPEN_PAR_T WHERE_T expr CLOSE_PAR_T
;

window_defn:
    OPEN_PAR_T base_window_name?
    (PARTITION_T BY_T expr (COMMA_T expr)*)?
    (ORDER_T BY_T ordering_term (COMMA_T ordering_term)*)?
    frame_spec? CLOSE_PAR_T
;


frame_spec:
    (RANGE_T | ROWS_T | GROUPS_T) (
        (BETWEEN_T (UNBOUNDED_T PRECEDING_T | expr PRECEDING_T | CURRENT_T ROW_T | expr FOLLOWING_T)
            AND_T (expr PRECEDING_T | CURRENT_T ROW_T | expr FOLLOWING_T | UNBOUNDED_T FOLLOWING_T))
        | UNBOUNDED_T PRECEDING_T
        | expr PRECEDING_T
        | CURRENT_T ROW_T
    ) (EXCLUDE_T (NO_T OTHERS_T | CURRENT_T ROW_T | GROUP_T | TIES_T))?
;


ordering_term:
    expr (COLLATE_T collation_name)? (ASC_T | DESC_T)? (NULLS_T (FIRST_T | LAST_T))?
;

returning_clause:
    RETURNING_T ((expr (AS_T? column_alias)?) | STAR_T)
    (COMMA_T ((expr (AS_T? column_alias)?) | STAR_T))*
;

unary_operator:
    MINUS_T
    | PLUS_T
    | TILDE_T
    | NOT_T
;

error_message:
    ERROR_MESSAGE_T
;

column_alias:
    column_name
;

schema_name:
    SCHEMA_NAME_T
;

table_name:
    TABLE_NAME_T
;

index_or_table_name:
    TABLE_NAME_T | INDEX_NAME_T
;

new_table_name:
    TABLE_NAME_T
;

column_name:
    COLUMN_NAME_T
;

collation_name:
    COLLATION_NAME_T
;

foreign_table:
    TABLE_NAME_T
;

index_name:
    INDEX_NAME_T
;

trigger_name:
    TRIGGER_NAME_T
;

view_name:
    VIEW_NAME_T
;

pragma_name:
    PRAGMA_NAME_T
;

savepoint_name:
    SAVEPOINT_NAME_T
;

table_alias:
    TABLE_NAME_T
;

window_name:
    WINDOW_NAME_T
;

alias:
    TABLE_NAME_T
;

// not entirely sure but seems to be the same as window_name
base_window_name:
    WINDOW_NAME_T
;

function:
    simple_func | aggregate_func | window_func
;

simple_func:
    (SIMPLE_FUNC_NAME_T | MAX_T | MIN_T) OPEN_PAR_T ((expr (COMMA_T expr)*) | STAR_T)? CLOSE_PAR_T
;

aggregate_func:
    (AGGREGATE_FUNC_NAME_T | MAX_T | MIN_T) OPEN_PAR_T ((DISTINCT_T? (expr (COMMA_T expr)*)) | STAR_T)? CLOSE_PAR_T filter_clause?
;

window_func:
    WINDOW_FUNC_NAME_T OPEN_PAR_T ((expr (COMMA_T expr)*) | STAR_T)? CLOSE_PAR_T filter_clause? OVER_T (window_defn | window_name)
;


SCOL_T:      ';';
DOT_T:       '.';
OPEN_PAR_T:  '(';
CLOSE_PAR_T: ')';
COMMA_T:     ', ';
ASSIGN_T:    '=';
STAR_T:      '*';
PLUS_T:      '+';
MINUS_T:     '-';
TILDE_T:     '~';
PIPE2_:     '||';
DIV_T:       '/';
MOD_T:       '%';
LT2_:       '<<';
GT2_:       '>>';
AMP_T:       '&';
PIPE_T:      '|';
LT_T:        '<';
LT_EQ_T:     '<=';
GT_T:        '>';
GT_EQ_T:     '>=';
EQ_T:        '==';
NOT_EQ1_:   '!=';
NOT_EQ2_:   '<>';
R_ARR1_:    '->';
R_ARR2_:    '->>';

ABORT_T:             ' ABORT ';
ACTION_T:            ' ACTION ';
ADD_T:               ' ADD ';
AFTER_T:             ' AFTER ';
ALL_T:               ' ALL ';
ALTER_T:             ' ALTER ';
ANALYZE_T:           ' ANALYZE ';
AND_T:               ' AND ';
AS_T:                ' AS ';
ASC_T:               ' ASC ';
ATTACH_T:            ' ATTACH ';
AUTOINCREMENT_T:     ' AUTOINCREMENT ';
BEFORE_T:            ' BEFORE ';
BEGIN_T:             ' BEGIN ';
BETWEEN_T:           ' BETWEEN ';
BY_T:                ' BY ';
CASCADE_T:           ' CASCADE ';
CASE_T:              ' CASE ';
CAST_T:              ' CAST ';
CHECK_T:             ' CHECK ';
COLLATE_T:           ' COLLATE ';
COLUMN_T:            ' COLUMN ';
COMMIT_T:            ' COMMIT ';
CONFLICT_T:          ' CONFLICT ';
CONSTRAINT_T:        ' CONSTRAINT ';
CREATE_T:            ' CREATE ';
CROSS_T:             ' CROSS ';
CURRENT_DATE_T:      ' CURRENT_DATE ';
CURRENT_TIME_T:      ' CURRENT_TIME ';
CURRENT_TIMESTAMP__T: ' CURRENT_TIMESTAMP_T ';
DATABASE_T:          ' DATABASE ';
DEFAULT_T:           ' DEFAULT ';
DEFERRABLE_T:        ' DEFERRABLE ';
DEFERRED_T:          ' DEFERRED ';
DELETE_T:            ' DELETE ';
DESC_T:              ' DESC ';
DETACH_T:            ' DETACH ';
DISTINCT_T:          ' DISTINCT ';
DROP_T:              ' DROP ';
EACH_T:              ' EACH ';
ELSE_T:              ' ELSE ';
END_T:               ' END ';
ESCAPE_T:            ' ESCAPE ';
EXCEPT_T:            ' EXCEPT ';
EXCLUSIVE_T:         ' EXCLUSIVE ';
EXISTS_T:            ' EXISTS ';
EXPLAIN_T:           ' EXPLAIN ';
FAIL_T:              ' FAIL ';
FOR_T:               ' FOR ';
FOREIGN_T:           ' FOREIGN ';
FROM_T:              ' FROM ';
FULL_T:              ' FULL ';
GLOB_T:              ' GLOB ';
GROUP_T:             ' GROUP ';
HAVING_T:            ' HAVING ';
IF_T:                ' IF ';
IGNORE_T:            ' IGNORE ';
IMMEDIATE_T:         ' IMMEDIATE ';
IN_T:                ' IN ';
INDEX_T:             ' INDEX ';
INDEXED_T:           ' INDEXED ';
INITIALLY_T:         ' INITIALLY ';
INNER_T:             ' INNER ';
INSERT_T:            ' INSERT ';
INSTEAD_T:           ' INSTEAD ';
INTERSECT_T:         ' INTERSECT ';
INTO_T:              ' INTO ';
IS_T:                ' IS ';
ISNULL_T:            ' ISNULL ';
JOIN_T:              ' JOIN ';
KEY_T:               ' KEY ';
LEFT_T:              ' LEFT ';
LIKE_T:              ' LIKE ';
LIMIT_T:             ' LIMIT ';
MATCH_T:             ' MATCH ';
MATERIALIZED_T:      ' MATERIALIZED ';
NATURAL_T:           ' NATURAL ';
NO_T:                ' NO ';
NOT_T:               ' NOT ';
NOTNULL_T:           ' NOTNULL ';
NULL_T:              ' NULL ';
OF_T:                ' OF ';
OFFSET_T:            ' OFFSET ';
ON_T:                ' ON ';
OR_T:                ' OR ';
ORDER_T:             ' ORDER ';
OUTER_T:             ' OUTER ';
PLAN_T:              ' PLAN ';
PRAGMA_T:            ' PRAGMA ';
PRIMARY_T:           ' PRIMARY ';
QUERY_T:             ' QUERY ';
RAISE_T:             ' RAISE ';
RECURSIVE_T:         ' RECURSIVE ';
REFERENCES_T:        ' REFERENCES ';
REGEXP_T:            ' REGEXP ';
REINDEX_T:           ' REINDEX ';
RELEASE_T:           ' RELEASE ';
RENAME_T:            ' RENAME ';
REPLACE_T:           ' REPLACE ';
RESTRICT_T:          ' RESTRICT ';
ROLLBACK_T:          ' ROLLBACK ';
ROW_T:               ' ROW ';
ROWID_T:             ' ROWID ';
ROWS_T:              ' ROWS ';
SAVEPOINT_T:         ' SAVEPOINT ';
SELECT_T:            ' SELECT ';
SET_T:               ' SET ';
STRICT_T:            ' STRICT ';
TABLE_T:             ' TABLE ';
TEMP_T:              ' TEMP ';
TEMPORARY_T:         ' TEMPORARY ';
THEN_T:              ' THEN ';
TO_T:                ' TO ';
TRANSACTION_T:       ' TRANSACTION ';
TRIGGER_T:           ' TRIGGER ';
UNION_T:             ' UNION ';
UNIQUE_T:            ' UNIQUE ';
UPDATE_T:            ' UPDATE ';
USING_T:             ' USING ';
VACUUM_T:            ' VACUUM ';
VALUES_T:            ' VALUES ';
VIEW_T:              ' VIEW ';
VIRTUAL_T:           ' VIRTUAL ';
WHEN_T:              ' WHEN ';
WHERE_T:             ' WHERE ';
WITH_T:              ' WITH ';
WITHOUT_T:           ' WITHOUT ';
OVER_T:              ' OVER ';
PARTITION_T:         ' PARTITION ';
RANGE_T:             ' RANGE ';
RETURNING_T:         ' RETURNING ';
PRECEDING_T:         ' PRECEDING ';
UNBOUNDED_T:         ' UNBOUNDED ';
CURRENT_T:           ' CURRENT ';
FOLLOWING_T:         ' FOLLOWING ';
GENERATED_T:         ' GENERATED ';
ALWAYS_T:            ' ALWAYS ';
STORED_T:            ' STORED ';
TRUE_T:              ' TRUE ';
FALSE_T:             ' FALSE ';
WINDOW_T:            ' WINDOW ';
NULLS_T:             ' NULLS ';
FIRST_T:             ' FIRST ';
LAST_T:              ' LAST ';
FILTER_T:            ' FILTER ';
GROUPS_T:            ' GROUPS ';
EXCLUDE_T:           ' EXCLUDE ';
TIES_T:              ' TIES ';
OTHERS_T:            ' OTHERS ';
DO_T:                ' DO ';
NOTHING_T:           ' NOTHING ';

COLLATION_NAME_T:
    'BINARY' | 'NOCASE' | 'RTRIM'
;

MIN_T:
    'min'
;

MAX_T:
    'max'
;

SIMPLE_FUNC_NAME_T:
    'abs'
    | 'changes'
    | 'char'
    | 'coalesce'
    | 'format'
    | 'glob'
    | 'hex'
    | 'ifnull'
    | 'iif'
    | 'instr'
    | 'last_insert_rowid'
    | 'length'
    | 'like'
    | 'likelihood'
    | 'likely'
    | 'load_extension'
    | 'lower'
    | 'ltrim'
    | 'nullif'
    | 'printf'
    | 'quote'
    | 'random'
    | 'randomblob'
    | 'replace'
    | 'round'
    | 'rtrim'
    | 'sign'
    | 'soundex'
    | 'sqlite_compileoption_get'
    | 'sqlite_compileoption_used'
    | 'sqlite_offset'
    | 'sqlite_source_id'
    | 'sqlite_version'
    | 'substr'
    | 'substring'
    | 'total_changes'
    | 'trim'
    | 'typeof'
    | 'unicode'
    | 'unlikely'
    | 'upper'
    | 'zeroblob'
    | 'date'
    | 'time'
    | 'datetime'
    | 'julianday'
    | 'unixepoch'
    | 'strftime'
;

PRAGMA_NAME_T:
    'analysis_limit'
    | 'application_id'
    | 'auto_vacuum'
    | 'automatic_index'
    | 'busy_timeout'
    | 'cache_size'
    | 'cache_spill'
    | 'case_sensitive_like'
    | 'cell_size_check'
    | 'checkpoint_fullfsync'
    | 'collation_list'
    | 'compile_options'
    | 'data_version'
    | 'database_list'
    | 'defer_foreign_keys'
    | 'encoding'
    | 'foreign_key_check'
    | 'foreign_key_list'
    | 'foreign_keys'
    | 'freelist_count'
    | 'fullfsync'
    | 'function_list'
    | 'hard_heap_limit'
    | 'ignore_check_constraints'
    | 'incremental_vacuum'
    | 'index_info'
    | 'index_list'
    | 'index_xinfo'
    | 'integrity_check'
    | 'journal_mode'
    | 'journal_size_limit'
    | 'legacy_alter_table'
    | 'legacy_file_format'
    | 'locking_mode'
    | 'max_page_count'
    | 'mmap_size'
    | 'module_list'
    | 'optimize'
    | 'page_count'
    | 'page_size'
    | 'parser_trace'
    | 'pragma_list'
    | 'query_only'
    | 'quick_check'
    | 'read_uncommitted'
    | 'recursive_triggers'
    | 'reverse_unordered_selects'
    | 'schema_version'
    | 'secure_delete'
    | 'shrink_memory'
    | 'soft_heap_limit'
    | 'stats'
    | 'synchronous'
    | 'table_info'
    | 'table_list'
    | 'table_xinfo'
    | 'temp_store'
    | 'threads'
    | 'trusted_schema'
    | 'user_version'
    | 'vdbe_addoptrace'
    | 'vdbe_debug'
    | 'vdbe_listing'
    | 'vdbe_trace'
    | 'wal_autocheckpoint'
;

AGGREGATE_FUNC_NAME_T:
    'avg'
    | 'count'
    | 'group_concat'
    | 'sum'
    | 'total'
;

COLUMN_NAME_T:
    'c0' | 'c1'
    | 'NEW.c0' | 'NEW.c1'
    | 'OLD.c0' | 'OLD.c1'
    | 'name'
    | 'path'
    | 'pageno'
    | 'pagetype'
    | 'ncell'
    | 'payload'
    | 'unused'
    | 'mx_payload'
    | 'pgoffset'
    | 'pgsize'
    | 'type'
    | 'tbl_name'
    | 'rootpage'
    | 'sql'
;

TABLE_NAME_T:
    't0' | 't1' | 't2' | 'sqlite_schema' | 'sqlite_temp_schema' | 'dbstat'
;

INDEX_NAME_T:
    'index0' | 'index1'
;

TRIGGER_NAME_T:
    'trig0' | 'trig1'
;

VIEW_NAME_T:
    'view0' | 'view1'
;

SAVEPOINT_NAME_T:
    'sav0' | 'sav1'
;

WINDOW_FUNC_NAME_T:
    'row_number' | 'rank' | 'dense_rank' | 'percent_rank'
    | 'cume_dist' | 'ntile' | 'lag' | 'lead' | 'first_value'
    | 'last_value' | 'nth_value'
;

WINDOW_NAME_T:
    'win0' | 'win1'
;

SCHEMA_NAME_T:
    'main' | 'temp'
;

ERROR_MESSAGE_T:
    '\'ahh\''
;

TYPE_BASE_NAME_T:
    'INTEGER' | 'REAL' | 'TEXT' | 'BLOB'
;

CONSTRAINT_NAME_T:
    'constr0' | 'constr1'
;

PRAGMA_SPECIAL_VALUE_T:
    'UTF-8'
    | 'UTF-16'
    | 'UTF-16le'
    | 'UTF-16be'
    | 'TRUNCATE'
    | 'PERSIST'
    | 'MEMORY'
    | 'WAL'
    | 'OFF'
    | 'NORMAL'
    | 'FAST'
    | 'PASSIVE'
    | 'RESTAR_T'
    | 'RESET'
;


NUMERIC_LITERAL_T:
    '0.0' | '0' | '7' | '3.14' | '0xda' | '42e-300' | '5e200' | '0xffff';


STRING_LITERAL_T: '\'lit0\'' | '\'\'' | '\':memory:\''
    | '\'%Y-%m-%d\'' | '\'%H:%M:%S.%f\'' | '\'%J%j%w%s\''
    | '\'%%\'' |  '\'unixepoch\'' | '\'auto\'';

BLOB_LITERAL_T: 'X\'53514C697465\'';

NEWLINE_T: '\n';

