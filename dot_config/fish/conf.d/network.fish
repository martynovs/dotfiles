status is-interactive || exit

# wget replacement
type -q xh; and alias wget "xh -dF"

# httpie replacement
type -q xh; and alias http xh

type -q posting; and alias web posting

type -q chiko; and alias web-grpc chiko

# network stats shortcuts
alias opencons "lsof -PiTCP -s TCP:^LISTEN"
alias openports "lsof -PiTCP -s TCP:LISTEN"

function px --description 'Run shell command with local proxy'
	set -x HTTP_PROXY http://127.0.0.1:12334
	set -x HTTPS_PROXY http://127.0.0.1:12334
	eval $argv
end

function proxyit --description 'Run proxychains4 and when inside a container replace 127.0.0.1 with host.docker.internal IP'
	set -l in_container 0
	if test -f /.dockerenv
		set in_container 1
	else if test -r /proc/1/cgroup
		if grep -qE 'docker|kubepods|containerd' /proc/1/cgroup 2>/dev/null
			set in_container 1
		end
	end

	set -l cfg ~/.config/proxy
	if test $in_container -eq 0
		proxychains4 -q -f $cfg $argv
		return $status
	end

	set -l host_ip 127.0.0.1
	# Try to resolve host.docker.internal using a few fallbacks
	if test "$host_ip" = '127.0.0.1' && type -q getent
		set -l g (getent hosts host.docker.internal 2>/dev/null)
		if test -n "$g"
			set host_ip (echo $g | awk '{print $1}')
		end
	end

	if test "$host_ip" = '127.0.0.1' && type -q nslookup
		set -l ns (nslookup host.docker.internal 2>/dev/null | awk '/^Address: /{print $2; exit}')
		if test -n "$ns"
			set host_ip $ns
		end
	end

	if test "$host_ip" = '127.0.0.1' && type -q ping
		# ping first line usually contains the resolved IP in parentheses
		set -l pline (ping -c 1 host.docker.internal 2>/dev/null | sed -n '1p')
		if test -n "$pline"
			set -l ip (string match -r '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' -- $pline)
			if test -n "$ip"
				set host_ip $ip
			end
		end
	end

	# If resolved to something other than loopback, create temp config and run proxychains with it
	if test "$host_ip" != '127.0.0.1'
		set -l tmp_cfg (mktemp)
		sed "s/http 127.0.0.1 /http $host_ip /g" $cfg > $tmp_cfg 2>/dev/null
		proxychains4 -q -f $tmp_cfg $argv
		set -l last_status $status
		rm -f $tmp_cfg
		return $last_status
	else
		echo "Failed to resolve host.docker.internal"
		proxychains4 -q -f $cfg $argv
		return $status
	end
end
