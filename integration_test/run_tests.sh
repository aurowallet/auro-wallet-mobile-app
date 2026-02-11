#!/bin/zsh

# Auro Wallet Integration Test Runner
#
# Usage:
#   ./run_tests.sh [options] [device_id] [test_order]
#
# Options:
#   -h, --help      Show help
#   --no-pub        Skip dependency resolution
#   --no-uninstall  Keep app installed between tests
#
# If test_order is omitted, an interactive menu is shown.
# Device ID is auto-detected if omitted (or read from .test_config).
#
# Config file: .test_config (optional, in project root)
#   DEVICE_ID=<id>
#   NO_PUB=true
#   DEFAULT_ORDER=1234

set -e

# ── Signal handling ─────────────────────────────────────────────
DRIVE_PID=""
WATCHDOG_PID=""
TAIL_PID=""
LOG_DIR=$(mktemp -d)
cleanup_children() {
    [ -n "$DRIVE_PID" ]    && kill "$DRIVE_PID"    2>/dev/null || true
    [ -n "$WATCHDOG_PID" ] && kill "$WATCHDOG_PID" 2>/dev/null || true
    [ -n "$TAIL_PID" ]     && kill "$TAIL_PID"     2>/dev/null || true
    DRIVE_PID=""; WATCHDOG_PID=""; TAIL_PID=""
}
trap 'cleanup_children; rm -rf "$LOG_DIR"; exit 0'   PIPE
trap 'cleanup_children; rm -rf "$LOG_DIR"; exit 130' INT
trap 'cleanup_children; rm -rf "$LOG_DIR"; exit 143' TERM

# macOS bash 3.2 builtins (echo/printf) silently ignore broken pipes.
# Use an external command to reliably detect broken stdout.
_check_pipe() {
    /usr/bin/printf '\r' 2>/dev/null || { cleanup_children; exit 0; }
}

# ── Proxy fix ─────────────────────────────────────────────────────
export NO_PROXY="${NO_PROXY:-}localhost,127.0.0.1,::1"
export no_proxy="${no_proxy:-}localhost,127.0.0.1,::1"

# ── Colors ────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Project directory ─────────────────────────────────────────────
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

# ── Load config file ─────────────────────────────────────────────
CONFIG_FILE="$PROJECT_DIR/.test_config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# ── Parse arguments ──────────────────────────────────────────────
ARG_DEVICE_ID=""
ARG_TEST_ORDER=""
OPT_NO_PUB="${NO_PUB:-false}"
OPT_NO_UNINSTALL="false"
POSITIONAL_ARGS=()

for arg in "$@"; do
    case "$arg" in
        -h|--help)
            cat <<'EOF'
Auro Wallet Integration Test Runner

Usage: ./run_tests.sh [options] [device_id] [test_order]

Options:
  -h, --help      Show this help
  --no-pub        Skip flutter pub get (faster restarts)
  --no-uninstall  Keep app installed between flow 1-4 tests

Arguments:
  device_id       Target device/simulator ID (auto-detected if omitted)
  test_order      Digit string selecting flows, e.g. 1234, 5, 12345
                  If omitted, an interactive menu is shown.

Test flows:
  1  Create wallet       (flow1_create_test.dart)
  2  Mnemonic import     (flow2_mnemonic_test.dart)
  3  Private key import  (flow3_privatekey_test.dart)
  4  Keystore import     (flow4_keystore_test.dart)
  5  Multi-wallet        (flow5_multiwallet_test.dart) — keeps existing wallet
  6  Quick wallet setup   (flow6_setup_wallets_test.dart) — import all, no uninstall

Config file (.test_config in project root):
  DEVICE_ID=<id>           Persist device ID
  NO_PUB=true              Always skip pub get
  DEFAULT_ORDER=1234       Default test order for interactive mode
  TEST_IDLE_TIMEOUT=120    Max idle seconds (no output) before kill (default: 120)

Examples:
  ./run_tests.sh                              # interactive menu
  ./run_tests.sh DEVICE_ID                    # interactive, specific device
  ./run_tests.sh DEVICE_ID 1234              # flows 1-4
  ./run_tests.sh DEVICE_ID 5 --no-pub        # multi-wallet, skip pub get
  ./run_tests.sh --no-pub 12345              # all flows, skip pub get
EOF
            exit 0
            ;;
        --no-pub)
            OPT_NO_PUB="true"
            ;;
        --no-uninstall)
            OPT_NO_UNINSTALL="true"
            ;;
        *)
            POSITIONAL_ARGS+=("$arg")
            ;;
    esac
done

# Smart argument parsing:
#   0 args → use config DEVICE_ID, interactive test selection
#   1 arg  → if looks like test order (digits 1-5) and config has DEVICE_ID → treat as test_order
#             otherwise → treat as device_id
#   2 args → first is device_id, second is test_order
if [ ${#POSITIONAL_ARGS[@]} -eq 0 ]; then
    : # use config or auto-detect
elif [ ${#POSITIONAL_ARGS[@]} -eq 1 ]; then
    local_arg="${POSITIONAL_ARGS[0]}"
    # if arg is digits 1-5 only, length<=5, and config has DEVICE_ID → treat as test order
    if [[ "$local_arg" =~ ^[1-6]+$ ]] && [ ${#local_arg} -le 6 ] && [ -n "${DEVICE_ID:-}" ]; then
        ARG_TEST_ORDER="$local_arg"
    else
        ARG_DEVICE_ID="$local_arg"
    fi
elif [ ${#POSITIONAL_ARGS[@]} -ge 2 ]; then
    ARG_DEVICE_ID="${POSITIONAL_ARGS[0]}"
    ARG_TEST_ORDER="${POSITIONAL_ARGS[1]}"
fi

# Resolve: CLI args > config > auto-detect
DEVICE_ID="${ARG_DEVICE_ID:-${DEVICE_ID:-}}"
TEST_ORDER="${ARG_TEST_ORDER:-}"
FLUTTER_EXTRA=""
if [ "$OPT_NO_PUB" = "true" ]; then
    FLUTTER_EXTRA="--no-pub"
fi

# ── Test metadata ─────────────────────────────────────────────────
get_test_file() {
    case "$1" in
        1) echo "flow1_create_test.dart" ;;
        2) echo "flow2_mnemonic_test.dart" ;;
        3) echo "flow3_privatekey_test.dart" ;;
        4) echo "flow4_keystore_test.dart" ;;
        5) echo "flow5_multiwallet_test.dart" ;;
        6) echo "flow6_setup_wallets_test.dart" ;;
        *) echo "" ;;
    esac
}

get_test_name() {
    case "$1" in
        1) echo "Create Wallet (Mnemonic)" ;;
        2) echo "Restore Wallet (Mnemonic)" ;;
        3) echo "Import Wallet (Private Key)" ;;
        4) echo "Import Wallet (Keystore)" ;;
        5) echo "Multi-Wallet Tests" ;;
        6) echo "Quick Wallet Setup" ;;
        *) echo "Unknown test" ;;
    esac
}

# ── Result tracking ───────────────────────────────────────────────
RESULT_1="SKIP"; RESULT_2="SKIP"; RESULT_3="SKIP"; RESULT_4="SKIP"; RESULT_5="SKIP"; RESULT_6="SKIP"

set_result() {
    case "$1" in
        1) RESULT_1="$2" ;; 2) RESULT_2="$2" ;; 3) RESULT_3="$2" ;;
        4) RESULT_4="$2" ;; 5) RESULT_5="$2" ;; 6) RESULT_6="$2" ;;
    esac
}

get_result() {
    case "$1" in
        1) echo "$RESULT_1" ;; 2) echo "$RESULT_2" ;; 3) echo "$RESULT_3" ;;
        4) echo "$RESULT_4" ;; 5) echo "$RESULT_5" ;; 6) echo "$RESULT_6" ;; *) echo "SKIP" ;;
    esac
}

# ── Banner ────────────────────────────────────────────────────────
print_banner() {
    echo ""
    echo -e "${CYAN}${BOLD}  ╔═══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}  ║   Auro Wallet · Integration Test Runner   ║${NC}"
    echo -e "${CYAN}${BOLD}  ╚═══════════════════════════════════════════╝${NC}"
    echo ""
}

# ── Device detection ──────────────────────────────────────────────
detect_device() {
    # Use configured device ID (flutter drive will error if device doesn't exist)
    if [ -n "$DEVICE_ID" ]; then
        echo -e "  ${DIM}Device:${NC} $DEVICE_ID"
        return
    fi

    echo -e "  ${YELLOW}Auto-detecting device...${NC}"

    # iOS simulator (fast, no flutter devices dependency)
    DEVICE_ID=$(xcrun simctl list devices booted -j 2>/dev/null \
        | grep -o '"udid" : "[^"]*"' | head -1 | cut -d'"' -f4) || true

    # Android (fast, using adb)
    if [ -z "$DEVICE_ID" ]; then
        DEVICE_ID=$(adb devices 2>/dev/null \
            | grep -E '\tdevice$' | head -1 | awk '{print $1}') || true
    fi

    if [ -z "$DEVICE_ID" ]; then
        echo -e "  ${RED}No device detected${NC}"
        echo -e "  ${DIM}Ensure iOS simulator is running or Android device is connected${NC}"
        echo ""
        echo "  Verify with:"
        echo "    iOS:     xcrun simctl list devices booted"
        echo "    Android: adb devices"
        exit 1
    fi

    echo -e "  ${GREEN}Device:${NC} $DEVICE_ID"
}

# ── Interactive menu ──────────────────────────────────────────────
show_menu() {
    echo -e "  ${BOLD}Select tests to run:${NC}"
    echo ""
    echo -e "    ${BOLD}1${NC}  Create Wallet          ${DIM}(flow1 — uninstall first)${NC}"
    echo -e "    ${BOLD}2${NC}  Restore (Mnemonic)     ${DIM}(flow2 — uninstall first)${NC}"
    echo -e "    ${BOLD}3${NC}  Import (Private Key)   ${DIM}(flow3 — uninstall first)${NC}"
    echo -e "    ${BOLD}4${NC}  Import (Keystore)      ${DIM}(flow4 — uninstall first)${NC}"
    echo -e "    ${BOLD}5${NC}  Multi-Wallet Tests     ${DIM}(flow5 — keep wallet)${NC}"
    echo -e "    ${BOLD}6${NC}  Quick Wallet Setup     ${DIM}(flow6 — import all, no uninstall)${NC}"
    echo ""
    echo -e "    ${BOLD}a${NC}  All (1-5)              ${DIM}default${NC}"
    echo ""

    local default_order="${DEFAULT_ORDER:-12345}"
    printf "  Enter selection [${default_order}]: "
    # Read from terminal, ensure pipe calls can still interact
    if [ -t 0 ]; then
        read -r selection
    else
        read -r selection < /dev/tty 2>/dev/null || selection=""
    fi

    # Empty input uses default
    if [ -z "$selection" ]; then
        selection="$default_order"
    fi

    case "$selection" in
        a|A) TEST_ORDER="12345" ;;
        *)   TEST_ORDER="$selection" ;;
    esac
}

# ── Uninstall app ─────────────────────────────────────────────────
uninstall_app() {
    if [ "$OPT_NO_UNINSTALL" = "true" ]; then
        echo -e "  ${DIM}Skip uninstall (--no-uninstall)${NC}"
        return
    fi
    echo -e "  ${DIM}Uninstalling app...${NC}"
    xcrun simctl uninstall "$DEVICE_ID" com.example.auroWallet 2>/dev/null || true
    adb -s "$DEVICE_ID" uninstall com.aurowallet.www 2>/dev/null || true
}

# ── Parse sub-test results from flutter output ──────────────────
_parse_subtest_results() {
    local test_num=$1
    local log_file=$2
    local details_file="$LOG_DIR/details_${test_num}.txt"
    : > "$details_file"

    # Extract non-passing sub-test lines (format: N.N test_name: FAIL/SKIP/PARTIAL - reason)
    grep -E '[0-9]+\.[0-9]+ .*(FAIL|SKIP|PARTIAL)' "$log_file" 2>/dev/null | \
        sed 's/^.*flutter: //' | sed 's/^║ //' | sed 's/^ *//' \
        > "$details_file" 2>/dev/null || true

    [ -s "$details_file" ] || return 0

    # Main result PASS but sub-tests have FAIL/PARTIAL → downgrade to WARN
    local current_result=$(get_result "$test_num")
    local has_fail=0
    has_fail=$(grep -cE 'FAIL|PARTIAL' "$details_file" 2>/dev/null) || has_fail=0
    if [ "$current_result" = "PASS" ] && [ "$has_fail" -gt 0 ]; then
        set_result "$test_num" "WARN"
        echo -e "  ${YELLOW}⚠️  $test_name — sub-test failures${NC}"
    fi
}

# ── Run a single test ─────────────────────────────────────────────
run_test() {
    local test_num=$1
    local test_file=$(get_test_file "$test_num")
    local test_name=$(get_test_name "$test_num")

    if [ -z "$test_file" ]; then
        echo -e "  ${RED}Invalid test number: $test_num${NC}"
        return
    fi

    echo ""
    echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${BOLD}[$test_num] $test_name${NC}  ${DIM}($test_file)${NC}"
    echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    if [ "$test_num" = "5" ] || [ "$test_num" = "6" ]; then
        echo -e "  ${YELLOW}Keeping app data — flow $test_num preserves existing wallet${NC}"
    else
        uninstall_app
    fi

    local idle_timeout="${TEST_IDLE_TIMEOUT:-120}"
    local rc=0

    # Check if pipe is broken (macOS bash 3.2 builtins can't detect)
    _check_pipe

    local log_file="$LOG_DIR/flow${test_num}.log"
    : > "$log_file"

    # For flow6 (quick wallet setup), add --keep-app-running to prevent uninstall
    local extra_flags="$FLUTTER_EXTRA"
    if [ "$test_num" = "6" ]; then
        extra_flags="$extra_flags --keep-app-running"
    fi

    # Run flutter drive in background, write output to log file
    flutter drive \
        --driver=test_driver/integration_test.dart \
        --target=integration_test/$test_file \
        -d "$DEVICE_ID" $extra_flags > "$log_file" 2>&1 &
    DRIVE_PID=$!

    # Stream output in real-time
    tail -f "$log_file" 2>/dev/null &
    TAIL_PID=$!

    # Watchdog: idle timeout (kill if no new output), not total time
    (
        local last_size=0
        local idle_count=0
        while true; do
            sleep 5 2>/dev/null || break
            # Check if process is still running
            kill -0 "$DRIVE_PID" 2>/dev/null || break
            local cur_size=$(wc -c < "$log_file" 2>/dev/null || echo 0)
            if [ "$cur_size" -eq "$last_size" ]; then
                idle_count=$((idle_count + 5))
                if [ "$idle_count" -ge "$idle_timeout" ]; then
                    echo -e "\n  ${RED}⏱  Idle timeout (${idle_timeout}s no output), killing test...${NC}"
                    kill "$DRIVE_PID" 2>/dev/null
                    break
                fi
            else
                idle_count=0
                last_size=$cur_size
            fi
        done
    ) &
    WATCHDOG_PID=$!

    # Wait for flutter drive to finish (can be interrupted by SIGPIPE/SIGINT)
    wait "$DRIVE_PID" 2>/dev/null || rc=$?
    DRIVE_PID=""

    # Stop tail
    kill "$TAIL_PID" 2>/dev/null || true
    wait "$TAIL_PID" 2>/dev/null || true
    TAIL_PID=""

    # Clean up watchdog
    kill "$WATCHDOG_PID" 2>/dev/null || true
    wait "$WATCHDOG_PID" 2>/dev/null || true
    WATCHDOG_PID=""

    if [ $rc -eq 0 ]; then
        set_result "$test_num" "PASS"
        echo -e "  ${GREEN}✅ $test_name — PASSED${NC}"
    elif [ $rc -eq 137 ] || [ $rc -eq 143 ]; then
        set_result "$test_num" "FAIL"
        echo -e "  ${RED}⏱  $test_name — idle timeout${NC}"
    else
        set_result "$test_num" "FAIL"
        echo -e "  ${RED}❌ $test_name — FAILED (exit=$rc)${NC}"
    fi

    # Copy screenshots to project directory
    local ss_dest="$PROJECT_DIR/integration_test/screenshots"
    # Prefer /tmp/auro_test_screenshots/ (new path, writes directly to host /tmp/)
    local ss_src="/tmp/auro_test_screenshots"
    # Fallback: extract path from log
    if [ ! -d "$ss_src" ] && [ -f "$log_file" ]; then
        ss_src=$(grep -oE '/[^ ]*auro_test_screenshots' "$log_file" | head -1)
    fi
    # Fallback: search simulator sandbox with find
    if [ -z "$ss_src" ] || [ ! -d "$ss_src" ]; then
        ss_src=$(find ~/Library/Developer/CoreSimulator/Devices/"$DEVICE_ID"/data \
            -path "*/tmp/auro_test_screenshots" -type d -maxdepth 6 2>/dev/null | head -1)
    fi
    if [ -n "$ss_src" ] && [ -d "$ss_src" ]; then
        mkdir -p "$ss_dest"
        cp -R "$ss_src"/* "$ss_dest/" 2>/dev/null || true
        echo -e "  ${DIM}📸 Screenshots copied to: $ss_dest${NC}"
    else
        echo -e "  ${DIM}⚠️ Screenshot directory not found${NC}"
    fi

    # Parse sub-test results (FAIL/SKIP), override main result if needed
    _parse_subtest_results "$test_num" "$log_file"
}

# ── Summary ───────────────────────────────────────────────────────
print_summary() {
    local pass_count=0
    local fail_count=0
    local warn_count=0

    echo ""
    echo -e "  ${CYAN}${BOLD}Test Results${NC}"
    echo -e "  ${CYAN}───────────────────────────────────────────${NC}"

    for i in $(echo "$TEST_ORDER" | grep -o .); do
        local result=$(get_result "$i")
        local name=$(get_test_name "$i")
        local details_file="$LOG_DIR/details_${i}.txt"

        if [ "$result" = "PASS" ]; then
            echo -e "  ${GREEN}✅ $name${NC}"
            ((pass_count++)) || true
        elif [ "$result" = "WARN" ]; then
            echo -e "  ${YELLOW}⚠️  $name (sub-test failures)${NC}"
            ((warn_count++)) || true
        elif [ "$result" = "FAIL" ]; then
            echo -e "  ${RED}❌ $name${NC}"
            ((fail_count++)) || true
        else
            echo -e "  ${DIM}⏭  $name (skipped)${NC}"
        fi

        # Show sub-test failure/skip details
        if [ -s "$details_file" ]; then
            while IFS= read -r line; do
                echo -e "     ${DIM}$line${NC}"
            done < "$details_file"
        fi
    done

    echo -e "  ${CYAN}───────────────────────────────────────────${NC}"
    local summary="Pass: ${GREEN}$pass_count${NC}  Fail: ${RED}$fail_count${NC}"
    if [ $warn_count -gt 0 ]; then
        summary="$summary  Partial: ${YELLOW}$warn_count${NC}"
    fi
    echo -e "  $summary"
    echo ""

    # Clean up temp logs
    rm -rf "$LOG_DIR" 2>/dev/null || true

    if [ $fail_count -gt 0 ] || [ $warn_count -gt 0 ]; then
        exit 1
    fi
}

# ── Main ──────────────────────────────────────────────────────────
main() {
    print_banner
    detect_device

    # Interactive selection if no test order given
    if [ -z "$TEST_ORDER" ]; then
        echo ""
        show_menu
    fi

    echo ""
    echo -e "  ${BOLD}Test plan:${NC}"
    for i in $(echo "$TEST_ORDER" | grep -o .); do
        echo -e "    $i. $(get_test_name "$i")"
    done
    if [ "$OPT_NO_PUB" = "true" ]; then
        echo -e "  ${DIM}(--no-pub skip dependency resolution)${NC}"
    fi

    # Clear old screenshots before running
    local ss_dest="$PROJECT_DIR/integration_test/screenshots"
    local ss_tmp="/tmp/auro_test_screenshots"
    if [ -d "$ss_dest" ]; then
        rm -rf "$ss_dest"
        echo -e "  ${DIM}Cleared old screenshots: $ss_dest${NC}"
    fi
    if [ -d "$ss_tmp" ]; then
        rm -rf "$ss_tmp"
        echo -e "  ${DIM}Cleared temp screenshots: $ss_tmp${NC}"
    fi

    # Run tests
    for i in $(echo "$TEST_ORDER" | grep -o .); do
        run_test "$i"
    done

    print_summary
}

main
