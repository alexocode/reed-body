defmodule Mix.Tasks.Sync do
  @moduledoc """
  Sync markdown pieces to Ghost.

      mix sync                  # sync all pieces
      mix sync --dry-run        # show what would happen
      mix sync path/to/file.md  # sync specific files
  """

  use Mix.Task

  @shortdoc "Sync pieces to Ghost"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, files, _} = OptionParser.parse(args, switches: [dry_run: :boolean])

    case files do
      [] -> Reed.sync_all(opts)
      paths -> Reed.sync(paths, opts)
    end
  end
end
