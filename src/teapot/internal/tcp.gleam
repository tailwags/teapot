import gleam/dynamic.{type Dynamic}
import teapot/internal/tcp/options.{type Options}

pub type Socket

pub type ListenSocket

@external(erlang, "gen_tcp", "listen")
fn do_listen(port: Int, options: List(Dynamic)) -> Result(ListenSocket, Dynamic)

pub fn listen(port: Int, options: Options) -> Result(ListenSocket, Dynamic) {
  do_listen(port, options |> options.to_dynamic())
}

@external(erlang, "gen_tcp", "accept")
pub fn accept(socket: ListenSocket) -> Result(Socket, Dynamic)
