import gleam/erlang/process.{type Selector, type Subject}
import gleam/function

import lib/repository
import lib/repository/actor
import lib/server

pub fn main() {
  let assert Ok(repository_actor) = repository.new("main") |> actor.start()

  let request_subject = process.new_subject()
  process.start(linked: True, running: fn () { server.start(request_subject) })

  let request_selector = process.new_selector() |> process.selecting(request_subject, function.identity)

  loop(repository_actor, request_selector)
}

fn loop(repository_actor: Subject(actor.Message), request_selector: Selector(server.Request)) {
  // wait for req
  let request = process.select_forever(request_selector)

  process.start(linked: True, running: fn() {
    case request.action {
      repository.Delete(key) -> process.send(repository_actor, actor.Delete(key))

      repository.Get(key) -> process.send(repository_actor, actor.Get(key, request.subject))

      repository.Set(key, value) -> process.send(repository_actor, actor.Set(key, value))
    }
  })

  loop(repository_actor, request_selector)
}
