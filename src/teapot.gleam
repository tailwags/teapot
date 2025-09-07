import gleam/bit_array
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/int
import gleam/option.{type Option}
import gleam/result
import gleam/string
import mug
import teapot/internal/splitter

pub fn send(
  req: request.Request(String),
) -> Result(response.Response(BitArray), String) {
  let assert Ok(socket) =
    mug.new(req.host, req.port |> option.unwrap(80)) |> mug.connect()

  let req_body =
    req.method |> http.method_to_string
    <> " "
    <> req.path
    <> " HTTP/1.1\r\n"
    <> "Host: "
    <> req.host
    <> "\r\n"
    <> "\r\n"

  let assert Ok(_) = socket |> mug.send(req_body |> bit_array.from_string)

  let assert Ok(rep) = socket |> mug.receive(1000)

  let assert Ok(#(line, rest)) = parse_field(rep)
  let assert Ok(#(code, _)) = parse_status_line(line)
  let assert Ok(#(headers, body)) = parse_headers(rest)

  Ok(response.Response(code, headers:, body:))
}

fn parse_status_line(rep: BitArray) -> Result(#(Int, Option(String)), Nil) {
  let space_splitter = splitter.new([<<" ">>])

  let #(_before, split, rest) = space_splitter |> splitter.split(rep)

  case split {
    <<" ">> -> {
      let #(before, split, _rest) = space_splitter |> splitter.split(rest)

      case split {
        <<" ">> -> {
          use code <- result.try(before |> bit_array.to_string)
          use code <- result.try(code |> int.parse)

          Ok(#(code, option.None))
        }

        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}

fn parse_field(fields: BitArray) -> Result(#(BitArray, BitArray), Nil) {
  let crlf_splitter = splitter.new([<<"\r\n">>])

  let #(before, split, after) = crlf_splitter |> splitter.split(fields)

  case split {
    <<"\r\n">> -> Ok(#(before, after))
    _ -> Error(Nil)
  }
}

fn parse_headers(rep: BitArray) -> Result(#(List(http.Header), BitArray), Nil) {
  do_parse_headers(rep, [])
}

fn do_parse_headers(
  rest: BitArray,
  headers: List(http.Header),
) -> Result(#(List(http.Header), BitArray), Nil) {
  let crlf_splitter = splitter.new([<<"\r\n">>])
  let header_splitter = splitter.new([<<":">>])

  case crlf_splitter |> splitter.split(rest) {
    #(<<"">>, <<"\r\n">>, rest) -> Ok(#(headers, rest))
    #(before, <<"\r\n">>, rest) -> {
      let #(before, split, after) = header_splitter |> splitter.split(before)

      case split {
        <<":">> -> {
          use name <- result.try(before |> bit_array.to_string)
          use field <- result.try(after |> bit_array.to_string)

          do_parse_headers(rest, [#(name, field |> string.trim), ..headers])
        }
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
}
