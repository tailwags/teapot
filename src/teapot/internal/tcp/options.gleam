import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom
import gleam/option.{type Option, None, Some}

pub opaque type Options {
  Options(
    active: Option(ActiveMode),
    mode: Option(Mode),
    reuseaddr: Option(Reuseaddr),
  )
}

pub type Mode {
  Binary
  List
}

pub type ActiveMode {
  Active
  Passive
  Once
  Count(Int)
}

type Reuseaddr {
  Reuseaddr(Bool)
}

pub fn default() -> Options {
  Options(
    active: Some(Active),
    mode: Some(Binary),
    reuseaddr: Some(Reuseaddr(True)),
  )
}

pub fn empty() -> Options {
  Options(active: None, mode: None, reuseaddr: None)
}

pub fn active(options: Options, active: ActiveMode) -> Options {
  Options(..options, active: Some(active))
}

pub fn reuseaddr(options: Options, reuseaddr: Bool) -> Options {
  Options(..options, reuseaddr: Some(Reuseaddr(reuseaddr)))
}

pub fn to_dynamic(options: Options) -> List(Dynamic) {
  []
  |> set_option(options.active, fn(v) {
    {
      let active = atom.create("active")

      case v {
        Active -> #(active, True) |> cast
        Passive -> #(active, False) |> cast
        Once -> #(active, atom.create("once")) |> cast
        Count(n) -> #(active, n) |> cast
      }
    }
  })
  |> set_option(options.mode, cast)
  |> set_option(options.reuseaddr, cast)
}

fn set_option(
  options: List(Dynamic),
  option: Option(a),
  apply: fn(a) -> Dynamic,
) -> List(Dynamic) {
  case option {
    None -> options
    Some(a) -> [apply(a), ..options]
  }
}

@external(erlang, "gleam_stdlib", "identity")
fn cast(a: anything) -> Dynamic
