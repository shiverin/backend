defmodule Cadet.Chatbot.PixelConversation do
  @moduledoc """
  The PixelConversation entity stores the messages exchanged between the user and the Pixel chatbot.
  Pixel is a general-purpose context-aware chatbot that appears on all pages except the SICP textbook.
  """
  use Cadet, :model

  alias Cadet.Accounts.User

  @type t :: %__MODULE__{
          user: User.t(),
          prepend_context: list(map()),
          messages: list(map())
        }

  schema "pixel_chats" do
    field(:prepend_context, {:array, :map}, default: [])
    field(:messages, {:array, :map}, default: [])

    belongs_to(:user, User)

    timestamps()
  end

  @required_fields ~w(user_id)a
  @optional_fields ~w(prepend_context messages)a

  def changeset(conversation, params) do
    conversation
    |> cast(params, @required_fields ++ @optional_fields)
    |> add_belongs_to_id_from_model([:user], params)
    |> validate_required(@required_fields)
  end
end
