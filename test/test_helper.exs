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

ExUnit.start()
