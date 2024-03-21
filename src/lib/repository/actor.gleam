import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/option.{type Option}
import gleam/otp/actor.{type Next, type StartError}

import lib/repository.{type Repository}

pub type Message {
  Delete(key: String)
  Get(key: String, subject: Subject(Option(String)))
  Set(key: String, value: String)
}

fn handle_message(msg: Message, state: Repository) -> Next(Message, Repository) {
  io.debug(msg)
  io.debug(state)

  case msg {
    Delete(key) -> handle_delete(state, key)
    Get(key, subject) -> handle_get(state, key, subject)
    Set(key, value) -> handle_set(state, key, value)
  }
}

fn handle_delete(state: Repository, key: String) -> Next(Message, Repository) {
  let state = repository.delete(state, key)
  actor.continue(state)
}

fn handle_get(state: Repository, key: String, subject: Subject(Option(String))) -> Next(Message, Repository) {
  let value =  repository.get(state, key)
  process.send(subject, value)
  actor.continue(state)
}

fn handle_set(state: Repository, key: String, value: String) -> Next(Message, Repository) {
  let state = repository.set(state, key, value)
  actor.continue(state)
}

pub fn start(repository: Repository) -> Result(Subject(Message), StartError) {
  actor.start(repository, handle_message)
}
