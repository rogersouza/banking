defmodule BankingWeb.ErrorView do
  use BankingWeb, :view

  def render("400.json", changeset) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  def render("409.json", changeset) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  def render("insufficient_funds.json", _) do
    %{errors: "insufficient funds"}
  end

  def template_not_found(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
