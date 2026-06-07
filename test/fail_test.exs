defmodule Bonfire.FailTest do
  use ExUnit.Case, async: true

  test "fail/1 with an arbitrary string that has no matching atom returns status 500" do
    result = Bonfire.Fail.fail("a_totally_unique_string_qwerty_987_no_atom")
    assert %Bonfire.Fail{status: 500} = result
  end

  test "fail/1 with a known error atom returns the correct status" do
    assert %Bonfire.Fail{status: 404, code: :not_found} = Bonfire.Fail.fail(:not_found)
  end

  test "fail/1 with an {:error, string} tuple that has no matching atom returns status 500" do
    result = Bonfire.Fail.fail({:error, "not permitted to follow this group_xyz_no_atom"})
    assert %Bonfire.Fail{status: 500} = result
  end
end
