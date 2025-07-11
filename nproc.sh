#!/bin/sh

get_cpu_count_native() {
    os="$(uname -s)"
    count=""
    
    case "$os" in
        Darwin|FreeBSD|OpenBSD|NetBSD)
            count=$(sysctl -n hw.ncpu 2>/dev/null)
            ;;
        Linux)
            if [ -r /proc/cpuinfo ]; then
                count=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null)
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            count=$NUMBER_OF_PROCESSORS
            ;;
    esac
    
    if printf '%s\n' "$count" | grep -q '^[0-9][0-9]*$' && [ "$count" -gt 0 ]; then
        echo "$count"
        return 0
    fi

    if [ "$NPROC_SH_SHOW_ERROR_ON_FALLBACK" = "yes" ]; then
        echo "ERROR: nproc.sh failed to detect CPU count"
        exit 1
    fi
    
    return 1
}

try_nproc_executables() {
    script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0")"
    nproc_paths=""
    
    old_ifs="$IFS"
    IFS=':'
    for dir in $PATH; do
        IFS="$old_ifs"
        if [ -x "$dir/nproc" ]; then
            full_path="$(readlink -f "$dir/nproc" 2>/dev/null || realpath "$dir/nproc" 2>/dev/null || echo "$dir/nproc")"
            if [ "$full_path" != "$script_path" ]; then
                if [ -z "$nproc_paths" ]; then
                    nproc_paths="$dir/nproc"
                else
                    nproc_paths="$nproc_paths $dir/nproc"
                fi
            fi
        fi
    done
    IFS="$old_ifs"
    
    for nproc_path in $nproc_paths; do
        if [ -x "$nproc_path" ]; then
            result="$("$nproc_path" 2>/dev/null)"
            if printf '%s\n' "$result" | grep -q '^[0-9][0-9]*$' && [ "$result" -gt 0 ]; then
                echo "$result"
                return 0
            fi
        fi
    done
    
    if [ "$NPROC_SH_SHOW_ERROR_ON_FALLBACK" = "yes" ]; then
        echo "ERROR: nproc.sh failed to detect CPU count"
        exit 1
    fi
}

main() {
    cpu_count=""
    
    if cpu_count=$(get_cpu_count_native); then
        echo "$cpu_count"
        exit 0
    fi
    
    if cpu_count=$(try_nproc_executables); then
        echo "$cpu_count"
        exit 0
    fi
    
    if [ "$NPROC_SH_SHOW_ERROR_ON_FALLBACK" = "yes" ]; then
        echo "ERROR: nproc.sh failed to detect CPU count"
        exit 1
    fi

    return 1
}

main