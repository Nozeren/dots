#!/usr/bin/env bash
# CPU and memory use for the tmux status bar, on Linux and macOS: stats.sh cpu|mem
case "$(uname -s)-$1" in
    Linux-mem)
        awk '/^MemTotal/ {t=$2} /^MemAvailable/ {a=$2} END {printf "%d%%", (t-a)*100/t}' /proc/meminfo
        ;;
    Linux-cpu)
        # Usage since the previous call (tmux calls this every status-interval seconds)
        state="${XDG_RUNTIME_DIR:-/tmp}/tmux-stats-cpu"
        read -r _ u n s i w q sq st _ < /proc/stat
        total=$((u + n + s + i + w + q + sq + st)) idle=$((i + w))
        read -r ptotal pidle 2>/dev/null < "$state" || { ptotal=0; pidle=0; }
        echo "$total $idle" > "$state"
        dt=$((total - ptotal)) di=$((idle - pidle))
        if [ "$ptotal" -eq 0 ] || [ "$dt" -le 0 ]; then echo "0.0%"; exit; fi
        awk -v dt="$dt" -v di="$di" 'BEGIN {printf "%.1f%%", (dt - di) * 100 / dt}'
        ;;
    Darwin-mem)
        # Used = active + wired + compressed pages, like Activity Monitor's "Memory Used"
        page=$(sysctl -n hw.pagesize) total=$(sysctl -n hw.memsize)
        vm_stat | awk -v page="$page" -v total="$total" '
            /Pages active/ {a=$3} /Pages wired/ {w=$4} /occupied by compressor/ {c=$5}
            END {printf "%d%%", (a + w + c) * page * 100 / total}'
        ;;
    Darwin-cpu)
        ps -A -o %cpu= | awk -v cores="$(sysctl -n hw.ncpu)" '{s += $1} END {printf "%.1f%%", s / cores}'
        ;;
esac
