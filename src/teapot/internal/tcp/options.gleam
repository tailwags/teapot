import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom
import gleam/option.{type Option, None, Some}

pub opaque type Options {
  Options(
    active: Option(ActiveMode),
    mode: Option(Mode),
    reuseaddr: Option(Reuseaddr),
    nodelay: Option(Nodelay),
    send_timeout: Option(SendTimeout),
    send_timeout_close: Option(SendTimeoutClose),
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

type Nodelay {
  Nodelay(Bool)
}

type SendTimeout {
  SendTimeout(Int)
}

type SendTimeoutClose {
  SendTimeoutClose(Bool)
}

pub fn new() -> Options {
  Options(
    active: None,
    mode: None,
    reuseaddr: None,
    nodelay: None,
    send_timeout: None,
    send_timeout_close: None,
  )
}

pub fn active(options: Options, active: ActiveMode) -> Options {
  Options(..options, active: Some(active))
}

pub fn mode(options: Options, mode: Mode) -> Options {
  Options(..options, mode: Some(mode))
}

pub fn reuseaddr(options: Options, reuseaddr: Bool) -> Options {
  Options(..options, reuseaddr: Some(Reuseaddr(reuseaddr)))
}

pub fn nodelay(options: Options, nodelay: Bool) -> Options {
  Options(..options, nodelay: Some(Nodelay(nodelay)))
}

pub fn send_timeout(options: Options, send_timeout: Int) -> Options {
  Options(..options, send_timeout: Some(SendTimeout(send_timeout)))
}

pub fn send_timeout_close(options: Options, send_timeout_close: Bool) -> Options {
  Options(
    ..options,
    send_timeout_close: Some(SendTimeoutClose(send_timeout_close)),
  )
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
  |> set_option(options.nodelay, cast)
  |> set_option(options.send_timeout, cast)
  |> set_option(options.send_timeout_close, cast)
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
