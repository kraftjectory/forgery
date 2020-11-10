# Forgery

![CI Status](https://github.com/kraftjectory/forgery/workflows/CI/badge.svg)
[![Hex Version](https://img.shields.io/hexpm/v/forgery.svg)](https://hex.pm/packages/forgery)

Forgery is a slim yet extensible data generator in Elixir.

## Installation

```elixir
def deps() do
  [{:forgery, "~> 0.1"}]
end
```

## Overview

Full documentation can be found at [https://hexdocs.pm/forgery](https://hexdocs.pm/forgery).

Forgery provides a few simple APIs to work with:

```elixir
defmodule User do
  defstruct [:id, :name, :password]
end

defmodule MyFactory do
  use Forgery

  def make(:user, fields) do
    fields
    |> put_new_field(:id, lazy(make_unique_integer()))
    |> put_new_field(:name, &("user#" <> Integer.to_string(&1.id)))
    |> create_struct(User)
  end
end

iex> import MyFactory
iex>
iex> %User{} = make(:user)
iex> %User{id: 42, name: "user#42"} = make(:user, id: 42)
iex> [%User{}, %User{}] = make_many(:user, 2)
```

And just as simple as that!

## Ecto integration

Forgery was built with easy Ecto integration in mind, though not limiting to it.

For example you use Ecto and have `MyRepo`. You can add a function, says `insert!` and `insert_many!`, into the factory:

```elixir
defmodule MyFactory do
  def insert!(factory_name, fields \\ %{}) do
    factory_name
    |> make(fields)
    |> MyRepo.insert!()
  end

  def insert_many!(factory_name, amount, fields \\ %{}) when amount >= 1 do
    [%schema{} | _] = entities = make_many(factory_name, amount, fields)

    {^amount, persisted_entities} = MyRepo.insert_all(schema, entities, returning: true)

    persisted_entities
  end
end

user = insert!(:user)
users = insert_many!(:user, 10, %{password: "1234567890"})
```

## Licensing

This software is licensed under [the ISC license](LICENSE).
