import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}

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

pub fn insert(in: Repository, key: String, value: String) -> Repository {
  Repository(..in, values: dict.insert(in.values, key, value))
}

pub fn new(name: String) -> Repository {
  Repository(name, dict.new())
}

pub fn update(in: Repository, key: String, with: fn (Option(String)) -> String) -> Repository {
  Repository(..in, values: dict.update(in.values, key, with))
}
