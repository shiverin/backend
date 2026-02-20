defmodule Cadet.Repo.Migrations.CreatePixelChatsTable do
  use Ecto.Migration

  def change do
    create table(:pixel_chats) do
      add(:user_id, references(:users), null: false)
      add(:messages, :jsonb, null: false, default: "[]")
      add(:prepend_context, :jsonb, null: false, default: "[]")
      timestamps()
    end

    create(index(:pixel_chats, [:user_id]))
  end
end
