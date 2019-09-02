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

  describe "transfer/2" do
    setup do
      {:ok, source_user} =
        build(:user)
        |> Db.Repo.insert()

      {:ok, destination_user} =
        build(:user)
        |> Db.Repo.insert()

      {:ok, _} = Banking.credit(source_user.id, @initial_balance)
      {:ok, _} = Banking.credit(destination_user.id, @initial_balance)

      %{source_user: source_user, destination_user: destination_user}
    end

    test "debits from source user's wallet", %{
      source_user: source_user,
      destination_user: destination_user
    } do
      transfer_attrs = %{
        source_user_id: source_user.id,
        destination_user_id: destination_user.id,
        amount: @initial_balance
      }

      balance_before_transfer = Banking.balance(source_user.id)
      {:ok, _transfer} = Banking.transfer(transfer_attrs)

      expected_balance = Money.subtract(balance_before_transfer, @initial_balance)
      assert Banking.balance(source_user.id) == expected_balance
    end

    test "credits on destination user's wallet", %{
      source_user: source_user,
      destination_user: destination_user
    } do
      transfer_attrs = %{
        source_user_id: source_user.id,
        destination_user_id: destination_user.id,
        amount: @initial_balance
      }

      balance_before_transfer = Banking.balance(destination_user.id)
      {:ok, _transfer} = Banking.transfer(transfer_attrs)

      expected_balance = Money.add(balance_before_transfer, @initial_balance)
      assert Banking.balance(destination_user.id) == expected_balance
    end

    test "doens't allow the transfer if the source user hasn't enough money", %{
      source_user: source_user,
      destination_user: destination_user
    } do
      transfer_attrs = %{
        source_user_id: source_user.id,
        destination_user_id: destination_user.id,
        amount: @initial_balance.amount + 1000
      }

      assert {:error, :insufficient_funds} = Banking.transfer(transfer_attrs)
    end

    test "returns the changeset if the amount is invalid", %{
      source_user: source_user,
      destination_user: destination_user
    } do
      transfer_attrs = %{
        source_user_id: source_user.id,
        destination_user_id: destination_user.id,
        amount: "invalid amount"
      }

      {:error, changeset} = Banking.transfer(transfer_attrs)
      assert "is invalid" in errors_on(changeset).amount
    end

    test "checks if the destination user exists", %{
      source_user: source_user,
      destination_user: destination_user
    } do
      transfer_attrs = %{
        source_user_id: source_user.id,
        destination_user_id: 0,
        amount: "100,00"
      }

      {:error, changeset} = Banking.transfer(transfer_attrs)
      assert "doesn't exist" in errors_on(changeset).destination_user_id
    end

    test "the transferred amount should be positive", %{
      source_user: source_user,
      destination_user: destination_user
    } do
      transfer_attrs = %{
        source_user_id: source_user.id,
        destination_user_id: destination_user.id,
        amount: "0,00"
      }

      {:error, changeset} = Banking.transfer(transfer_attrs)
      assert "must be positive" in errors_on(changeset).amount
    end
  end
end
