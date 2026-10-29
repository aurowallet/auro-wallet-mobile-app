"""Launcher regression tests; mock all external commands."""
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location('ui_compare', Path(__file__).parents[1] / 'ui_compare.py')
ui = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ui)
PROJECT = '''97C147061CF9000F007C117D /* Debug */ = {
PRODUCT_BUNDLE_IDENTIFIER = com.aurowallet.www.aurowallet;
name = Debug;
};
'''


class FakeEnvironment:
    def __init__(self, root):
        self.root = root
        self.master = root.with_name(root.name + '-master-ui-compare')
        self.devices = []
        self.session = False
        self.dead = False
        self.installed = set()
        self.commands = []
        self.project = root / 'ios/Runner.xcodeproj/project.pbxproj'
        self.project.parent.mkdir(parents=True)
        self.project.write_text(PROJECT.replace('aurowallet;', 'aurowallet.debug;'))
        config = root / 'lib/common/consts/apiConfig.dart'
        config.parent.mkdir(parents=True)
        config.write_text('// fixture configuration\n')
        self.flutter = root.parent / 'flutter'
        self.flutter.touch()

    def run(self, *args, capture=False, cwd=None, check=True):
        args = tuple(str(a) for a in args)
        self.commands.append(args)
        output, code = '', 0
        if args[0] == 'git':
            if 'add' in args:
                project = self.master / 'ios/Runner.xcodeproj/project.pbxproj'
                project.parent.mkdir(parents=True)
                project.write_text(PROJECT)
                (self.master / 'lib/common/consts').mkdir(parents=True)
            elif 'worktree' in args:
                output = f'worktree {self.master}\nHEAD fixture\n'
            elif 'rev-parse' in args:
                output = 'fixed-master-commit'
            elif 'show' in args:
                output = PROJECT
        elif args[0] == str(self.flutter):
            if '--version' in args:
                output = 'Flutter fixture'
            elif 'build' in args:
                (Path(cwd) / 'build/ios/iphonesimulator/Runner.app').mkdir(parents=True, exist_ok=True)
        elif args[0] == 'xcodebuild':
            output = 'Xcode fixture'
        elif args[0] == 'xcrun':
            if args[2:4] == ('list', 'runtimes'):
                output = json.dumps({'runtimes': [{'identifier': ui.RUNTIME, 'isAvailable': True}]})
            elif args[2:4] == ('list', 'devices'):
                output = json.dumps({'devices': {ui.RUNTIME: self.devices}})
            elif args[2] == 'create':
                output = f'uuid-{len(self.devices)}'
                self.devices.append(dict(name=args[3], deviceTypeIdentifier=args[4],
                    udid=output, isAvailable=True, state='Shutdown'))
            elif args[2] == 'boot':
                next(d for d in self.devices if d['udid'] == args[3])['state'] = 'Booted'
            elif args[2] == 'get_app_container':
                code = 0 if args[3] in self.installed else 1
            elif args[2] == 'install':
                self.installed.add(args[3])
        elif args[0] == 'ditto':
            Path(args[2]).mkdir()
        elif args[0] == 'tmux':
            if args[1] == 'has-session':
                code = 0 if self.session else 1
            elif args[1] == 'new-session':
                self.session, self.dead = True, False
                output = '%1'
            elif args[1] == 'kill-session':
                self.session = False
            elif args[1] == 'split-window':
                output = '%2'
            elif args[1] == 'show-options':
                output = str(self.root) if args[-1] == '@auro-root' else '1'
            elif args[1] == 'list-panes':
                dead = '1' if self.dead else '0'
                output = {'#{pane_dead}': f'{dead}\n{dead}', '#{pane_id}': '%1\n%2',
                          '#{pane_id} #{pane_dead}': f'%1 {dead}\n%2 {dead}'}[args[-1]]
            elif args[1] == 'capture-pane':
                output = 'Flutter run key commands'
        if check and code:
            raise RuntimeError('fake command failed')
        return output.strip() if capture and check else subprocess.CompletedProcess(args, code, output, '')


class LauncherTests(unittest.TestCase):
    def test_initial_reuse_and_restart_preserve_data_and_source(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp) / 'repo'
            env = FakeEnvironment(root)
            original = env.project.read_bytes()
            with patch.object(ui, 'ROOT', root), patch.object(ui, 'run', env.run), \
                 patch.object(ui.Path, 'home', return_value=Path(temp) / 'home'), \
                 patch.object(ui.shutil, 'which', return_value='/mock/tool'), \
                 patch.dict(ui.os.environ, {'AURO_FLUTTER': str(env.flutter)}), \
                 patch.object(ui.sys, 'argv', ['ui_compare', '--no-attach']):
                ui.main()
                self.assertEqual(len(env.devices), 3)
                self.assertEqual(sum('build' in c for c in env.commands), 2)
                self.assertEqual(env.project.read_bytes(), original)
                self.assertEqual((env.master / 'lib/common/consts/apiConfig.dart').read_text(),
                                 '// fixture configuration\n')
                env.commands.clear()
                ui.main()
                self.assertFalse(any('build' in c or 'install' in c or 'create' in c for c in env.commands))
                env.dead = True  # After q: reuse master and rebuild only the current version.
                env.commands.clear()
                ui.main()
                self.assertEqual(sum('build' in c for c in env.commands), 1)
                self.assertFalse(any('create' in c or 'erase' in c or 'uninstall' in c for c in env.commands))
                self.assertEqual(env.project.read_bytes(), original)
                self.assertEqual(len(env.devices), 3)

    def test_check_does_not_mutate(self):
        with tempfile.TemporaryDirectory() as temp:
            env = FakeEnvironment(Path(temp) / 'repo')
            with patch.object(ui, 'ROOT', env.root), patch.object(ui, 'run', env.run), \
                 patch.object(ui.Path, 'home', return_value=Path(temp) / 'home'), \
                 patch.object(ui.shutil, 'which', return_value='/mock/tool'), \
                 patch.dict(ui.os.environ, {'AURO_FLUTTER': str(env.flutter)}), \
                 patch.object(ui.sys, 'argv', ['ui_compare', '--check']):
                ui.main()
                self.assertFalse(env.master.exists())
                self.assertFalse((Path(temp) / 'home').exists())
                self.assertFalse(any('create' in c or 'build' in c for c in env.commands))

    def test_duplicate_or_wrong_device_rejected(self):
        name, kind = ui.DEVICES[0]
        device = dict(name=name, deviceTypeIdentifier=kind, isAvailable=True)
        with self.assertRaises(RuntimeError):
            ui.find_devices({'devices': {ui.RUNTIME: [device, device]}})
        with self.assertRaises(RuntimeError):
            ui.find_devices({'devices': {'other-runtime': [device]}})

    def test_bundle_patch_is_idempotent(self):
        with tempfile.TemporaryDirectory() as temp:
            file = Path(temp) / 'project'
            file.write_text(PROJECT)
            ui.patch_master(file)
            once = file.read_bytes()
            ui.patch_master(file)
            self.assertEqual(file.read_bytes(), once)

    def test_dead_attach_fails_before_keyboard_sync(self):
        with patch.object(ui, 'run', return_value='%1 0\n%2 1'):
            with self.assertRaises(RuntimeError):
                ui.ready('session', ['%1', '%2'])


if __name__ == '__main__':
    unittest.main()
