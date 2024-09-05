import { machine as os_arch, platform as os_type, userInfo } from 'node:os';
import { argv } from 'node:process';


export function apt(name: string): AptPackage { return new AptPackage(name); }
export function dnf(name: string): DnfPackage { return new DnfPackage(name); }
export function npm(name: string): NpmPackage { return new NpmPackage(name); }
export function eget(repo: string): EgetPackage { return new EgetPackage(repo); }
export function brew(name: string): BrewPackage { return new BrewPackage(name); }
export function cargo(name: string): CargoPackage { return new CargoPackage(name); }
export function go_pkg(name: string): GoPackage { return new GoPackage(name); }
export function native(name: string): NativePackage { return new NativePackage(name); }
export function macos(...packages: Package[]): MacOsPackages { return new MacOsPackages(...packages); }
export function linux(...packages: Package[]): LinuxPackages { return new LinuxPackages(...packages); }
export function optional(name: string, ...packages: Package[]): OptionalPackages { return new OptionalPackages(name, ...packages); }


const arch = os_arch();
const sudo = userInfo().uid == 0 ? '' : 'sudo ';
const is_arm = arch === 'aarch64' || arch === 'arm64';
const is_macos = os_type() === 'darwin';
const pkgManager = argv[2];

interface PackageVisitor {
    aptPackage(pkg: AptPackage): void;
    dnfPackage(pkg: DnfPackage): void;
    npmPackage(pkg: NpmPackage): void;
    egetPackage(pkg: EgetPackage): void;
    brewPackage(pkg: BrewPackage): void;
    cargoPackage(pkg: CargoPackage): void;
    goPackage(pkg: GoPackage): void;
    nativePackage(pkg: NativePackage): void;
    macosPackages(pkg: MacOsPackages): void;
    linuxPackages(pkg: LinuxPackages): void;
    optionalPackages(pkg: OptionalPackages): void;
}

interface Package {
    apply: (visitor: PackageVisitor) => void;
}

class BrewPackage implements Package {
    name: string;
    brew_tap?: string;
    brew_cask?: boolean;
    npm_pkg?: string;
    github?: string;

    constructor(name: string) {
        let idx = name.lastIndexOf('/');
        if (idx > 0) {
            this.brew_tap = name.substring(0, idx);
            this.name = name.substring(idx + 1);
        } else {
            this.name = name;
        }
    }
    tap(tap: string): BrewPackage {
        this.brew_tap = tap;
        return this;
    }
    cask(): BrewPackage {
        this.brew_cask = true;
        return this;
    }
    npm(pkg: string): BrewPackage {
        this.npm_pkg = pkg;
        return this;
    }
    gh(repo: string): BrewPackage {
        this.github = repo;
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

class NpmPackage implements Package {
    name: string;
    constructor(name: string) { this.name = name; }
    apply(visitor: PackageVisitor): void { visitor.npmPackage(this); }
}

class EgetPackage implements Package {
    repo: string;
    constructor(repo: string) { this.repo = repo; }
    apply(visitor: PackageVisitor): void { visitor.egetPackage(this); }
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
    brew_casks: string[] = [];
    brew_packages: string[] = [];
    brew_packages_from_source: string[] = [];
    linux_packages: string[] = [];
    cargo_packages: string[] = [];
    eget_packages: string[] = [];
    npm_packages: string[] = [];
    go_packages: string[] = [];

    constructor(name: string) { this.name = name; }

    isEmpty() {
        return this.apt_ppa.length === 0 &&
            this.brew_taps.length === 0 &&
            this.brew_packages.length === 0 &&
            this.brew_packages_from_source.length === 0 &&
            this.linux_packages.length === 0 &&
            this.cargo_packages.length === 0 &&
            this.eget_packages.length === 0 &&
            this.npm_packages.length === 0 &&
            this.go_packages.length === 0;
    }

    addBrewPkgName(name: string) { this.brew_packages.push(name); }
    addBrewPkg(pkg: BrewPackage, should_build: boolean = false) {
        if (pkg.brew_tap) this.brew_taps.push(pkg.brew_tap);
        if (pkg.brew_cask) {
            this.brew_casks.push(pkg.name);
        } else {
            if (should_build) this.brew_packages_from_source.push(pkg.name);
            else this.brew_packages.push(pkg.name);
        }
    }

    addCargo(name: string) { this.cargo_packages.push(name); }
    addAptPPA(ppa: string) { this.apt_ppa.push(ppa); }
    addLinux(name: string) { this.linux_packages.push(name); }
    addEget(repo: string) { this.eget_packages.push(repo); }
    addNpm(name: string) { this.npm_packages.push(name); }
    addGo(repo: string) { this.go_packages.push(repo); }
}

abstract class BasicInstaller implements PackageVisitor {
    packages: PackageSet;
    defaultPackageSet: PackageSet;
    optionalPackageSets: PackageSet[] = [];
    packageSetStack: PackageSet[] = [];

    constructor() {
        this.packages = this.defaultPackageSet = new PackageSet('');
        this.packageSetStack.push(this.defaultPackageSet);
    }

    abstract aptPackage(pkg: AptPackage): void;
    abstract dnfPackage(pkg: DnfPackage): void;
    abstract nativePackage(pkg: NativePackage): void;
    abstract macosPackages(pkg: MacOsPackages): void;
    abstract linuxPackages(pkg: LinuxPackages): void;

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
    brewPackage(pkg: BrewPackage): void { this.packages.addBrewPkg(pkg); }
    egetPackage(pkg: EgetPackage): void { this.packages.addEget(pkg.repo); }
    npmPackage(pkg: NpmPackage): void { this.packages.addNpm(pkg.name); }
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
            for (const cask of pkgSet.brew_casks) {
                p(`cask "${cask}"`);
            }
            if (pkgSet.eget_packages.length > 0) {
                p('brew "eget"');
            }
            if (pkgSet.cargo_packages.length > 0 && !pkgSet.brew_packages.includes('cargo-binstall')) {
                p('brew "cargo-binstall"');
            }
            p('EOF');
        }
        for (const pkg of pkgSet.brew_packages_from_source) {
            print_cmd(`brew install "${pkg}" --build-from-source`, `install brew package from source: ${pkg}`);
        }
        if (pkgSet.brew_packages.length > 0 || pkgSet.brew_packages_from_source.length > 0) {
            print_cmd("brew cleanup -s", 'clean brew cache');
        }
        for (const pkg of pkgSet.npm_packages) {
            print_cmd(`npm install -g ${pkg}`, `install npm package: ${pkg}`);
        }
        for (const repo of pkgSet.eget_packages) {
            print_cmd(`eget ${repo} --to='~/.local/bin'`, `install eget package: ${repo}`);
        }
        for (const pkg of pkgSet.cargo_packages) {
            if (pkg.includes('github.com/')) {
                let url = pkg;
                if (!url.startsWith('http') && !url.startsWith('git@')) {
                    url = 'https://' + url;
                }
                print_cmd(`cargo install --git ${url}`, `install cargo package from git: ${url}`);
            } else {
                print_cmd(`cargo-binstall binstall -y ${pkg}`, `install cargo package: ${pkg}`);
            }
        }
        for (const pkg of pkgSet.go_packages) {
            let url = pkg;
            if (!url.includes('.')) { url = 'github.com/' + url; }
            if (!url.includes('@')) { url = url + '@latest'; }
            print_cmd(`go install ${url}`, `install go package: ${url}`);
        }
    }
}

class MacInstaller extends BasicInstaller implements PackageVisitor {
    macosPackages(pkg: MacOsPackages): void { pkg.packages.forEach(p => p.apply(this)); }
    nativePackage(pkg: NativePackage): void { this.packages.addBrewPkgName(pkg.name); }
    linuxPackages(_pkg: LinuxPackages): void { }
    aptPackage(_pkg: AptPackage): void { }
    dnfPackage(_pkg: DnfPackage): void { }
}

abstract class LinuxInstaller extends BasicInstaller {
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

    printPackageSetScript(pkgSet: PackageSet): void {
        if (pkgSet.linux_packages.length > 0) {
            print_cmd(`${sudo}${this.install_cmd} ${pkgSet.linux_packages.join(' ')}`, 'install some packages');
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
            print_cmd(`${sudo}${this.install_cmd} software-properties-common`, 'install apt prerequisites');
            for (const ppa of pkgSet.apt_ppa) {
                print_cmd(`${sudo}NONINTERACTIVE=1 add-apt-repository -y ppa:${ppa}`, `add apt ppa: ${ppa}`);
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

function print_cmd(cmd: string, description: string): void {
    p('echo');
    colorized(cmd);
    p(cmd);
}
