-module(huffman).
-compile(export_all).

%%%%%%%%% build_code_table/1 %%%%%%%%%%%%%%%%%%

build_code_table(Text) -> Freq = freq(Text,[]),
				 Tree = tree(Freq),
				 codes(Tree).

freq([H|T], Res) ->
    case lists:keyfind(H, 1, Res) of
        {H, Count} -> freq(T, lists:keyreplace(H, 1, Res, {H, Count+1}));
        false -> freq(T, [{H, 1} | Res])
    end;
freq([], Res) ->
    Res.


tree([{Char, _} | []]) ->
    Char;
tree(Freq)->
	[{Key1, Freq1},{Key2, Freq2} | Rest] = lists:keysort(2, Freq),
	tree([{{Key1,Key2}, Freq1 + Freq2} | Rest]).


codes({LeftTraversal, RightTraversal}) ->
    codes(LeftTraversal, [0]) ++ codes(RightTraversal, [1]).
  		
codes({LeftTraversal, RightTraversal}, AssignedCode) ->
    codes(LeftTraversal, AssignedCode ++ [0]) ++ codes(RightTraversal, AssignedCode ++ [1]);
	
codes(Char, AssignedCode) ->
    [{[Char], string:join([integer_to_list(I) || I <- AssignedCode], "")}].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%% encode/1 %%%%%%%%%%%%%%%%%%

encode(Text) ->
	Table = build_code_table(Text),
	Dict = dict:from_list(Table),
	{Table,encode(Text, Dict, [])}.

encode([], _Dict, Result) ->
	Result;

encode([Char | Rest], Dict, Result) -> 
	Newvar = dict:fetch([Char], Dict),
	Newlist = lists:append([Result, Newvar]),
	encode(Rest , Dict, Newlist).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%% decode %%%%%%%%%%%%%%%%%%

decode(TableAndSeq)->
	{CodeTable,EncodedText} = TableAndSeq,
    decode(EncodedText,CodeTable,[]).

decode([], _Table, Result) ->
	Result;

decode(Seq, Table, Result) -> 
	{Char, Rest} = decode_char(Seq, 1, Table),
	NewChar = Char,
	Newlist = lists:append([Result, NewChar]),
	decode(Rest, Table, Newlist).
	

decode_char(Seq, N, Table) ->
	{Code, Rest} = lists:split(N, Seq),
	case lists:keyfind(Code, 2, Table) of
	{C,_} ->
		{C, Rest};
	false ->
		decode_char(Seq, N+1, Table)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	