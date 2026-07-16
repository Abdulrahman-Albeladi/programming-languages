#!/usr/bin/env bash
# Regression checks for the prob2_wc command-line program.

set -u

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_root"

test_dir="test-results"
actual_file="$test_dir/prob2_output_actual.tmp"
expected_file="$test_dir/prob2_output_expected.tmp"

printf '\nBuilding programs\n'
if ! cargo build; then
    printf 'Build failed.\n' >&2
    exit 1
fi

mkdir -p "$test_dir"

commands=(
    "test-data/bruce.txt"
    "test-data/gettysburg.txt.txt"
    "test-data/dijkstra.txt"
    "test-data/howl.txt"
    "test-data/empty.txt"
    ""
    "test-data/no-such-file.txt"
)

printf 'Running sample cases\n'
{
    for filename in "${commands[@]}"; do
        if [[ -n "$filename" ]]; then
            printf '>> cargo run --quiet --bin prob2_wc -- %s\n' "$filename"
            cargo run --quiet --bin prob2_wc -- "$filename"
        else
            printf '>> cargo run --quiet --bin prob2_wc --\n'
            cargo run --quiet --bin prob2_wc --
        fi
        printf '\n'
    done
} >"$actual_file" 2>&1

cat >"$expected_file" <<'EOF'
>> cargo run --quiet --bin prob2_wc -- test-data/bruce.txt
   2   17   91 test-data/bruce.txt

>> cargo run --quiet --bin prob2_wc -- test-data/gettysburg.txt.txt
Couldn't open file test-data/gettysburg.txt.txt: No such file or directory (os error 2)

>> cargo run --quiet --bin prob2_wc -- test-data/dijkstra.txt
  40  271 1633 test-data/dijkstra.txt

>> cargo run --quiet --bin prob2_wc -- test-data/howl.txt
 145 2909 17521 test-data/howl.txt

>> cargo run --quiet --bin prob2_wc -- test-data/empty.txt
   0    0    0 test-data/empty.txt

>> cargo run --quiet --bin prob2_wc --
usage: target/debug/prob2_wc <filename>

>> cargo run --quiet --bin prob2_wc -- test-data/no-such-file.txt
Couldn't open file test-data/no-such-file.txt: No such file or directory (os error 2)

EOF

printf 'Comparing expected and actual output\n'
if diff -y -bB "$expected_file" "$actual_file"; then
    printf 'Output matches the recorded regression cases.\n'
else
    printf 'Output differs from the recorded regression cases.\n' >&2
    exit 1
fi
