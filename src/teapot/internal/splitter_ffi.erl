-module(splitter_ffi).
-export([new/1, split/2, split_before/2, split_after/2]).

new([]) ->
    empty_splitter;
new(Patterns) ->
    binary:compile_pattern(Patterns).

split(empty_splitter, BitArray) ->
    {<<>>, <<>>, BitArray};
split(Splitter, BitArray) ->
    case binary:match(BitArray, Splitter) of
        nomatch -> {BitArray, <<>>, <<>>};  % No delimiter found
        {Index, Length} ->
            {binary:part(BitArray, 0, Index),
             binary:part(BitArray, Index, Length),
             binary:part(BitArray, Index + Length, byte_size(BitArray) - Index - Length)}
    end.

split_before(empty_splitter, BitArray) ->
    {<<>>, BitArray};
split_before(Splitter, BitArray) ->
    case binary:match(BitArray, Splitter) of
        nomatch -> {BitArray, <<>>};  % No delimiter found
        {Index, _Length} ->
            {binary:part(BitArray, 0, Index),
             binary:part(BitArray, Index, byte_size(BitArray) - Index)}
    end.

split_after(empty_splitter, BitArray) ->
    {<<>>, BitArray};
split_after(Splitter, BitArray) ->
    case binary:match(BitArray, Splitter) of
        nomatch -> {BitArray, <<>>};  % No delimiter found
        {Index, Length} ->
            SplitPoint = Index + Length,
            {binary:part(BitArray, 0, SplitPoint),
             binary:part(BitArray, SplitPoint, byte_size(BitArray) - SplitPoint)}
    end.
