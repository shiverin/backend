defmodule Cadet.Chatbot.Conversation do
  @moduledoc """
  The Conversation entity stores the messages exchanged between the user and the chatbot.
  """
  use Cadet, :model

  alias Cadet.Accounts.User

  @type t :: %__MODULE__{
          user: User.t() | nil,
          guest_uuid: String.t() | nil,
          prepend_context: list(map()),
          messages: list(map())
        }

  schema "llm_chats" do
    field(:prepend_context, {:array, :map}, default: [])
    field(:messages, {:array, :map}, default: [])
    field(:guest_uuid, :string)

    belongs_to(:user, User)

    timestamps()
  end

  @all_fields ~w(user_id guest_uuid prepend_context messages)a

  def changeset(conversation, params) do
    conversation
    |> cast(params, @all_fields)
    |> add_belongs_to_id_from_model([:user], params)
    |> validate_required([:user_id])
    |> check_constraint(:user_id,
      name: :user_or_guest,
      message: "exactly one of user_id or guest_uuid must be set"
    )
  end

  def guest_changeset(conversation, params) do
    conversation
    |> cast(params, @all_fields)
    |> validate_required([:guest_uuid])
    |> validate_format(
      :guest_uuid,
      ~r/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    )
    |> check_constraint(:guest_uuid,
      name: :user_or_guest,
      message: "exactly one of user_id or guest_uuid must be set"
    )
  end
end
