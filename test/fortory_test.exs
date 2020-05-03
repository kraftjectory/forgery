defmodule FortoryTest do
  use ExUnit.Case, async: true

  doctest Fortory

  defmodule User do
    defstruct [:id, :username, :password]
  end

  defmodule DummyFactory do
    use Fortory

    def make(:user, fields) do
      id = make_unique_integer()

      make_foo = fn -> raise("asdfasdf") end

      fields
      |> put_new_field(:id, id)
      |> put_new_field(:username, "user#{id}")
      |> put_new_field(:username, make_foo.())
      |> create_struct(User)
    end
  end

  test "make/1 and make/2" do
    assert %User{
             id: id,
             username: username
           } = DummyFactory.make(:user)

    assert is_integer(id)
    assert id > 0
    assert username == "user#{id}"

    assert %User{
             id: 100,
             username: username
           } = DummyFactory.make(:user, id: 100)

    assert "user" <> _ = username

    assert %User{username: "john"} = DummyFactory.make(:user, username: "john")
  end

  test "make_many/4" do
    assert [user1, user2] = DummyFactory.make_many(:user, 2, %{password: "123456"})
    assert user1.id != user2.id
    assert user1.username != user2.username

    assert user1.password == "123456"
    assert user2.password == "123456"
  end
end
