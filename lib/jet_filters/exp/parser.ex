defmodule JetFilters.Exp.Parser do
  @moduledoc false

  @type line() :: non_neg_integer()

  @opaque ast() :: {conjunction(), line(), [ast()]} | {call_id(), line(), [id() | literal()]}

  @typep conjunction() :: :and | :or | :not
  @typep call_id() :: {:id, String.t()}

  @typep id() :: {:id, line(), String.t()}
  @typep literal() :: nil | boolean() | number() | String.t() | annotation() | [literal()]
  @typep annotation() :: {:"::", line(), list()}

  @spec parse(String.t()) ::
          {:ok, ast()} | {:error, term()} | {:error, error_info :: term(), line()}
  # credo:disable-for-previous-line JetCredo.Checks.ExplicitAnyType
  def parse(code) do
    with({:ok, tokens, _line} <- code |> to_charlist() |> :jet_filter_exp_tokenizer.string()) do
      :jet_filter_exp_parser.parse(tokens)
    end
  end
end
