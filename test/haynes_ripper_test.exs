defmodule HaynesRipperTest do
  use ExUnit.Case
  doctest HaynesRipper

  test "greets the world" do
    assert HaynesRipper.hello() == :world
  end
end
