#!/usr/bin/env python3
"""Manage comparison simulators and builds without changing app source."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = 'com.apple.CoreSimulator.SimRuntime.iOS-26-4'
BUNDLE = 'com.aurowallet.www.aurowallet.debug'
DEVICES = [
    ('Auro-Master-iPhone', 'com.apple.CoreSimulator.SimDeviceType.iPhone-17'),
    ('Auro-Current-iPhone', 'com.apple.CoreSimulator.SimDeviceType.iPhone-17'),
    ('Auro-Current-iPad', 'com.apple.CoreSimulator.SimDeviceType.iPad-Air-11-inch-M4'),
]


def run(*args, capture=False, cwd=None, check=True):
    result = subprocess.run([str(a) for a in args], cwd=cwd, text=True,
                            stdout=subprocess.PIPE if capture else None,
                            stderr=subprocess.PIPE if capture else None)
    if check and result.returncode:
        raise RuntimeError(f'Command failed: {shlex.join(str(a) for a in args)}\n'
                           f'{result.stderr or "See output above"}')
    return result.stdout.strip() if capture and check else result


def json_cmd(*args):
    return json.loads(run(*args, capture=True))


def patch_master(path):
    text = path.read_text()
    start = text.index('97C147061CF9000F007C117D /* Debug */ = {')
    end = text.index('name = Debug;', start)
    block = text[start:end]
    old = 'PRODUCT_BUNDLE_IDENTIFIER = com.aurowallet.www.aurowallet;'
    new = f'PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE};'
    if block.count(new) == 1 and old not in block:
        return
    if block.count(old) != 1:
        raise RuntimeError('Unexpected master Runner Debug bundle ID; review it manually')
    path.write_text(text[:start] + block.replace(old, new) + text[end:])


def find_devices(data):
    result = []
    for name, kind in DEVICES:
        matches = [(runtime, d) for runtime, devices in data['devices'].items()
                   for d in devices if d['name'] == name]
        if len(matches) > 1:
            raise RuntimeError(f'{name} has duplicate devices; review and rename them first')
        if matches:
            runtime, d = matches[0]
            if (runtime != RUNTIME or not d.get('isAvailable')
                    or d.get('deviceTypeIdentifier') != kind):
                raise RuntimeError(f'{name} has an unavailable or unexpected runtime/model; device unchanged')
            result.append(d)
        else:
            result.append(None)
    return result


def installed(device):
    return run('xcrun', 'simctl', 'get_app_container', device, BUNDLE, 'app',
               capture=True, check=False).returncode == 0


def boot(device):
    data = json_cmd('xcrun', 'simctl', 'list', 'devices', '--json')
    state = next(d['state'] for ds in data['devices'].values() for d in ds
                 if d['udid'] == device)
    if state == 'Shutdown':
        run('xcrun', 'simctl', 'boot', device)
    run('xcrun', 'simctl', 'bootstatus', device, '-b')


def ready(session, panes, timeout=180, previously_ready=False):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        statuses = run('tmux', 'list-panes', '-t', session, '-F',
                       '#{pane_id} #{pane_dead}', capture=True).splitlines()
        if len(statuses) != 2 or any(s.endswith(' 1') for s in statuses):
            raise RuntimeError('Flutter session exited; check tmux output, fix the issue, then use --restart')
        if previously_ready:
            return
        if all('Flutter run key commands' in run('tmux', 'capture-pane', '-p',
                    '-S', '-2000', '-t', pane, capture=True) for pane in panes):
            return
        time.sleep(2)
    raise RuntimeError('Flutter attach timed out; sessions preserved. Check tmux output and retry')


def main():
    parser = argparse.ArgumentParser(description='Launch master iPhone, current iPhone, and current iPad')
    parser.add_argument('--check', action='store_true', help='Check prerequisites only')
    parser.add_argument('--restart', action='store_true', help='Rebuild and restart both current sessions, preserving wallet data')
    parser.add_argument('--no-attach', action='store_true', help='Start without attaching to tmux')
    args = parser.parse_args()
    if args.check and args.restart:
        parser.error('--check and --restart are mutually exclusive')
    key = hashlib.sha256(str(ROOT).encode()).hexdigest()[:10]
    state = Path.home() / 'Library' / 'Caches' / 'auro-ui-compare' / key
    master = ROOT.with_name(ROOT.name + '-master-ui-compare')
    session = 'auro-ui-' + key
    flutter = os.environ.get('AURO_FLUTTER') or str(Path.home() / '.fvm/default/bin/flutter')
    missing = [cmd for cmd in ['git', 'xcrun', 'tmux', 'open', 'ditto'] if not shutil.which(cmd)]
    if not Path(flutter).is_file():
        missing.append(f'Flutter ({flutter}; set its absolute path via AURO_FLUTTER)')
    print(f'Current source: {ROOT}\nBaseline: {master}\nCache: {state}\ntmux: {session}', flush=True)
    if shutil.which('xcrun'):
        runtimes = json_cmd('xcrun', 'simctl', 'list', 'runtimes', '--json')['runtimes']
        if not any(r['identifier'] == RUNTIME and r.get('isAvailable') for r in runtimes):
            missing.append(f'Xcode Runtime {RUNTIME}')
        devices = find_devices(json_cmd('xcrun', 'simctl', 'list', 'devices', '--json'))
        for (name, _), device in zip(DEVICES, devices):
            print(f'{name}: ' + (device['udid'] + ' / ' + device['state'] if device else 'Created on first run'))
    if missing:
        raise RuntimeError('Missing dependencies: ' + ', '.join(missing) + '\nInstall missing tmux with: brew install tmux')
    if args.check:
        print('Prerequisites passed; build, install, wallet, and hot restart remain unverified.')
        return

    state.mkdir(parents=True, exist_ok=True)
    # Prevent concurrent device/build setup; release the lock on exit.
    import fcntl
    with (state / 'launcher.lock').open('w') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise RuntimeError('Another launcher is preparing the environment; wait for it to finish')
        exists = run('tmux', 'has-session', '-t', session, capture=True, check=False).returncode == 0
        if exists:
            owner = run('tmux', 'show-options', '-qv', '-t', session, '@auro-root', capture=True)
            if owner != str(ROOT):
                raise RuntimeError('Existing tmux session belongs to another launcher; left unchanged')
            statuses = run('tmux', 'list-panes', '-t', session, '-F', '#{pane_dead}', capture=True).splitlines()
            if args.restart or (len(statuses) == 2 and all(s == '1' for s in statuses)):
                run('tmux', 'kill-session', '-t', session)
                exists = False
            else:
                if not all(devices):
                    raise RuntimeError('Debug sessions exist but devices are missing; check and use --restart')
                panes = run('tmux', 'list-panes', '-t', session, '-F', '#{pane_id}', capture=True).splitlines()
                confirmed = run('tmux', 'show-options', '-qv', '-t', session, '@auro-ready', capture=True)
                ready(session, panes, timeout=10, previously_ready=confirmed == '1')
                for device in devices:
                    boot(device['udid'])
                run('open', '-a', 'Simulator')
                run('xcrun', 'simctl', 'launch', devices[0]['udid'], BUNDLE)
                print('Reusing debug sessions; press r/R to apply saved Dart changes.')
        if not exists:
            if not master.exists():
                run('git', '-C', ROOT, 'worktree', 'add', '--detach', master, 'master')
            worktrees = run('git', '-C', ROOT, 'worktree', 'list', '--porcelain', capture=True)
            if f'worktree {master}\n' not in worktrees:
                raise RuntimeError('Baseline directory is not a worktree of this repository; left unchanged')
            commit = run('git', '-C', master, 'rev-parse', 'HEAD', capture=True)
            # Allow only the documented Debug bundle ID change in the baseline.
            changed = run('git', '-C', master, 'diff', 'HEAD', '--name-only', capture=True).splitlines()
            if any(p != 'ios/Runner.xcodeproj/project.pbxproj' for p in changed):
                raise RuntimeError('Baseline contains other source changes; review before continuing')
            project = master / 'ios/Runner.xcodeproj/project.pbxproj'
            expected = run('git', '-C', master, 'show', 'HEAD:ios/Runner.xcodeproj/project.pbxproj', capture=True)
            # Accept only the original project or the expected Debug bundle ID patch.
            start = expected.index('97C147061CF9000F007C117D /* Debug */ = {')
            end = expected.index('name = Debug;', start)
            patched = expected[:start] + expected[start:end].replace(
                'PRODUCT_BUNDLE_IDENTIFIER = com.aurowallet.www.aurowallet;',
                f'PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE};') + expected[end:]
            if project.read_text().strip() not in (expected.strip(), patched.strip()):
                raise RuntimeError('Baseline project has extra changes; left unchanged')
            patch_master(project)
            current_project = (ROOT / 'ios/Runner.xcodeproj/project.pbxproj').read_text()
            start = current_project.index('97C147061CF9000F007C117D /* Debug */ = {')
            end = current_project.index('name = Debug;', start)
            if f'PRODUCT_BUNDLE_IDENTIFIER = {BUNDLE};' not in current_project[start:end]:
                raise RuntimeError('Current Runner Debug bundle ID does not match; project unchanged')
            config_path = Path('lib/common/consts/apiConfig.dart')
            config = master / config_path
            if not config.exists():
                source = ROOT / config_path
                if not source.is_file():
                    raise RuntimeError('Missing apiConfig.dart; configure the current checkout and retry')
                if run('git', '-C', master, 'check-ignore', '-q', str(config_path),
                       capture=True, check=False).returncode != 0:
                    raise RuntimeError('Baseline config path is not Git-ignored; no file written')
                shutil.copy2(source, config)
                print('Copied local apiConfig.dart to baseline; contents omitted')
            untracked = run('git', '-C', master, 'ls-files', '--others', '--exclude-standard', capture=True)
            if untracked:
                raise RuntimeError('Baseline contains untracked files; review before continuing')
            fingerprint = hashlib.sha256((commit + hashlib.sha256(config.read_bytes()).hexdigest()
                        + run(flutter, '--version', capture=True)
                        + run('xcodebuild', '-version', capture=True) + BUNDLE).encode()).hexdigest()
            app = state / 'master-Runner.app'
            stamp = state / 'master-build.txt'
            if not app.exists() or not stamp.exists() or stamp.read_text() != fingerprint:
                print('Building pinned master baseline...', flush=True)
                run(flutter, 'pub', 'get', cwd=master)
                run(flutter, 'build', 'ios', '--simulator', '--debug', cwd=master)
                # Invalidate the cache before copying to reject partial app bundles.
                if stamp.exists():
                    stamp.unlink()
                if app.exists():
                    shutil.rmtree(app)
                run('ditto', master / 'build/ios/iphonesimulator/Runner.app', app)
                stamp.write_text(fingerprint)
            else:
                print(f'Reusing master build: {commit}')
            # Refresh devices and create missing models; preserve existing wallet data.
            devices = find_devices(json_cmd('xcrun', 'simctl', 'list', 'devices', '--json'))
            ids = []
            for (name, kind), device in zip(DEVICES, devices):
                uid = device['udid'] if device else run('xcrun', 'simctl', 'create', name, kind, RUNTIME, capture=True)
                ids.append(uid)
                boot(uid)
            run('open', '-a', 'Simulator')
            install_stamp = state / ('master-installed-' + ids[0])
            if not installed(ids[0]) or not install_stamp.exists() or install_stamp.read_text() != fingerprint:
                run('xcrun', 'simctl', 'install', ids[0], app)
                install_stamp.write_text(fingerprint)
            run('xcrun', 'simctl', 'launch', ids[0], BUNDLE)
            print('Building current version once, then installing on both current devices...', flush=True)
            run(flutter, 'pub', 'get', cwd=ROOT)
            run(flutter, 'build', 'ios', '--simulator', '--debug', cwd=ROOT)
            current_app = ROOT / 'build/ios/iphonesimulator/Runner.app'
            for uid in ids[1:]:
                run('xcrun', 'simctl', 'terminate', uid, BUNDLE, capture=True, check=False)
                run('xcrun', 'simctl', 'install', uid, current_app)
                run('xcrun', 'simctl', 'launch', uid, BUNDLE)
            command = lambda uid: 'exec ' + shlex.join([flutter, 'attach', '-d', uid])
            pane1 = run('tmux', 'new-session', '-d', '-P', '-F', '#{pane_id}', '-s', session,
                        '-n', 'current', '-c', ROOT, command(ids[1]), capture=True)
            run('tmux', 'set-option', '-t', session, '@auro-root', ROOT)
            run('tmux', 'set-window-option', '-t', session, 'remain-on-exit', 'on')
            pane2 = run('tmux', 'split-window', '-h', '-P', '-F', '#{pane_id}', '-t', session + ':current',
                        '-c', ROOT, command(ids[2]), capture=True)
            print(f'Waiting for both Flutter sessions; inspect with: tmux attach -t {session}', flush=True)
            ready(session, [pane1, pane2])
            run('tmux', 'set-option', '-t', session, '@auro-ready', '1')
        run('tmux', 'set-window-option', '-t', session + ':current', 'synchronize-panes', 'on')
    print('Three devices started. Current devices: r reload / R restart / q quit; Ctrl+B then D detaches.\n'
          'Import a test wallet, verify unlock, and align pages manually; Keychain is not copied.', flush=True)
    if not args.no_attach and sys.stdin.isatty():
        run('tmux', 'switch-client' if os.environ.get('TMUX') else 'attach-session', '-t', session)
    else:
        print(f'Attach: tmux attach-session -t {session}')


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, ValueError, OSError, subprocess.SubprocessError) as error:
        print(f'Startup failed: {error}', file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print('\nStartup interrupted; created devices, data, and sessions preserved.', file=sys.stderr)
        sys.exit(130)
