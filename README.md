# Forgery

Forgery is a slim though extensible test data generator in Elixir.

## Installation

```elixir
def deps() do
  [{:forgery, "~> 0.1"}]
end
```

## Overview

Full documentation can be found at [https://hexdocs.pm/forgery](https://hexdocs.pm/forgery).

Forgery provides only a few simple APIs to work with:

```elixir
defmodule MyUser do
  defstruct [:id, :username, :password]
end

defmodule MyFactory do
  use Forgery

  def make(:user, fields) do
    fields
    |> put_new_field(:id, make_unique_integer())
    |> put_new_field(:username, "user" <> to_string(make_unique_integer()))
    |> create_struct(MyUser)
  end
end

iex> import MyFactory
iex>
iex> %MyUser{} = make(:user)
iex> %MyUser{id: 42} = make(:user, id: 42)
iex> [%MyUser{}, %MyUser{}] = make_many(:user, 2)
```

And just as simple as that!

## Ecto integration

Forgery was built with easy Ecto integration in mind, though not limiting to it.

For example you use Ecto and have `MyRepo`. You can add a function, says `insert!` and `insert_many!`, into the factory:

```elixir
defmodule MyFactory do
  def insert!(factory, fields \\ %{}) do
    :user
    |> make(fields)
    |> MyRepo.insert!()
  end

  def insert_many!(factory, amount, fields \\ %{}) when amount >= 1 do
    [%schema{} | _] = entities = make_many(:user, amount, fields)

    {^amount, persisted_entities} = MyRepo.insert_all(schema, entities, returning: true)

    persisted_entities
  end
end

user = insert!(:user)
users = insert_many!(:user, 10, %{password: "1234567890"})
```

## Licensing

This software is licensed under [the ISC license](LICENSE).
