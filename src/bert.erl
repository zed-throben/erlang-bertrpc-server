%%% See http://github.com/mojombo/bert.erl for documentation.
%%% MIT License - Copyright (c) 2009 Tom Preston-Werner <tom@mojombo.com>

-module(bert).
-version('1.1.0').
-author("Tom Preston-Werner").

-export([encode/1, decode/1]).
-export([encode64/1, decode64/1]).

-ifdef(TEST).
-include("test/bert_test.erl").
-endif.

%%---------------------------------------------------------------------------
%% Public API

-spec encode(term()) -> binary().

encode(Term) ->
  term_to_binary(encode_term(Term),[{minor_version, 0}]).

-spec decode(binary()) -> term().

decode(Bin) ->
  decode_term(binary_to_term(Bin)).

-spec encode64(binary()) -> binary().
encode64(Term) ->
    base64:encode(encode(Term)).

-spec decode64(binary()) -> binary().
decode64(Term) ->
    decode(base64:decode(Term)).

%%---------------------------------------------------------------------------
%% Encode

-spec encode_term(term()) -> term().

encode_term(Term) ->
  case Term of
    [] -> {bert, nil};
    true -> {bert, true};
    false -> {bert, false};
    Dict when is_record(Term, dict, 9) ->
      {bert, dict, dict:to_list(Dict)};
    List when is_list(Term) ->
      lists:map((fun encode_term/1), List);
    Tuple when is_tuple(Term) ->
      TList = tuple_to_list(Tuple),
      TList2 = lists:map((fun encode_term/1), TList),
      list_to_tuple(TList2);
    _Else -> Term
  end.

%%---------------------------------------------------------------------------
%% Decode

-spec decode_term(term()) -> term().

decode_term(Term) ->
  case Term of
    {bert, nil} -> [];
    {bert, true} -> true;
    {bert, false} -> false;
    {bert, dict, Dict} ->
      dict:from_list(Dict);
    {bert, Other} ->
      {bert, Other};
    List when is_list(Term) ->
      lists:map((fun decode_term/1), List);
    Tuple when is_tuple(Term) ->
      TList = tuple_to_list(Tuple),
      TList2 = lists:map((fun decode_term/1), TList),
      list_to_tuple(TList2);
    _Else -> Term
  end.