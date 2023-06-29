Definitions.

ID = [a-zA-Z][0-9a-zA-Z_']*?

INT = [0-9]+
FLOAT = [0-9]+\.[0-9]+

STRING = \"(\\.|[^"\\])*\"

WHITESPACE = [\s\t\n\r]

Rules.

and : {token, {'and', TokenLine}}.
or  : {token, {'or', TokenLine}}.
not : {token, {'not', TokenLine}}.

null : {token, {null, TokenLine}}.

true  : {token, {bool, 'true', true}}.
false : {token, {bool, 'false', false}}.

{INT} : {token, {number, TokenLine, list_to_integer(TokenChars)}}.
{FLOAT} : {token, {number, TokenLine, list_to_float(TokenChars)}}.

{STRING} : {token, {string, TokenLine, build_string(TokenChars)}}.

{ID} : {token, {id, TokenLine, list_to_binary(TokenChars)}}.

,    : {token, {',', TokenLine}}.
\(   : {token, {'(', TokenLine}}.
\)   : {token, {')', TokenLine}}.
\[   : {token, {'[', TokenLine}}.
\]   : {token, {']', TokenLine}}.
\:\: : {token, {'::', TokenLine}}.

{WHITESPACE}+ : skip_token.

Erlang code.

build_string(TokenChars) ->
  Binary = unicode:characters_to_binary(TokenChars),
  trim_string(Binary).

trim_string(<<"\"", BinTail/binary>>) -> trim_string_tail(BinTail).

trim_string_tail(<<"\"">>) -> <<>>;
trim_string_tail(<<C, BinTail/binary>>) ->
  NewBinTail = trim_string_tail(BinTail),
  <<C, NewBinTail/binary>>.
