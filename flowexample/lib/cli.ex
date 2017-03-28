use Mix.Config

defmodule Flowexample.CLI do
  def main(_args) do
    IO.puts "Invoke clump()"
    IO.inspect Flowexample.clump("CGGACTCGACAGATGTGAAGAACGACAATGTGAAGACTCGACACGACAGAGTGAAGAGAAGAGGAAACATTGTAA", 5, 4)
  end
end
