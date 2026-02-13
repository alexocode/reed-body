defmodule Reed.Content.PieceTest do
  use ExUnit.Case, async: true

  alias Reed.Content.Piece

  @valid_fixture "test/fixtures/Piece - Test.md"
  @no_title_fixture "test/fixtures/Piece - No Title.md"
  @invalid_fixture "test/fixtures/NotAPiece.md"

  describe "from_file/1" do
    test "parses valid piece file" do
      piece = Piece.from_file(@valid_fixture)

      assert %Piece{} = piece
      assert piece.path == @valid_fixture
      assert piece.title == "Test Piece Title"
      assert piece.key == "Test"
      assert piece.slug == nil
      assert piece.body =~ "This is the body content"
    end

    test "uses key as title when no heading found" do
      piece = Piece.from_file(@no_title_fixture)

      assert piece.title == "No Title"
      assert piece.key == "No Title"
    end

    test "returns nil for invalid filename pattern" do
      assert Piece.from_file(@invalid_fixture) == nil
    end
  end

  describe "to_html/1" do
    test "converts markdown to HTML" do
      piece = Piece.from_file(@valid_fixture)
      html = Piece.to_html(piece)

      assert html =~ "<h1>"
      assert html =~ "Test Piece Title"
      assert html =~ "<h2>"
      assert html =~ "Subtitle"
      assert html =~ "<p>"
      assert html =~ "This is the body content"
    end

    test "handles markdown with no title" do
      piece = Piece.from_file(@no_title_fixture)
      html = Piece.to_html(piece)

      assert html =~ "<p>"
      assert html =~ "Just body content"
    end
  end
end
