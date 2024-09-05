import { machine as os_arch, platform as os_type, userInfo } from 'node:os';
import process from 'node:process';
import path from 'node:path';
import util from 'node:util';

const arch = os_arch();
const sudo = userInfo().uid == 0 ? '' : 'sudo ';
const is_macos = os_type() === 'darwin';

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


export function printScript(...packages: Package[]) {
    const installer = getInstaller();
    packages.forEach(pkg => pkg.apply(installer));
    installer.printScript();
}

function getInstaller(): PackageInstaller {
    const { values: { pkg, dry, stub }, positionals: _ } = util.parseArgs({
        args: process.argv.slice(2),
        allowPositionals: true,
        options: {
            pkg: { type: 'string' },
            dry: { type: 'boolean' },
            stub: { type: 'string', short: 's' },
        }
    });

    if (stub && stub.length > 0) {
        return new StubInstaller({ dry }, stub);
    }

    if (is_macos) {
        return new MacInstaller({ dry });
    } else if (pkg === 'apt') {
        return new AptInstaller({ dry });
    } else if (pkg === 'dnf') {
        return new DnfInstaller({ dry });
    } else {
        throw "Unsupported package manager: " + pkg;
    }
}

type CmdPrint = (cmd: string, header?: string) => void;
function getCmdPrint(options: InstallerOptions): CmdPrint {
    const print_cmd: (cmd: string) => void = options.dry
        ? (cmd) => console.log(`echo "${cmd.replace(/"/g, '\\"')}"`)
        : (cmd) => console.log(cmd);
    return (cmd, description) => {
        if (description) {
            console.log(`echo -e "${colorize(description, 32)}"`);
        }
        print_cmd(cmd);
    };
}


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

interface PackageInstaller extends PackageVisitor {
    printScript(): void;
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

type InstallerOptions = {
    dry?: boolean;
}

abstract class BasicInstaller implements PackageVisitor {
    options: InstallerOptions;
    packages: PackageSet;
    defaultPackageSet: PackageSet;
    optionalPackageSets: PackageSet[] = [];
    packageSetStack: PackageSet[] = [];

    constructor(options: InstallerOptions) {
        this.options = options;
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
        const p: CmdPrint = getCmdPrint(this.options);
        this.printPackageSetScript(this.defaultPackageSet, p);
        if (this.optionalPackageSets.length > 0) {
            let idx = 0;
            for (const pkgSet of this.optionalPackageSets) {
                const fn_name = `install_optional_packages_${idx++}`;
                p(`${fn_name}() {`);
                p('echo');
                p(`ask_confirmation "Do you want to install optional packages: '${pkgSet.name}'?" || return 0;`);
                this.printPackageSetScript(pkgSet, p);
                p('}');
                p(fn_name);
                p('');
            }
        }
    }

    printPackageSetScript(pkgSet: PackageSet, p: CmdPrint): void {
        if (pkgSet.brew_packages.length > 0) {
            p('brew bundle --file=- <<EOF', 'Installing brew packages');
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
            p(`brew install "${pkg}" --build-from-source`, `install brew package from source: ${pkg}`);
        }
        if (pkgSet.brew_packages.length > 0 || pkgSet.brew_packages_from_source.length > 0) {
            p("brew cleanup -s", 'clean brew cache');
        }
        for (const pkg of pkgSet.npm_packages) {
            p(`npm install -g ${pkg}`, `install npm package: ${pkg}`);
        }
        for (const repo of pkgSet.eget_packages) {
            p(`eget ${repo} --to='~/.local/bin'`, `install eget package: ${repo}`);
        }
        for (const pkg of pkgSet.cargo_packages) {
            if (pkg.includes('github.com/')) {
                let url = pkg;
                if (!url.startsWith('http') && !url.startsWith('git@')) {
                    url = 'https://' + url;
                }
                p(`cargo install --git ${url}`, `install cargo package from git: ${url}`);
            } else {
                p(`cargo-binstall binstall -y ${pkg}`, `install cargo package: ${pkg}`);
            }
        }
        for (const pkg of pkgSet.go_packages) {
            let url = pkg;
            if (!url.includes('.')) { url = 'github.com/' + url; }
            if (!url.includes('@')) { url = url + '@latest'; }
            p(`go install ${url}`, `install go package: ${url}`);
        }
    }
}

class StubInstaller implements PackageInstaller {
    dir: string;
    options: InstallerOptions;
    packages: { tool: string, version?: string, bin?: string, desc?: string }[] = [];

    constructor(options: InstallerOptions, dir: string) {
        this.options = options;
        this.dir = dir;
    }

    printScript(): void {
        const p = getCmdPrint(this.options);
        for (const { tool, version, bin, desc } of this.packages) {
            const file = path.join(this.dir, `executable_${bin ?? tool}`);
            p(`cat > ${file} <<EOF`, bin ?? tool);
            p('#!/usr/bin/env -S mise tool-stub');
            if (desc) desc.split('\n').forEach(line => p(`# ${line}`));
            if (bin) p(`bin = ${bin}`);
            p(`tool = ${tool}`);
            p(`version = ${version ?? 'latest'}`);
            p('EOF');
        }
    }

    egetPackage(pkg: EgetPackage): void {
        this.packages.push({
            tool: `ubi:${pkg.repo}`,
            bin: pkg.repo.split('/').pop(),
        })
    }

    brewPackage(pkg: BrewPackage): void {
        if (pkg.github) {
            this.packages.push({
                tool: `ubi:${pkg.github}`,
                bin: pkg.github.split('/').pop(),
            })
        }
    }

    cargoPackage(pkg: CargoPackage): void {
    }

    goPackage(pkg: GoPackage): void {
    }

    aptPackage(_: AptPackage): void { }
    dnfPackage(_: DnfPackage): void { }
    npmPackage(_: NpmPackage): void { }
    nativePackage(_: NativePackage): void { }
    linuxPackages(_: LinuxPackages): void { }
    macosPackages(_: MacOsPackages): void { }
    optionalPackages(_: OptionalPackages): void { }
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


    constructor(options: InstallerOptions, install_cmd: string, github_file_ext: string) {
        super(options);
        this.install_cmd = install_cmd;
        this.github_file_ext = github_file_ext;
    }

    nativePackage(pkg: NativePackage): void { this.packages.addLinux(pkg.name); }

    linuxPackages(pkgs: LinuxPackages): void { pkgs.packages.forEach(pkg => pkg.apply(this)); }

    aptPackage(_pkg: AptPackage): void { }
    dnfPackage(_pkg: DnfPackage): void { }
    macosPackages(_pkg: MacOsPackages): void { }

    printPackageSetScript(pkgSet: PackageSet, p: CmdPrint): void {
        if (pkgSet.linux_packages.length > 0) {
            p(`${sudo}${this.install_cmd} ${pkgSet.linux_packages.join(' ')}`, 'install some packages');
        }
        super.printPackageSetScript(pkgSet, p);
    }
}

class DnfInstaller extends LinuxInstaller implements PackageVisitor {
    constructor(options: InstallerOptions) { super(options, 'dnf install -yq', `${arch}.rpm`); }

    dnfPackage(pkg: DnfPackage): void { this.packages.addLinux(pkg.name); }
}

class AptInstaller extends LinuxInstaller implements PackageVisitor {
    constructor(options: InstallerOptions) {
        super(options, 'apt install -y -qq', arch == 'aarch64' ? `arm64.deb` : `${arch}.deb`);
    }

    aptPackage(pkg: AptPackage): void {
        if (pkg.apt_ppa) { this.packages.addAptPPA(pkg.apt_ppa); }
        this.packages.addLinux(pkg.name);
    }

    printPackageSetScript(pkgSet: PackageSet, p: CmdPrint): void {
        if (pkgSet.apt_ppa.length > 0) {
            p(`${sudo}${this.install_cmd} software-properties-common`, 'install apt prerequisites');
            for (const ppa of pkgSet.apt_ppa) {
                p(`${sudo}NONINTERACTIVE=1 add-apt-repository -y ppa:${ppa}`, `add apt ppa: ${ppa}`);
            }
        }
        super.printPackageSetScript(pkgSet, p);
    }
}

function colorize(text: string, color: number = 32) {
    return `\\033[1m\\033[0;${color}m${text}\\033[0m`;
}
