# Migrations to support guest users in llm_chats. This includes:
# - Making user_id not null, as guest users do not have a user id and will use guest_uuid instead.
# - Add column guest uuid
# - Add constraint to ensure that either guest_uuid/ user_id is set

defmodule Cadet.Repo.Migrations.AddGuestUuidToLlmChats do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE llm_chats ALTER COLUMN user_id DROP NOT NULL")

    alter table(:llm_chats) do
      add(:guest_uuid, :string, null: true)
    end

    create(
      constraint(:llm_chats, :user_or_guest,
        check: """
        (user_id IS NOT NULL AND guest_uuid IS NULL)
        OR
        (user_id IS NULL AND guest_uuid IS NOT NULL)
        """
      )
    )

    create(index(:llm_chats, [:guest_uuid], where: "guest_uuid IS NOT NULL"))
  end

  def down do
    execute("DELETE FROM llm_chats WHERE user_id IS NULL")

    drop_if_exists(constraint(:llm_chats, :user_or_guest))
    drop_if_exists(index(:llm_chats, [:guest_uuid]))

    alter table(:llm_chats) do
      remove(:guest_uuid)
    end

    execute("ALTER TABLE llm_chats ALTER COLUMN user_id SET NOT NULL")
  end
end
