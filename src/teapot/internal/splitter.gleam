import gleam/list

pub type Splitter

pub fn new(substrings: List(BitArray)) -> Splitter {
  substrings
  |> list.filter(fn(x) { x != <<>> })
  |> make
}

@external(erlang, "splitter_ffi", "split")
pub fn split(
  splitter: Splitter,
  string: BitArray,
) -> #(BitArray, BitArray, BitArray)

@external(erlang, "splitter_ffi", "split_before")
pub fn split_before(
  splitter: Splitter,
  string: BitArray,
) -> #(BitArray, BitArray)

@external(erlang, "splitter_ffi", "split_after")
pub fn split_after(
  splitter: Splitter,
  string: BitArray,
) -> #(BitArray, BitArray)

@external(erlang, "splitter_ffi", "new")
fn make(patterns: List(BitArray)) -> Splitter
