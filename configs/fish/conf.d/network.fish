status is-interactive || exit

# wget replacement
type -q xh; and alias wget "xh -dF"

# httpie replacement
type -q xh; and alias http "xh"

type -q posting; and alias api "posting"

# network stats shortcuts
alias opencons "lsof -PiTCP -s TCP:^LISTEN"
alias openports "lsof -PiTCP -s TCP:LISTEN"
