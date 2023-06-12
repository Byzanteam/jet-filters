Nonterminals
  expr
  call call_args_parens call_args call_arg
  literal_list literal_list_elems literal_list_elem
  conjunction and_op or_op not_op
  literal annotation
  .

Terminals
  id null bool number string
  and or not
  ',' '(' ')' '[' ']' '::'
  .

Rootsymbol expr.

Left     10 or_op.
Left     20 and_op.
Nonassoc 30 not_op.

expr -> call : '$1'.
expr -> conjunction : '$1'.
expr -> '(' expr ')' : '$2'.

call -> id call_args_parens : build_call('$1', '$2').
call_args_parens -> '(' ')' : [].
call_args_parens -> '(' call_args ')' : lists:reverse('$2').
call_args -> call_arg : ['$1'].
call_args -> call_args ',' call_arg : ['$3' | '$1'].
call_arg -> id : '$1'.
call_arg -> literal : '$1'.
call_arg -> literal_list : '$1'.

literal_list -> '[' ']' : [].
literal_list -> '[' literal_list_elems ']' : lists:reverse('$2').
literal_list_elems -> literal_list_elem : ['$1'].
literal_list_elems -> literal_list_elems ',' literal_list_elem : ['$3' | '$1'].
literal_list_elem -> literal : '$1'.
literal_list_elem -> literal_list : '$1'.

conjunction -> expr and_op expr : build_conjunction('$2', ['$1', '$3']).
conjunction -> expr or_op expr : build_conjunction('$2', ['$1', '$3']).
conjunction -> not_op expr : build_conjunction('$1', ['$2']).

and_op -> 'and' : '$1'.
or_op -> 'or' : '$1'.
not_op -> 'not' : '$1'.

literal -> null : nil.
literal -> bool : build_literal('$1').
literal -> number : build_literal('$1').
literal -> string : build_literal('$1').
literal -> annotation : '$1'.

annotation -> literal '::' id : build_annotation('$2', ['$1', '$3']).

Erlang code.

build_literal({_Category, _TokenLine, Value}) -> Value.
build_call({id, TokenLine, Id}, Args) -> {{id, Id}, TokenLine, Args}.
build_conjunction({Op, TokenLine}, Args) -> {Op, TokenLine, Args}.
build_annotation({'::', TokenLine}, [Value, {id, _TokenLine, Id}]) -> {'::', TokenLine, [Value, Id]}.
