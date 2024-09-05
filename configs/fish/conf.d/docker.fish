if status is-interactive

    # type -q podman; and alias docker podman;
    # type -q podman; and type -q lima; alias docker podman.lima;

    if type -q docker
        abbr -a d docker
        abbr -a di "docker images"
        abbr -a dl "docker container ls"
        abbr -a dr "docker run -it --rm"
        abbr -a ds "docker stats --format 'table {{.ID}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.Name}}'"
        abbr -a dc docker-compose
        abbr -a dcr "docker-compose run --rm"
        abbr -a --position anywhere -- -amd "--platform linux/amd64"
        abbr -a --position anywhere -- -wd "-v $(pwd):/work -w /work"

        alias drw "docker run -it --rm -v $(pwd):/work -w /work"
        alias drw86 "docker run -it --rm --platform linux/amd64 -v $(pwd):/work -w /work"
    end

    if type -q container
        alias cr "container run -it --rm"
        alias crw "container run -it --rm -v $(pwd):/work -w /work"
    end

end
