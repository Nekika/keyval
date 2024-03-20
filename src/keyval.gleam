import gleam/erlang/process.{type Subject}

import lib/repository
import lib/repository/actor
import lib/server

pub fn main() {
  let assert Ok(repository_actor) = repository.new("main") |> actor.start()

  let request_subject = process.new_subject()
  process.start(linked: True, running: fn () { server.start(request_subject) })

  loop(repository_actor, request_subject)
}

fn loop(repository_actor: Subject(actor.Message), request_subject: Subject(server.Request)) {
  // wait for req

  // send them to repo
  // respond if necessary

  loop(repository_actor, request_subject)
}
