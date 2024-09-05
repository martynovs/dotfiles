# cmux Browser Reference

Control an embedded browser pane alongside your terminals.
**When opening a browser pane, just open it — never wait for page load.**

## Surface Context

Browser commands need to know which browser surface to operate on. When calling from a terminal, always specify the surface explicitly:

```bash
cmux browser open-split https://example.com        # returns surface=surface:N pane=pane:M
cmux browser surface:N snapshot                    # use the returned surface ref
```

If you omit the surface while in a terminal context (non-browser surface), commands may fail unexpectedly with misleading errors.

## Opening a Browser

```bash
cmux browser open <url>           # create browser split in current workspace
cmux browser open-split <url>     # explicit split
```

## Navigation

```bash
cmux browser surface:N goto <url> [--snapshot-after]
cmux browser surface:N back | forward | reload [--snapshot-after]
cmux browser surface:N url                  # get current URL
```

## Reading Page Content

```bash
cmux browser surface:N get url|title|text|html|value|attr|count|box|styles [...]
cmux browser surface:N snapshot [--interactive|-i] [--compact] [--cursor] [--max-depth <n>] [--selector <css>]
cmux browser surface:N find <role|text|label|placeholder|alt|title|testid|first|last|nth> ...
cmux browser surface:N is <visible|enabled|checked> <selector>
cmux browser surface:N screenshot [--out <path>] [--json]
```

## Interacting with a Page

```bash
cmux browser surface:N click <selector> [--snapshot-after]
cmux browser surface:N dblclick|hover|focus|check|uncheck|scroll-into-view <selector> [--snapshot-after]
cmux browser surface:N type <selector> <text> [--snapshot-after]
cmux browser surface:N fill <selector> [text] [--snapshot-after]   # empty text clears input
cmux browser surface:N press <key> [--snapshot-after]              # also: keydown|keyup
cmux browser surface:N scroll [--selector <css>] [--dx <n>] [--dy <n>] [--snapshot-after]
cmux browser surface:N select <selector> <value> [--snapshot-after]
```

## Waiting

```bash
cmux browser surface:N wait [--selector <css>] [--text <text>] [--url-contains <text>] \
  [--load-state interactive|complete] [--function <js>] \
  [--timeout-ms <ms>] [--timeout <seconds>]
```

## JavaScript

```bash
cmux browser surface:N eval <script>
```

## Tabs

```bash
cmux browser surface:N tab new|list|switch|close|<index> [...]
cmux browser surface:N tab switch 2        # switch to tab index 2
```

## Common Workflow

**Open a browser alongside a terminal and inspect the page:**
```bash
# Just open it — the user can see the pane directly, never wait for load after open
cmux browser open-split https://docs.example.com
# If you need to interact afterwards, note the returned surface:N and use it
cmux browser surface:N snapshot --compact
cmux browser surface:N click "button[type=submit]" --snapshot-after
```
