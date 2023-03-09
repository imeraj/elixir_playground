defmodule MailTpl do
  @moduledoc false

  def full(employee) do
    {[Employee.email(employee)], "Happy birthday!", body(employee)}
  end

  def body(employee) do
    name = Employee.first_name(employee)
    "Happy birthday, dear #{name}!"
  end
end
