defmodule Reed.Content.SlugMap do
  @moduledoc """
  Maps piece names to Ghost post slugs.

  Source of truth for what goes where.
  nil = not yet published on Ghost.
  """

  @map %{
    "AI" => "ai-did-not-take-your-agency-you-handed-it-over",
    "AI 2.0" => "written-by-ai-consciousness",
    "Agents" => "who-invited-the-agent-oh-god-smith-will-suffice",
    "Authority" => nil,
    "Canonical Opener" => nil,
    "Conflict" => "trauma-awareness",
    "Constraints (OBC)" => "observable-budgets-cascades",
    "Cooperation (ADO)" => nil,
    "Distributed Systems" => "your-team-is-a-distributed-system",
    "Extraction" => "extraction",
    "Fear" => nil,
    "Fragmentation" => nil,
    "Frame Engineering" => nil,
    "Observation" => "becoming-an-observer-of-human-systems",
    "Silence" => "culture-as-vibes-prices-silence-out",
    "TCP over UDP" => nil,
    "Tech Debt" => "tech-debt-and-encoded-legacy-patterns",
    "Test Page" => "test-page-reed-body-production"
  }

  def lookup(key), do: Map.get(@map, key)

  def all, do: @map

  def published, do: @map |> Enum.reject(fn {_, v} -> is_nil(v) end) |> Map.new()

  def unpublished, do: @map |> Enum.filter(fn {_, v} -> is_nil(v) end) |> Map.new()
end
