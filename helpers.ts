import { machine, platform, userInfo } from 'node:os';
import { argv } from 'node:process';

class Package {
    cargo_pkg?: string;
    cargo_bin?: string;
    brew_name?: string;
    brew_tap?: string;
    mac_only?: boolean;
    apt_name?: string;
    apt_ppa?: string;
    dnf_name?: string;
    gh_repo?: string;
    go_repo?: string;

    mac(): Package { this.mac_only = true; return this; }
    apt(name: string): Package { this.apt_name = name; return this; }
    ppa(name: string): Package { this.apt_ppa = name; return this; }
    dnf(name: string | undefined): Package { this.dnf_name = name; return this; }
    tap(name: string): Package { this.brew_tap = name; return this; }
    brew(name: string): Package { this.brew_name = name; return this; }
    github(repo: string): Package { this.gh_repo = repo; return this; }
    go_pkg(name: string): Package { this.go_repo = name; return this; }
    cargo(name: string): Package { this.cargo_pkg = name; return this; }
    cargob(name: string): Package { this.cargo_bin = name; return this; }
}

export function apt(name: string): Package { return new Package().apt(name); }
export function dnf(name: string): Package { return new Package().dnf(name); }
export function brew(name: string): Package { return new Package().brew(name); }
export function cargo(name: string): Package { return new Package().cargo(name); }
export function cargobin(name: string): Package { return new Package().cargob(name); }
export function macos(name: string): Package { return new Package().brew(name).mac(); }
export function linux(name: string): Package { return new Package().apt(name).dnf(name); }
export function universal(name: string): Package { return new Package().apt(name).dnf(name).brew(name); }
export function github(name: string): Package { return new Package().github(name); }
export function go_pkg(name: string): Package { return new Package().go_pkg(name); }


export function printScript(...packages: Package[]) {
    const os = platform();
    const arch = machine();
    const root = userInfo().uid == 0;
    const is_macos = os === 'darwin';
    const platformPkgManager = argv[2];
    const platformInstallCmd = root
        ? platformPkgManager + ' install -y'
        : 'sudo ' + platformPkgManager + ' install -y';

    var gh_repos: string[] = [];
    var go_repos: string[] = [];
    var brew_taps: string[] = [];
    var apt_ppa: string[] = [];
    var brew_packages: string[] = [];
    var cargo_packages: string[] = [];
    var cargo_binaries: string[] = [];
    var platform_packages: string[] = [];

    packages.forEach(pkg => {
        if (pkg.mac_only || (pkg.brew_name && is_macos)) {
            if (!is_macos) return;
            if (pkg.brew_name) brew_packages.push(pkg.brew_name);
            if (pkg.brew_tap) brew_taps.push(pkg.brew_tap);
        } else if (pkg.cargo_pkg) {
            cargo_packages.push(pkg.cargo_pkg);
        } else if (pkg.cargo_bin) {
            cargo_binaries.push(pkg.cargo_bin);
        } else if (pkg.apt_name && platformPkgManager == 'apt') {
            platform_packages.push(pkg.apt_name);
            if (pkg.apt_ppa) apt_ppa.push(pkg.apt_ppa);
        } else if (pkg.dnf_name && platformPkgManager == 'dnf') {
            platform_packages.push(pkg.dnf_name);
        } else if (pkg.go_repo) {
            go_repos.push(pkg.go_repo);
        } else if (pkg.gh_repo) {
            gh_repos.push(pkg.gh_repo);
        } else if (pkg.brew_name) {
            brew_packages.push(pkg.brew_name);
        }
    });

    const colorized = (text: string, color: number = 32) =>
        console.log(`echo -e "\\033[1m\\033[0;${color}m${text}\\033[0m"`);

    function run(...args: string[]): void {
        const cmd = args.join(' ');
        console.log('echo');
        colorized(cmd);
        console.log(cmd);
    }

    if (platform_packages.length > 0) {
        if (platformPkgManager == 'apt' && apt_ppa.length > 0) {
            run('NONINTERACTIVE=1 apt install -y software-properties-common');
            for (const ppa of apt_ppa) {
                run(`NONINTERACTIVE=1 add-apt-repository ppa:${ppa}`);
            }
        }
        if (platformPkgManager) {
            run(platformInstallCmd, ...platform_packages);
        } else {
            console.error('Unknown package manager for platform packages.');
        }
    }

    if (brew_packages.length > 0) {
        for (const tap of brew_taps) {
            run('brew tap', tap);
        }
        for (const pkg of brew_packages) {
            run('brew install', pkg);
        }
    }

    for (const pkg of cargo_packages) {
        run('cargo install --locked', pkg);
    }

    for (const bin of cargo_binaries) {
        run('cargo binstall -y', bin);
    }

    for (const repo of go_repos) {
        let url = repo;
        if (!URL.parse(url)?.host?.includes('.')) {
            url = 'github.com/' + url;
        }
        if (!url.includes('@')) {
            url = url + '@latest';
        }
        run('go install', url);
    }

    if (gh_repos.length > 0) {
        const file_ext = platformPkgManager == 'apt' ? 'deb' : platformPkgManager == 'dnf' ? 'rpm' : 'tar.gz';
        const grep_file = arch == 'aarch64' && platformPkgManager == 'apt'
            ? `https:.*arm64.${file_ext}`
            : `https:.*${arch}.${file_ext}`;
        for (const repo of gh_repos) {
            const json_url = `https://api.github.com/repos/${repo}/releases/latest`;
            console.log('echo');
            colorized(`Installing ${repo}`);
            colorized(`curl -s ${json_url} | grep 'browser_download_url' | grep -o '${grep_file}'`);
            console.log(`package_url=$(curl -s ${json_url} | grep 'browser_download_url' | grep -o '${grep_file}')`);
            console.log(`tempfile="$(mktemp).${file_ext}"`);
            colorized(`curl -L -o $tempfile $package_url`);
            console.log('curl -L -o $tempfile $package_url');
            colorized(`${platformInstallCmd} $tempfile`);
            console.log(`${platformInstallCmd} $tempfile`);
            console.log('rm $tempfile');
        }
    }
}
