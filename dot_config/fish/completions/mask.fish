function __mask_commands
    mask -h 2>/dev/null | sd -f s ".+SUBCOMMANDS:\n" "" | string replace -r '^\s+(\w+)\s+(.*)$' '$1\t$2' | grep -v '^help   '
end

# Disable file completions for mask
complete -f mask

# Complete subcommands dynamically by running __mask_commands
complete -c mask -n '__fish_use_subcommand' -a '(__mask_commands)'
