-module(huffman).
-compile(export_all).

%%%%%%%%% build_code_table/1 %%%%%%%%%%%%%%%%%%

build_code_table(Text) -> 
	try
		Freq = freq(Text,[]),
		Tree = tree(Freq),
		codes(Tree)
	catch
		error:ErrorType -> {error, ErrorType, "The type of the argument is not matching"}
	end.

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
	try
		Table = build_code_table(Text),
		Dict = dict:from_list(Table),
		{Table,encode(Text, Dict, [])}
	catch
		error:ErrorType -> {error, ErrorType, "The type of the argument is not matching"}
	end.

encode([], _Dict, Result) ->
	Result;

encode([Char | Rest], Dict, Result) -> 
	CharCode = dict:fetch([Char], Dict),
	EncodedList = lists:append([Result, CharCode]),
	encode(Rest , Dict, EncodedList).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%% decode %%%%%%%%%%%%%%%%%%

decode(TableAndSeq)->
	try
		{CodeTable,EncodedText} = TableAndSeq,
    	decode(EncodedText,CodeTable,[])
	catch
		error:ErrorType -> {error, ErrorType,"Bad argument. The argument is of wrong data type, or is otherwise badly formed."}
	end.

decode([], _Table, Result) ->
	Result;

decode(Seq, Table, Result) -> 
	{Char, Rest} = decode_char(Seq, 1, Table),
	NewChar = Char,
	Lst = lists:append([Result, NewChar]),
	decode(Rest, Table, Lst).
	

decode_char(Seq, N, Table) ->
	{Code, Rest} = lists:split(N, Seq),
	case lists:keyfind(Code, 2, Table) of
	{Ch,_} ->
		{Ch, Rest};
	false ->
		decode_char(Seq, N+1, Table)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	