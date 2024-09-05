If user asks to open/switch pane (terminal) or show/open page (web) or to show/check running processes, always check whether you are running inside cmux:

```bash
echo $CMUX_WORKSPACE_ID
```

If the variable is set (non-empty), read the `cmux` skill before doing anything.
