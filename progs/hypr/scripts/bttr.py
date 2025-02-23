#??inheritPath=false
#??[runtimeInputs]
#??pkgs = ["hyprland"]

from __future__ import annotations
from abc import ABC, abstractmethod
from functools import cache
import sys
import subprocess
import json
from typing import Callable, Dict, Iterable, Iterator, Tuple, TypeVar

T = TypeVar("T")

workspaces_per_monitor = 9
special_base = int(1e6)
workspace_base = 1
special_count = 5
max_monitors = 5
log_level = 0

class Log:
    @staticmethod
    def print(level, tag, *parts):
        if level > log_level:
            return
        print(f"[{tag}]", *parts, file = sys.stderr)

    @staticmethod
    def info(*parts):
        Log.print(3, "info", *parts)

    @staticmethod
    def warn(*parts):
        Log.print(2, "warn", *parts)

    @staticmethod
    def err(*parts):
        Log.print(1, "error", *parts)

    @staticmethod
    def fatal(*parts):
        Log.print(0, "fatal", *parts)
        sys.exit(1)

class Args:
    l: list[str]

    def __init__(self, initial: list[str]):
        initial.reverse()
        self.l = initial
        # skip program name
        self.next()

    def next(self) -> str | None:
        if len(self.l) == 0:
            return None
        return self.l.pop()

    def peek(self) -> str | None:
        if len(self.l) == 0:
            return None
        return self.l[-1]

def run(cmd: str) -> Tuple[bytes, bool]:
    Log.info("Running: ", cmd)
    sub = subprocess.run(cmd.split(), capture_output=True)
    ok = sub.returncode == 0
    if not ok:
        Log.warn("Exited with", sub.returncode)
    return sub.stdout, ok

@cache
def fetch(what: str):
    Log.info("Fetching: ", what)
    out, _ = run(f'hyprctl {what} -j')
    return json.loads(out)

def first(it: Iterator[T]) -> T | None:
    try:
        return next(it)
    except StopIteration:
        return None

class MonitorSelector(ABC):
    @abstractmethod
    def focus_workspace(self, w: WorkspaceSelector):
        pass

    @abstractmethod
    def move_win_to_workspace(self, win: WindowSelector, w: WorkspaceSelector):
        pass

class AbsMonitor(MonitorSelector):
    def __init__(self, id: int):
        monitors = fetch("monitors")
        m = first(filter(lambda m: m["id"] == id, monitors))
        assert m is not None
        self.id = id

    def focus_workspace(self, w: WorkspaceSelector):
        run(f'hyprctl dispatch bttr:workspacemonitor {w.raw_id(self)} {self.id}')

    def move_win_to_workspace(self, win: WindowSelector, w: WorkspaceSelector):
        run(f'hyprctl dispatch movetoworkspacesilent {w.raw_id(self)},address:{hex(win.id())}')

class CurrentMonitor(MonitorSelector):
    def __init__(self):
        pass

    def abs(self) -> AbsMonitor:
        monitors = fetch("monitors")
        cur_monitor = first(filter(lambda m: m["focused"], monitors))
        assert cur_monitor is not None
        return AbsMonitor(cur_monitor["id"])

    def focus_workspace(self, w: WorkspaceSelector):
        self.abs().focus_workspace(w)

    def move_win_to_workspace(self, win: WindowSelector, w: WorkspaceSelector):
        self.abs().move_win_to_workspace(win, w)

class AllMonitors(MonitorSelector):
    def __init__(self):
        pass

    def abs_list(self) -> Iterable[AbsMonitor]:
        monitors = fetch("monitors")
        return map(lambda m: AbsMonitor(m["id"]), monitors)

    def focus_workspace(self, w: WorkspaceSelector):
        for m in self.abs_list():
            m.focus_workspace(w)

    def move_win_to_workspace(self, win: WindowSelector, w: WorkspaceSelector):
        _ = win, w
        Log.fatal("Cannot move window to all workspaces")
        assert False

# (cur|abs <num>|all)
def parse_monitor(args: Args) -> MonitorSelector | None:
    match args.next():
        case "cur":
            return CurrentMonitor()
        case "abs":
            monitor_id = None
            try:
                monitor_id = args.next()
                assert monitor_id is not None
                monitor_id = int(monitor_id)
            except:
                Log.fatal('Abs monitor selector requires a num')
                return
            return AbsMonitor(monitor_id)
        case "all":
            return AllMonitors()
        case _:
            Log.err("Unknown monitor selector")
            return

def fetch_open_workspaces(m: AbsMonitor) -> list[AbsWorkspace | SpecialWorkspace]:
    workspaces = fetch("workspaces")
    workspaces = map(lambda w: mw_from_id(int(w['id'])), workspaces)
    on_monitor = filter(lambda mw: mw[0].id == m.id, workspaces)
    ws = list(map(lambda mw: mw[1], on_monitor))
    ws.sort(key=lambda w: w.raw_id(m) or 0)
    return ws

def fetch_active_workspace(m: AbsMonitor) -> AbsWorkspace | SpecialWorkspace:
    monitors = fetch("monitors")
    mon = first(filter(lambda mon: mon["id"] == m.id, monitors))
    assert mon is not None
    id = mon["activeWorkspace"]["id"]
    _, w = mw_from_id(id)
    return w

class WorkspaceSelector(ABC):
    def __init__(self, id: int):
        self.id = id

    @abstractmethod
    def raw_id(self, m: AbsMonitor) -> int | None:
        pass

class AbsWorkspace(WorkspaceSelector):
    def raw_id(self, m: AbsMonitor) -> int | None:
        if not (0 <= self.id and self.id < workspaces_per_monitor):
            Log.err("Workspace id out of range")
            return None
        return workspace_base + m.id * workspaces_per_monitor + self.id

class RelEmptyWorkspace(WorkspaceSelector):
    def raw_id(self, m: AbsMonitor) -> int | None:
        active = fetch_active_workspace(m)

        assert isinstance(active, AbsWorkspace)

        active.id = (active.id + self.id) % workspaces_per_monitor
        return active.raw_id(m)

class RelWorkspace(WorkspaceSelector):
    def abs_workspaces(self, m: AbsMonitor) -> list[AbsWorkspace]:
        ws = fetch_open_workspaces(m)
        abs = list(filter(lambda w: isinstance(w, AbsWorkspace), ws))
        return abs # type: ignore

    def raw_id(self, m: AbsMonitor) -> int | None:
        open = self.abs_workspaces(m)
        active = fetch_active_workspace(m)

        assert isinstance(active, AbsWorkspace)

        ind = None
        for i, w in enumerate(open):
            if w.id == active.id:
                ind = i
                break

        assert ind is not None

        return open[(ind + self.id) % len(open)].raw_id(m)

class SpecialWorkspace(WorkspaceSelector):
    def raw_id(self, m: AbsMonitor) -> int | None:
        if not (0 <= self.id and self.id < special_count):
            Log.err("Special id out of range")
            return None
        return special_base + m.id * special_count + self.id

class LastWorkspace(WorkspaceSelector):
    def __init__(self):
        pass

    def raw_id(self, m: AbsMonitor) -> int | None:
        out, _ = run(f'hyprctl dispatch bttr:prevworkspace {m.id}')
        return int(out)

# (abs|rel|rel_empty|special) <num>
def parse_workspace(args: Args) -> WorkspaceSelector | None:
    mode = args.next()

    if mode == "last":
        return LastWorkspace()

    try:
        num = args.next()
        assert num is not None
        num = int(num)
    except:
        Log.fatal('Workspace selectors require a number argument')
        return

    match mode:
        case "abs":
            return AbsWorkspace(num - 1)
        case "rel":
            return RelWorkspace(num)
        case "rel_empty":
            return RelEmptyWorkspace(num)
        case "special":
            return SpecialWorkspace(num - 1)
        case _:
            Log.fatal("Unknown workspace selector")
            return

class WindowSelector(ABC):
    @abstractmethod
    def id(self) -> int:
        pass

class CurrentWindow(WindowSelector):
    def __init__(self):
        pass

    def id(self) -> int:
        win = fetch("activewindow")
        Log.info("win addr:", win['address'])
        return int(win['address'], 16)

class WindowId(WindowSelector):
    def __init__(self, id: int):
        self._id = id

    def id(self) -> int:
        return self._id

# id <num>|cur
def parse_window(args: Args) -> WindowSelector | None:
    match args.next():
        case "cur":
            return CurrentWindow()
        case "id":
            try:
                num = args.next()
                assert num is not None
                num = int(num, 16)
            except:
                Log.fatal('Cannot parse window selector')
                return
            return WindowId(num)

def mw_from_id(id: int) -> Tuple[AbsMonitor, AbsWorkspace | SpecialWorkspace]:
    if id < special_base:
        base = workspace_base
        offsets = workspaces_per_monitor
        workspace_type = AbsWorkspace
    else:
        base = special_base
        offsets = special_count
        workspace_type = SpecialWorkspace

    id -= base
    m = id // offsets
    id %= offsets
    return AbsMonitor(m), workspace_type(id)

def monitor_workspace(args: Args):
    m = parse_monitor(args)

    if m is None:
        Log.fatal("Monitor selection failed")
        return

    w = parse_workspace(args)

    if w is None:
        Log.fatal("Workspace selection failed")
        return

    ws = filter(
        lambda w: isinstance(w, SpecialWorkspace),
        map(lambda m: fetch_active_workspace(m), AllMonitors().abs_list())
    )

    if first(ws) is not None:
        AllMonitors().focus_workspace(LastWorkspace())
    else:
        m.focus_workspace(w)

def move_to_workspace(args: Args):
    win = parse_window(args)
    m = parse_monitor(args)
    w = parse_workspace(args)

    assert win is not None
    assert m is not None
    assert w is not None

    m.move_win_to_workspace(win, w)

def dump(_: Args):
    ms = AllMonitors().abs_list()
    res = []
    for m in ms:
        ws = fetch_open_workspaces(m)
        active = fetch_active_workspace(m)
        abs = []
        special = []
        for w in ws:
            d = {}
            d["id"] = w.id + 1
            d["focused"] = w.raw_id(m) == active.raw_id(m)
            if isinstance(w, AbsWorkspace):
                abs.append(d)
            else:
                special.append(d)

        res.append({"abs": abs, "special": special})
    print(json.dumps(res))

def main():
    args = Args(sys.argv)

    dispatchers: Dict[str, Callable[[Args], None]] = {
        "monitor_workspace": monitor_workspace,
        "move_to_workspace": move_to_workspace,
        "dump": dump,
    }

    disp_name = args.next()
    if disp_name is None:
        Log.fatal("No dispatcher supplied")
        return

    disp = dispatchers[disp_name]

    if disp is None:
        Log.fatal("Unknown dispatcher")
        return

    disp(args)

if __name__ == "__main__":
    main()
