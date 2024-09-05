status is-interactive || exit

# wget replacement
type -q xh; and alias wget "xh -dF"

# httpie replacement
type -q xh; and alias http xh

type -q posting; and alias web posting

type -q chiko; and alias web-grpc chiko

abbr ssync "rsync -avzP -e ssh"

# network stats shortcuts
alias opencons "lsof -PiTCP -s TCP:^LISTEN"
alias openports "lsof -PiTCP -s TCP:LISTEN"

function px --description 'Run shell command with local proxy'
    set -x HTTP_PROXY "http://127.0.0.1:12334"
    set -x HTTPS_PROXY "http://127.0.0.1:12334"
	set -x NO_PROXY "localhost,127.0.0.1"
	eval $argv
end
