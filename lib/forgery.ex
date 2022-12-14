defmodule Forgery do
  @moduledoc """
  Forgery is a slim yet extensible data generator in Elixir.

  Forgery provides a few simple APIs to work with. To get started, you
  need to implement the `make/2` callback:

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

  And just as simple as that!

  ## Ecto integration

  Forgery was built with easy Ecto integration in mind, though not limiting to it.

  For example if you use Ecto and have `MyRepo`. You can add a function, says `insert!`, into the factory:

      defmodule MyFactory do
        def insert!(factory_name, fields \\ %{}) do
          factory_name
          |> make(fields)
          |> MyRepo.insert!()
        end

        def insert_many!(factory_name, amount, fields \\ %{}) when amount >= 1 do
          [%schema{} | _] = entities = make_many(factory_name, amount, fields)

          {_, persisted_entities} = MyRepo.insert_all(schema, entities, returning: true)

          persisted_entities
        end
      end

      user = insert!(:user)
      users = insert_many!(:user, 10, %{password: "1234567890"})

  """

  @type factory_name() :: atom()

  @doc """
  Makes data from the given factory.

  The implementation of this callback should take in the factory name, as well and `fields`.
  """

  @callback make(factory_name(), fields :: Enumerable.t()) :: any()

  @doc """
  Make multiple data from the given factory.

  This function is roughly equivalent to:

      Enum.map(1..amount, fn _ -> make(factory_name) end)

  ### Example

      make_many(:users, 3)
      [
        %User{id: 3, password: nil, name: "user#3"},
        %User{id: 5, password: nil, name: "user#5"},
        %User{id: 7, password: nil, name: "user#7"}
      ]

  """
  @callback make_many(factory_name(), amount :: integer(), fields :: Enumerable.t()) ::
              list(any())

  defmacro __using__(_) do
    quote location: :keep do
      import Forgery

      @behaviour Forgery

      def make(factory_name, fields \\ %{})

      def make_many(factory_name, amount, fields \\ %{}) when is_integer(amount) do
        if amount > 0 do
          for _ <- 1..amount, do: make(factory_name, fields)
        else
          []
        end
      end
    end
  end

  @doc """
  Lazily evaluates `value_setter` and puts the result into `key` if it does not exist in `fields`.

  The `value_setter` function receives `fields` as an argument.

      iex> make_foo = fn _ -> raise("I am invoked") end
      iex> fields = %{foo: 1}
      iex> put_new_field(fields, :foo, make_foo)
      %{foo: 1}
      iex> put_new_field(fields, :bar, &(&1.foo + 100))
      %{foo: 1, bar: 101}

  There is also helper macro `lazy/1`:

      iex> fields = %{foo: 2}
      iex> put_new_field(fields, :foo, lazy(10 * 10))
      %{foo: 2}

  """
  @spec put_new_field(
          fields :: Enumerable.t(),
          key :: any(),
          value_setter :: (fields :: map() -> any())
        ) :: map()
  def put_new_field(fields, key, value_setter) when is_function(value_setter, 1) do
    case Map.new(fields) do
      %{^key => _value} = fields ->
        fields

      fields ->
        Map.put(fields, key, value_setter.(fields))
    end
  end

  @doc """
  Wraps the given `expr` into an anonymous function.

  It is equivalent to `fn _ -> expr end`.
  """
  defmacro lazy(expr) do
    quote do
      fn _ -> unquote(expr) end
    end
  end

  @doc """
  Create struct of `module` from `fields`.

  See `Kernel.struct!/2` for more information.

      iex> create_struct(%{id: 1, name: "John", password: "123456"}, User)
      %User{id: 1, password: "123456", name: "John"}

  """

  @spec create_struct(fields :: Enumerable.t(), module() | struct()) :: struct()
  def create_struct(fields, module) do
    struct!(module, fields)
  end

  @doc """
  Returns monotonically increasing unique integer. It would be useful when it comes to
  generate unique serial IDs.
  """
  @spec make_unique_integer() :: pos_integer()
  def make_unique_integer() do
    System.unique_integer([:monotonic, :positive])
  end
end
