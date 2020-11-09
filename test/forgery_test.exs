defmodule ForgeryTest do
  use ExUnit.Case, async: true

  defmodule User do
    defstruct [:id, :name, :password]
  end

  defmodule MyFactory do
    use Forgery

    def make(:user, fields) do
      id = make_unique_integer()
      make_foo = fn -> raise("unexpected") end

      fields
      |> put_new_field(:id, id)
      |> put_new_field(:name, "user##{id}")
      |> put_new_field(:name, make_foo.())
      |> create_struct(User)
    end
  end

  doctest Forgery

  test "make/1 and make/2" do
    assert %User{
             id: id,
             name: name
           } = MyFactory.make(:user)

    assert is_integer(id)
    assert id > 0
    assert name == "user##{id}"

    assert %User{
             id: 100,
             name: "user" <> _
           } = MyFactory.make(:user, id: 100)

    assert %User{name: "John"} = MyFactory.make(:user, name: "John")
  end

  test "make_many/4" do
    assert [user1, user2] = MyFactory.make_many(:user, 2, %{password: "123456"})
    assert user1.id != user2.id
    assert user1.name != user2.name

    assert user1.password == "123456"
    assert user2.password == "123456"
  end
end
