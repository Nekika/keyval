import gleam/dict
import gleam/option.{None, Some}
import gleam/result

import gleeunit
import gleeunit/should

import lib/repository.{Repository}

pub fn main() {
  gleeunit.main()
}

pub fn repository_new_test() {
  let name = "test"
  should.equal(repository.new(name), Repository(name, dict.new()))
}

pub fn repository_set_non_existing_key_test() {
  let repository = 
    repository.new("test")
    |> repository.set("hello", "world")

  let value = 
    dict.get(repository.values, "hello")
    |> result.unwrap("")

  should.equal(value, "world")

}
pub fn repository_set_existing_key_test() {
  let repository = 
    repository.new("test")
    |> repository.set("hello", "world")
    |> repository.set("hello", "planet")

  let value =
    dict.get(repository.values, "hello")
    |> result.unwrap("")

  should.equal(value, "planet")
}

pub fn repository_get_existing_key_test() {
  let value =
    repository.new("test")
    |> repository.set("hello", "world")
    |> repository.get("hello")

  should.equal(value, Some("world"))
}

pub fn repository_get_non_existing_key_test() {
  let value =
    repository.new("test")
    |> repository.get("hello")

  should.equal(value, None)
}

pub fn repository_delete_key_test() {
  let value = 
    repository.new("test")
    |> repository.set("hello", "world")
    |> repository.delete("hello")
    |> repository.get("hello")

  should.equal(value, None)
}
