status is-interactive || exit

# type -q podman; and alias docker podman;
# type -q podman; and type -q lima; alias docker podman.lima;

type -q dcv; and alias dd dcv

type -q tart; and alias vm tart
type -q tart; and alias vm-create "tart create --linux --disk-format asif"

if type -q docker
    abbr -a d docker
    abbr -a di "docker images"
    abbr -a dl "docker container ls"
    abbr -a dr "docker run -it --rm"
    abbr -a ds "docker stats --format 'table {{.ID}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.Name}}'"
    abbr -a dc docker-compose
    abbr -a dcr "docker-compose run --rm"
    abbr -a --position anywhere -- -amd "--platform linux/amd64"
    abbr -a --position anywhere -- -wd "-v (pwd):/work -w /work"

    alias drw "docker run -it --rm -v (pwd):/work -w /work"

    function _docker_select_container
        docker ps --format 'table {{.Names}},{{.Image}}' | gum table --height 10 -r 1
    end

    function _docker_select_image
        docker images --format 'table {{.Repository}}:{{.Tag}},{{.ID}}' | gum table --height 15 -r 2
    end

    function _docker_remove_images_by_pattern --argument pattern
        # Interpret + as a wildcard so the caller can avoid shell globbing
        set -l glob (string replace -a '+' '*' $pattern)
        set -l matched 0
        for line in (docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}')
            set -l entry (string split --max 2 ' ' $line)
            set -l repo_tag $entry[1]
            set -l id $entry[2]
            if string match -q -- $glob $repo_tag
                docker rmi -f $id
                set matched 1
            end
        end
        if test $matched -eq 0
            echo "No docker images match $pattern"
        end
    end

    function drm --description 'Remove docker image(s) [interactively]' --argument image_names
        if test (count $argv) -gt 0
            for image in $argv
                if string match -q -- '*+*' $image
                    _docker_remove_images_by_pattern $image
                else
                    docker rmi -f $image
                end
            end
        else
            echo 'Select image:'
            set image (_docker_select_image)
            if test -n "$image"
                docker rmi -f $image
            end
        end
    end

    function dx --description 'Execute bash in a [selected] docker container' --argument container
        if test (count $argv) -gt 1
            echo 'Usage: dx [container]' >&2
            return 1
        end

        if test (count $argv) -gt 0
            docker exec -it $argv bash
        else
            echo 'Select container:'
            set container (_docker_select_container)
            if test -n "$container"
                docker exec -it $container bash
            end
        end
    end
end

if type -q dive
    function dv --description 'Inspect a [selected] docker image with dive' --argument image
        if test (count $argv) -gt 1
            echo 'Usage: dv [image]' >&2
            return 1
        end

        if test (count $argv) -gt 0
            dive $argv
        else
            echo 'Select image:'
            set image (_docker_select_image)
            if test -n "$image"
                dive $image
            end
        end
    end
end
