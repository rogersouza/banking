defmodule BankingTest do
  use Banking.DataCase

  import Banking.Factory

  @user_fixture build(:user)
  @initial_balance Application.get_env(:banking, :initial_balance) |> Money.new()

  defp debit(user_id, amount) do
    insert(:transaction,
      amount: amount,
      user_id: user_id,
      type: "debit",
      description: "system_debit"
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

  describe "withdraw/1" do
    setup do
      {:ok, user} = Repo.insert(@user_fixture)
      {:ok, _} = Banking.credit(user.id, @initial_balance)
      %{user: user}
    end

    test "takes the given amount out of user's wallet", %{user: user} do
      amount = Integer.floor_div(@initial_balance.amount, 2)

      {:ok, _withdraw} = Banking.withdraw(user.id, amount)

      expected_balance = Money.subtract(@initial_balance, amount)
      assert Banking.balance(user.id) == expected_balance
    end

    test "doesn't allow withdraws if user has not sufficient funds", %{user: user} do
      amount = Money.add(@initial_balance, Money.new(1000))
      assert {:error, :insufficient_funds} = Banking.withdraw(user.id, amount)
    end

    test "returns the money to user's wallet if user has not sufficient funds", %{user: user} do
      amount = Money.add(@initial_balance, Money.new(1000))

      balance_before_withdraw = Banking.balance(user.id)
      {:error, :insufficient_funds} = Banking.withdraw(user.id, amount)
      balance_after_withdraw = Banking.balance(user.id)

      assert balance_before_withdraw == balance_after_withdraw
    end
  end
end
