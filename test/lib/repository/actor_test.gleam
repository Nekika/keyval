import gleam/erlang/process.{type Subject}
import gleam/option.{None, Some}

import gleeunit
import gleeunit/should

import lib/repository.{type Repository}
import lib/repository/actor.{type Message, Delete, Get, Set}

pub fn main() {
  gleeunit.main()
}

fn create_actor() -> Subject(Message) {
  let assert Ok(actor) =
    repository.new("test")
    |> repository.set("message", "hello")
    |> actor.start()

  actor
}

pub fn actor_get_test() {
  create_actor()
  |> process.call(Get("message", _), 10)
  |> should.equal(Some("hello"))
}

pub fn actor_set_test() {
  let actor = create_actor()

  process.send(actor, Set("secret", "mypassword123"))

  process.call(actor, Get("secret", _), 10)
  |> should.equal(Some("mypassword123"))
}

pub fn actor_delete_test() {
  let actor = create_actor()

  process.send(actor, Delete("message"))

  process.call(actor, Get("message", _), 10)
  |> should.equal(None)
}
