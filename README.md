# Dotfiles

Shell configuration for Linux/containers and MacOS.


# Installation

```sh
curl -o- https://raw.githubusercontent.com/martynovs/dotfiles/HEAD/bootstrap | bash
```

For empty containers, like ones Apple uses, you first need to install curl.
In debian/ubuntu based containers run:
```sh
apt update && apt install -y curl git
```
In fedora based containers run:
```sh
dnf install -y curl git
```
