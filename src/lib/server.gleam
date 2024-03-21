import gleam/bit_array
import gleam/bytes_builder
import gleam/erlang/process.{type Subject}
import gleam/option.{type Option, None}
import gleam/otp/actor.{type Next, Stop}
import gleam/result
import gleam/string_builder

import glisten.{Packet, type StartError}

import lib/repository.{type Action, Get}


type Connection = glisten.Connection(Nil)

type Message = glisten.Message(Nil)

type ProcessingError {
  RequestFailed
  RequestMalformed
  RequestUnsupported
}

pub type Request {
  Request(action: Action, subject: Subject(Option(String)))
}

pub fn start(subject parent_subject: Subject(Request)) -> Result(Nil, StartError)  {
  let handler = glisten.handler(fn() { #(process.new_subject(), None) }, handle_message(parent_subject))
  use _ <- result.map(glisten.serve(handler, 3000))
  process.sleep_forever()
}

fn handle_message(parent_subject: Subject(Request)) {
  fn(msg: Message, state: Subject(Option(String)), conn: Connection) -> Next(Message, Subject(Option(String))) {
    parse_message(msg, state)
    |> result.map(handle_request(_, conn, parent_subject))
    |> result.replace(actor.continue(state))
    |> result.map_error(fn(error) {
      let reason = processing_error_to_string(error)

      bytes_builder.from_string(reason)
      |> glisten.send(conn, _)
      
      Stop(process.Abnormal(reason))
    })
    |> result.unwrap_both()
  }
}


fn handle_request(req: Request, conn: Connection, owner: Subject(Request)) -> Result(Nil, ProcessingError) {
  process.send(owner, req)

  case req.action {
    Get(_) -> {
      process.new_selector()
      |> process.selecting(req.subject, option.unwrap(_, "/"))
      |> process.select_forever()
      |> string_builder.from_string()
      |> string_builder.append("\n")
      |> bytes_builder.from_string_builder()
      |> glisten.send(conn, _)

      Ok(Nil)
    }
    _ -> Ok(Nil)
  }
}

fn parse_message(msg: glisten.Message(Nil), subject: Subject(Option(String))) -> Result(Request, ProcessingError) {
  case msg {
    Packet(data) -> {
      bit_array.to_string(data)
      |> result.try(repository.parse_action)
      |> result.map(Request(action: _, subject: subject))
      |> result.replace_error(RequestMalformed)
    }
    _ -> Error(RequestUnsupported)
  } 
}

fn processing_error_to_string(error: ProcessingError) -> String {
  let reason  = case error {
    RequestFailed -> "request failed"
    RequestMalformed -> "request malformed"
    RequestUnsupported -> "request unsupported"
  }

  string_builder.new()
  |> string_builder.append("Error: ")
  |> string_builder.append(reason)
  |> string_builder.append(".\n")
  |> string_builder.to_string()
}


