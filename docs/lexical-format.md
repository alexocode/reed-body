# Ghost Lexical Format

Reverse-engineered from published systemic.engineering pieces.

## Structure

Lexical is a JSON tree:
```json
{
  "root": {
    "children": [nodes...],
    "direction": "ltr",
    "format": "",
    "indent": 0,
    "type": "root",
    "version": 1
  }
}
```

## Node Types

### Observed in Production

From analysis of 9 published pieces:

| Node Type | Count | Description |
|-----------|-------|-------------|
| `paragraph` | ~300 | Text blocks with inline formatting |
| `extended-heading` | ~35 | Headers (h2-h6) |
| `extended-quote` | ~15 | Blockquotes |
| `list` | ~10 | Ordered/unordered lists |
| `horizontalrule` | 4 | Horizontal dividers |
| `paywall` | 1-2 | Members-only content marker |
| `signup` | 1-2 | Email signup forms |
| `image` | 1+ | Images with captions |
| `html` | 1+ | Raw HTML blocks |

### Text Nodes

Inside paragraphs and other containers:

- `extended-text`: Text content with formatting
- `linebreak`: Line breaks within paragraphs
- `link`: Hyperlinks

## Paragraph Structure

```json
{
  "type": "paragraph",
  "children": [
    {
      "type": "extended-text",
      "text": "Hi.",
      "format": 0,
      "mode": "normal",
      "style": "",
      "detail": 0,
      "version": 1
    },
    {
      "type": "linebreak",
      "version": 1
    },
    {
      "type": "extended-text",
      "text": "Bye.",
      "format": 0,
      ...
    }
  ],
  "direction": "ltr",
  "format": "",
  "indent": 0,
  "version": 1
}
```

**Key insight**: Markdown line breaks within paragraphs → `linebreak` nodes in Lexical.

## Heading Structure

```json
{
  "type": "extended-heading",
  "tag": "h2",
  "children": [
    {
      "type": "extended-text",
      "text": "Loss of Ownership",
      "format": 0,
      ...
    }
  ],
  "direction": "ltr",
  "format": "",
  "indent": 0,
  "version": 1
}
```

## Quote Structure

```json
{
  "type": "extended-quote",
  "children": [
    {
      "type": "extended-text",
      "text": "Language:",
      "format": 1,  // Bold
      ...
    },
    {
      "type": "linebreak",
      "version": 1
    },
    ...
  ],
  "direction": "ltr",
  "format": "",
  "indent": 0,
  "version": 1
}
```

## Text Formatting

The `format` field is a bitmask:
- `0`: Normal
- `1`: Bold
- `2`: Italic
- `4`: Strikethrough
- `8`: Code
- Combinations: bitwise OR (e.g., `3` = bold + italic)

## Analysis by Piece

| Piece | Nodes | Headings | Quotes | Lists | Special |
|-------|-------|----------|--------|-------|---------|
| AI | 51 | 5 | 2 | 1 | signup |
| AI 2.0 | 127 | 12 | 5 | 5 | html, 4x hr, paywall |
| Agents | 38 | 5 | 2 | 1 | image |
| Conflict | 57 | 6 | 4 | 2 | paywall, signup |
| Constraints (OBC) | 72 | ? | ? | ? | ? |

## Transformation Patterns

### Markdown → Lexical

1. **Paragraph breaks** (double newline) → New `paragraph` node
2. **Line breaks** (single newline) → `linebreak` node within paragraph
3. **Headings** (`##`) → `extended-heading` with `tag: "h2"`
4. **Blockquotes** (`>`) → `extended-quote`
5. **Bold** (`**text**`) → `format: 1`
6. **Lists** (`-` or `1.`) → `list` node with `listitem` children
7. **Horizontal rules** (`---`) → `horizontalrule`
8. **Links** (`[text](url)`) → `link` node with `url` field

## Next Steps

To build Markdown → Lexical transformer:
1. Parse Markdown AST (using Earmark or custom parser)
2. Map AST nodes to Lexical nodes
3. Handle inline formatting (bold, italic, links)
4. Generate valid Lexical JSON
5. Test against Ghost API

## References

- Ghost Lexical: https://ghost.org/docs/lexical/
- Analysis command: `just analyze-lexical`
- Fetch command: `just fetch-lexical SLUG`
