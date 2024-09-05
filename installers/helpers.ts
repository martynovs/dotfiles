import { machine as os_arch, platform as os_type, userInfo } from 'node:os';
import { argv } from 'node:process';

const arch = os_arch();
const sudo = userInfo().uid == 0 ? '' : 'sudo ';
const is_arm = arch === 'aarch64' || arch === 'arm64';
const is_macos = os_type() === 'darwin';
const pkgManager = argv[2];

interface PackageVisitor {
    aptPackage(pkg: AptPackage): void;
    dnfPackage(pkg: DnfPackage): void;
    brewPackage(pkg: BrewPackage): void;
    cargoPackage(pkg: CargoPackage): void;
    goPackage(pkg: GoPackage): void;
    nativePackage(pkg: NativePackage): void;
    macosPackages(pkg: MacOsPackages): void;
    linuxPackages(pkg: LinuxPackages): void;
    optionalPackages(pkg: OptionalPackages): void;
}

interface Package {
    apply: (PackageVisitor) => void;
}

class BrewPackage implements Package {
    name: string;
    brew_tap?: string;
    sans_linux_arm_binary?: boolean;
    constructor(name: string) {
        this.name = name;
    }
    tap(tap: string): BrewPackage {
        this.brew_tap = tap;
        return this;
    }
    sans_arm(): Package {
        this.sans_linux_arm_binary = true;
        return this;
    }
    apply(visitor: PackageVisitor): void { visitor.brewPackage(this); }
}

class CargoPackage implements Package {
    name: string;
    constructor(name: string) { this.name = name; }
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

class MacOsPackages implements Package {
    packages: Package[];
    constructor(...packages: Package[]) { this.packages = packages; }
    apply(visitor: PackageVisitor): void { visitor.macosPackages(this); }
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
export function go_pkg(name: string): GoPackage { return new GoPackage(name); }
export function native(name: string): NativePackage { return new NativePackage(name); }
export function macos(...packages: Package[]): MacOsPackages { return new MacOsPackages(...packages); }
export function linux(...packages: Package[]): LinuxPackages { return new LinuxPackages(...packages); }
export function optional(name: string, ...packages: Package[]): OptionalPackages { return new OptionalPackages(name, ...packages); }

export function printScript(...packages: Package[]) {
    const installer = getInstaller();
    packages.forEach(pkg => pkg.apply(installer));
    installer.printScript();
}

function getInstaller(): BasicInstaller {
    if (is_macos) {
        return new MacInstaller();
    } else if (pkgManager === 'apt') {
        return new AptInstaller();
    } else if (pkgManager === 'dnf') {
        return new DnfInstaller();
    } else {
        throw "Unsupported package manager: " + pkgManager;
    }
}

class PackageSet {
    name: string;
    apt_ppa: string[] = [];
    brew_taps: string[] = [];
    brew_packages: string[] = [];
    brew_packages_from_source: string[] = [];
    linux_packages: string[] = [];
    cargo_packages: string[] = [];
    go_packages: string[] = [];

    constructor(name: string) { this.name = name; }

    isEmpty() {
        return this.apt_ppa.length === 0 &&
            this.brew_taps.length === 0 &&
            this.brew_packages.length === 0 &&
            this.brew_packages_from_source.length === 0 &&
            this.linux_packages.length === 0 &&
            this.cargo_packages.length === 0 &&
            this.go_packages.length === 0;
    }

    addBrew(name: string, should_build: boolean = false, tap?: string) {
        if (should_build) this.brew_packages_from_source.push(name);
        else this.brew_packages.push(name);
        if (tap) this.brew_taps.push(tap);
    }

    addCargo(name: string) { this.cargo_packages.push(name); }
    addAptPPA(ppa: string) { this.apt_ppa.push(ppa); }
    addLinux(name: string) { this.linux_packages.push(name); }
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
        if (optPackageSet.isEmpty()) this.optionalPackageSets.pop();
        this.packages = this.packageSetStack[this.packageSetStack.length - 1];
    }

    cargoPackage(pkg: CargoPackage): void { this.packages.addCargo(pkg.name); }
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
            p('echo');
            colorized('Installing brew packages');
            p('brew bundle --file=- <<EOF');
            for (const tap of pkgSet.brew_taps) {
                p(`tap "${tap}"`);
            }
            for (const pkg of pkgSet.brew_packages) {
                p(`brew "${pkg}"`);
            }
            if (pkgSet.cargo_packages.length > 0 && !pkgSet.brew_packages.includes('cargo-binstall')) {
                p(`brew "cargo-binstall"`);
            }
            p('EOF');
        }
        for (const pkg of pkgSet.brew_packages_from_source) {
            print_cmd(`brew install "${pkg}" --build-from-source`);
        }
        if (pkgSet.brew_packages.length > 0 || pkgSet.brew_packages_from_source.length > 0) {
            print_cmd("brew cleanup -s");
        }
        for (const pkg of pkgSet.cargo_packages) {
            print_cmd(`cargo-binstall binstall -y ${pkg} || echo 'Failed cargo binstall ${pkg}'`);
        }
        for (const pkg of pkgSet.go_packages) {
            let url = pkg;
            if (!url.includes('.')) { url = 'github.com/' + url; }
            if (!url.includes('@')) { url = url + '@latest'; }
            print_cmd(`go install ${url} || echo 'Failed go install ${pkg}'`);
        }
    }
}

class MacInstaller extends BasicInstaller implements PackageVisitor {
    macosPackages(pkg: MacOsPackages): void { pkg.packages.forEach(p => p.apply(this)); }
    nativePackage(pkg: NativePackage): void { this.packages.addBrew(pkg.name); }
    linuxPackages(_pkg: LinuxPackages): void { }
    aptPackage(_pkg: AptPackage): void { }
    dnfPackage(_pkg: DnfPackage): void { }
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

    aptPackage(_pkg: AptPackage): void { }
    dnfPackage(_pkg: DnfPackage): void { }
    macosPackages(_pkg: MacOsPackages): void { }

    brewPackage(pkg: BrewPackage): void {
        const shouldBuild = is_arm && pkg.sans_linux_arm_binary;
        this.packages.addBrew(pkg.name, shouldBuild, pkg.brew_tap);
    }

    printPackageSetScript(pkgSet: PackageSet): void {
        if (pkgSet.linux_packages.length > 0) {
            print_cmd(`${sudo}${this.install_cmd} ${pkgSet.linux_packages.join(' ')}`);
        }
        super.printPackageSetScript(pkgSet);
    }
}

class DnfInstaller extends LinuxInstaller implements PackageVisitor {
    constructor() { super('dnf install -yq', `${arch}.rpm`); }

    dnfPackage(pkg: DnfPackage): void { this.packages.addLinux(pkg.name); }
}

class AptInstaller extends LinuxInstaller implements PackageVisitor {
    constructor() {
        super('apt install -y -qq', arch == 'aarch64' ? `arm64.deb` : `${arch}.deb`);
    }

    aptPackage(pkg: AptPackage): void {
        if (pkg.apt_ppa) { this.packages.addAptPPA(pkg.apt_ppa); }
        this.packages.addLinux(pkg.name);
    }

    printPackageSetScript(pkgSet: PackageSet): void {
        if (pkgSet.apt_ppa.length > 0) {
            print_cmd(`${sudo}${this.install_cmd} software-properties-common`);
            for (const ppa of pkgSet.apt_ppa) {
                print_cmd(`${sudo}NONINTERACTIVE=1 add-apt-repository -y ppa:${ppa}`);
            }
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
    print_cmd(`${sudo}${install_cmd} $tempfile`);
    print_cmd('rm $tempfile');
}
