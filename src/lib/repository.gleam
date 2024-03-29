import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub type Repository {
  Repository(name: String, values: Dict(String, String))
}

pub fn delete(in: Repository, key: String) -> Repository {
  Repository(..in, values: dict.delete(in.values, key))
}

pub fn get(in: Repository, key: String) -> Option(String) {
  case dict.get(in.values, key) {
    Ok(value) -> Some(value)
    Error(_) -> None
  }
}

pub fn new(name: String) -> Repository {
  Repository(name, dict.new())
}

pub fn set(in: Repository, key: String, value: String) -> Repository {
  Repository(..in, values: dict.insert(in.values, key, value))
}

pub type Action {
  Delete(key: String)
  Get(key: String)
  Set(key: String, value: String)
}

pub fn parse_action(from: String) -> Result(Action, Nil) {
  let formatted = string.trim(from) |> string.lowercase()

  case formatted {
    "delete " <> key -> Ok(Delete(key))
    "get " <> key -> Ok(Get(key))
    "set " <> rest -> {
      string.split_once(rest, on: " ")
      |> result.map(fn(value) { Set(value.0, value.1) })
      |> result.replace_error(Nil)
    }
    _ -> Error(Nil)
  }
}
