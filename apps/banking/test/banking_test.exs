defmodule BankingTest do
  use Banking.DataCase

  import Banking.Factory

  @user_fixture build(:user)

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Auth.Repo)
  end

  defp debit(user_id, amount) do
    insert(:transaction,
      amount: amount,
      user_id: user_id,
      type: "debit"
    )
  end

  describe "credit/2" do
    setup do
      {:ok, user} = Repo.insert(@user_fixture)
      %{user: user}
    end

    test "credits 1000$ for the given user", %{user: user} do
      amount = Money.parse!("1000,00")
      {:ok, transaction} = Banking.credit(user.id, amount)
      
      assert transaction.amount == amount
      assert transaction.type == "credit"
    end
  end

  describe "balance/1" do
    setup do
      {:ok, user} = Repo.insert(@user_fixture)
      %{user: user}    
    end

    test "returns the sum of all transactions (debit and credit)", %{user: user} do
      {:ok, _} = Banking.credit(user.id, "100,00")
      {:ok, _} = Banking.credit(user.id, "100,00")
      debit(user.id, "50,00")

      expected_balance = Money.parse!("150,00")
      assert Banking.balance(user.id) == expected_balance
    end
  end
end