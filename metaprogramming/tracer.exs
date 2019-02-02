defmodule Tracer do
  defp name_and_args({:when, _, [short_head | _ ]}) do
    name_and_args(short_head)
  end

  defp name_and_args(short_head) do
    Macro.decompose_call(short_head)
  end

  defmacro deftraceable(head, body) do
    {func_name, args_ast} = name_and_args(head)

    quote do
      def unquote(head) do
        file = __ENV__.file
        line = __ENV__.line
        module = __ENV__.module

        function_name = unquote(func_name)
        passed_args = unquote(args_ast) |> Enum.map(&IO.inspect/1) |> Enum.join(",")

        result = unquote(body[:do])

        loc = "#{file}(line #{line})"
        call = "#{module}.#{function_name}(#{passed_args}) = #{inspect(result)}"
        IO.puts("#{loc} #{call}")

        result
      end
    end
  end
end

defmodule Test do
  import Tracer

  deftraceable my_func(a, b) when a < b do
    a * b
  end
end
