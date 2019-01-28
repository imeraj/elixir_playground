defmodule Math do
  defmacro say({:+, _, [lhs, rhs]})  do
    quote do
      unquote(lhs) + unquote(rhs)
    end
  end
end
