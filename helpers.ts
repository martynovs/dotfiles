import { machine, platform as os_type, userInfo } from 'node:os';
import { argv } from 'node:process';

interface PackageVisitor {
    aptPackage(pkg: AptPackage): void;
    dnfPackage(pkg: DnfPackage): void;
    macPackage(pkg: MacPackage): void;
    brewPackage(pkg: BrewPackage): void;
    cargoPackage(pkg: CargoPackage): void;
    goPackage(pkg: GoPackage): void;
    nativePackage(pkg: NativePackage): void;
    linuxPackages(pkg: LinuxPackages): void;
    optionalPackages(pkg: OptionalPackages): void;
}

interface Package {
    apply: (PackageVisitor) => void;
}

class BrewPackage implements Package {
    name: string;
    brew_tap?: string;
    github_repo?: string;
    constructor(name: string) {
        this.name = name;
    }
    tap(tap: string): BrewPackage {
        this.brew_tap = tap;
        return this;
    }
    github(repo: string): BrewPackage {
        this.github_repo = repo;
        return this;
    }
    apply(visitor: PackageVisitor): void { visitor.brewPackage(this); }
}

class CargoPackage implements Package {
    name: string;
    cargo_bin: boolean;
    constructor(name: string, cargo_bin?: boolean) {
        this.name = name;
        this.cargo_bin = cargo_bin || false;
    }
    apply(visitor: PackageVisitor): void { visitor.cargoPackage(this); }
}

class GoPackage implements Package {
    repo: string;
    constructor(repo: string) { this.repo = repo; }
    apply(visitor: PackageVisitor): void { visitor.goPackage(this); }
}

class AptPackage implements Package {
    name: string;
    apt_ppa?: string;
    constructor(name: string) { this.name = name; }
    ppa(ppa: string): AptPackage { this.apt_ppa = ppa; return this; }
    apply(visitor: PackageVisitor): void { visitor.aptPackage(this); }
}

class DnfPackage implements Package {
    name: string;
    constructor(name: string) { this.name = name; }
    apply(visitor: PackageVisitor): void { visitor.dnfPackage(this); }
}

class MacPackage implements Package {
    name: string;
    brew_tap?: string;
    constructor(name: string) { this.name = name; }
    tap(tap: string): MacPackage { this.brew_tap = tap; return this; }
    apply(visitor: PackageVisitor): void { visitor.macPackage(this); }
}

class NativePackage implements Package {
    name: string;
    constructor(name: string) { this.name = name; }
    apply(visitor: PackageVisitor): void { visitor.nativePackage(this); }
}

class LinuxPackages implements Package {
    packages: Package[];
    constructor(...packages: Package[]) { this.packages = packages; }
    apply(visitor: PackageVisitor): void { visitor.linuxPackages(this); }
}

class OptionalPackages implements Package {
    name: string
    packages: Package[];
    constructor(name: string, ...packages: Package[]) {
        this.name = name;
        this.packages = packages;
    }
    apply(visitor: PackageVisitor): void { visitor.optionalPackages(this); }
}

export function apt(name: string): AptPackage { return new AptPackage(name); }
export function dnf(name: string): DnfPackage { return new DnfPackage(name); }
export function brew(name: string): BrewPackage { return new BrewPackage(name); }
export function cargo(name: string): CargoPackage { return new CargoPackage(name); }
export function cargobin(name: string): CargoPackage { return new CargoPackage(name, true); }
export function macos(name: string): MacPackage { return new MacPackage(name); }
export function native(name: string): NativePackage { return new NativePackage(name); }
export function go_pkg(name: string): GoPackage { return new GoPackage(name); }
export function linux(...packages: Package[]): LinuxPackages { return new LinuxPackages(...packages); }
export function optional(name: string, ...packages: Package[]): OptionalPackages { return new OptionalPackages(name, ...packages); }

export function printScript(...packages: Package[]) {
    const installer = getInstaller();
    packages.forEach(pkg => pkg.apply(installer));
    installer.printScript();
}

function getInstaller(): BasicInstaller {
    const os = os_type();
    const arch = machine();
    const root = userInfo().uid == 0;
    const platformPkgManager = argv[2];

    if (os === 'darwin') {
        return new MacInstaller();
    } else if (platformPkgManager === 'apt') {
        return new AptInstaller(root, arch);
    } else if (platformPkgManager === 'dnf') {
        return new DnfInstaller(root, arch);
    } else {
        throw "Unsupported package manager: " + platformPkgManager;
    }
}

class PackageSet {
    name: string;
    apt_ppa: string[] = [];
    brew_taps: string[] = [];
    brew_packages: string[] = [];
    linux_packages: string[] = [];
    cargo_binaries: string[] = [];
    cargo_packages: string[] = [];
    github_repos: string[] = [];
    go_packages: string[] = [];

    constructor(name: string) { this.name = name; }

    addBrew(name: string, tap?: string) {
        this.brew_packages.push(name);
        if (tap) this.brew_taps.push(tap);
    }

    addCargo(name: string, cargo_bin: boolean = false) {
        if (cargo_bin) { this.cargo_binaries.push(name); }
        else { this.cargo_packages.push(name); }
    }

    addAptPPA(ppa: string) { this.apt_ppa.push(ppa); }
    addLinux(name: string) { this.linux_packages.push(name); }
    addGithubRepo(repo: string) { this.github_repos.push(repo); }
    addGo(repo: string) { this.go_packages.push(repo); }
}

class BasicInstaller {
    packages: PackageSet;
    defaultPackageSet: PackageSet;
    optionalPackageSets: PackageSet[] = [];
    packageSetStack: PackageSet[] = [];

    constructor() {
        this.packages = this.defaultPackageSet = new PackageSet('');
        this.packageSetStack.push(this.defaultPackageSet);
    }

    optionalPackages(pkg: OptionalPackages): void {
        const optPackageSet = new PackageSet(pkg.name);
        this.optionalPackageSets.push(optPackageSet);
        this.packageSetStack.push(optPackageSet);
        this.packages = optPackageSet;
        pkg.packages.forEach(pkg => pkg.apply(this));
        this.packageSetStack.pop();
        this.packages = this.packageSetStack[this.packageSetStack.length - 1];
    }

    aptPackage(_pkg: AptPackage): void { }
    dnfPackage(_pkg: DnfPackage): void { }
    macPackage(_pkg: MacPackage): void { }
    platformPackage(_pkg: NativePackage): void { }

    cargoPackage(pkg: CargoPackage): void { this.packages.addCargo(pkg.name, pkg.cargo_bin); }
    brewPackage(pkg: BrewPackage): void { this.packages.addBrew(pkg.name, pkg.brew_tap); }
    goPackage(pkg: GoPackage): void { this.packages.addGo(pkg.repo); }

    printScript(): void {
        this.printPackageSetScript(this.defaultPackageSet);
        if (this.optionalPackageSets.length > 0) {
            let idx = 0;
            for (const pkgSet of this.optionalPackageSets) {
                const fn_name = `install_optional_packages_${idx++}`;
                p(`${fn_name}() {`);
                p('echo');
                p(`ask_confirmation "Do you want to install optional packages: '${pkgSet.name}'?" || return 0;`);
                this.printPackageSetScript(pkgSet);
                p('}');
                p(fn_name);
                p('');
            }
        }
    }

    printPackageSetScript(pkgSet: PackageSet): void {
        if (pkgSet.brew_packages.length > 0) {
            for (const tap of pkgSet.brew_taps) {
                print_cmd(`brew tap ${tap} || echo 'Failed to add tap ${tap}'`);
            }
            for (const pkg of pkgSet.brew_packages) {
                print_cmd(`brew install ${pkg} || echo 'Installation of ${pkg} failed'`);
            }
        }
        for (const bin of pkgSet.cargo_binaries) {
            print_cmd(`cargo binstall -y ${bin} || echo 'Failed to cargo binstall ${bin}'`);
        }
        for (const pkg of pkgSet.cargo_packages) {
            print_cmd(`cargo install --locked ${pkg} || echo 'Failed to install cargo package ${pkg}'`);
        }
        for (const pkg of pkgSet.go_packages) {
            let url = pkg;
            if (!url.includes('.')) { url = 'github.com/' + url; }
            if (!url.includes('@')) { url = url + '@latest'; }
            print_cmd(`go install ${url} || echo 'Failed to install go package ${pkg}'`);
        }
    }
}

class MacInstaller extends BasicInstaller implements PackageVisitor {
    macPackage(pkg: MacPackage): void { this.packages.addBrew(pkg.name, pkg.brew_tap); }
    nativePackage(pkg: NativePackage): void { this.packages.addBrew(pkg.name); }
    linuxPackages(_pkg: LinuxPackages): void { }
}

class LinuxInstaller extends BasicInstaller {
    install_cmd: string;
    github_file_ext: string;


    constructor(install_cmd: string, github_file_ext: string) {
        super();
        this.install_cmd = install_cmd;
        this.github_file_ext = github_file_ext;
    }

    nativePackage(pkg: NativePackage): void { this.packages.addLinux(pkg.name); }

    linuxPackages(pkgs: LinuxPackages): void { pkgs.packages.forEach(pkg => pkg.apply(this)); }

    brewPackage(pkg: BrewPackage): void {
        if (pkg.github_repo) { this.packages.addGithubRepo(pkg.github_repo); }
        else { super.brewPackage(pkg); }
    }

    printPackageSetScript(pkgSet: PackageSet): void {
        if (pkgSet.linux_packages.length > 0) {
            print_cmd(`${this.install_cmd} ${pkgSet.linux_packages.join(' ')}`);
        }
        super.printPackageSetScript(pkgSet);
        for (const repo of pkgSet.github_repos) {
            print_github_release_install(repo, this.install_cmd, this.github_file_ext);
        }
    }
}

class DnfInstaller extends LinuxInstaller implements PackageVisitor {
    constructor(root: boolean, arch: string) {
        super(
            root ? 'dnf install -y' : 'sudo dnf install -y',
            `${arch}.rpm`
        );
    }

    dnfPackage(pkg: DnfPackage): void { this.packages.addLinux(pkg.name); }
}

class AptInstaller extends LinuxInstaller implements PackageVisitor {
    add_ppa_cmd: string;

    constructor(root: boolean, arch: string) {
        super(
            root ? 'apt install -y' : 'sudo apt install -y',
            arch == 'aarch64' ? `arm64.deb` : `${arch}.deb`
        );
        this.add_ppa_cmd = root
            ? 'NONINTERACTIVE=1 add-apt-repository -y'
            : 'sudo NONINTERACTIVE=1 add-apt-repository -y';
    }

    aptPackage(pkg: AptPackage): void {
        if (pkg.apt_ppa) { this.packages.addAptPPA(pkg.apt_ppa); }
        this.packages.addLinux(pkg.name);
    }

    printPackageSetScript(pkgSet: PackageSet): void {
        if (pkgSet.apt_ppa.length > 0) {
            print_cmd(`${this.install_cmd} software-properties-common`);
            for (const ppa of pkgSet.apt_ppa) { print_cmd(`${this.add_ppa_cmd} ppa:${ppa}`); }
        }
        super.printPackageSetScript(pkgSet);
    }
}

function colorize(text: string, color: number = 32) {
    return `\\033[1m\\033[0;${color}m${text}\\033[0m`;
}

function p(...args: any[]) { console.log(...args); }

function colorized(text: string, color: number = 32) {
    p(`echo -e "${colorize(text, color)}"`);
}

function print_cmd(cmd: string): void {
    p('echo');
    colorized(cmd);
    p(cmd);
}

function print_github_release_install(repo: string, install_cmd: string, file_ext: string): void {
    const json_url = `https://api.github.com/repos/${repo}/releases/latest`;
    const grep_file = `grep -o 'https:.*${file_ext}'`;
    colorized(`Installing github ${repo} release`);
    colorized(`curl -s ${json_url} | grep 'browser_download_url' | ${grep_file}`);
    p(`package_url=$(curl -s ${json_url} | grep 'browser_download_url' | ${grep_file})`);
    p(`tempfile="$(mktemp).${file_ext}"`);
    colorized('Downloading package $package_url');
    p('curl -L -o $tempfile $package_url');
    print_cmd(`${install_cmd} $tempfile`);
    print_cmd('rm $tempfile');
}
