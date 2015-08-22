import gdb

class CheckFmtBreakpoint(gdb.Breakpoint):
    """Breakpoint checking whether the first argument of a function call is in
    read-only location, stopping program execution if it is not."""

    def __init__(self, spec, fmt_idx):
        # spec: specifies where to break
        #
        # gdb.BP_BREAKPOINT: specified that we are a breakpoint and not a
        # watchpoint.
        #
        # internal=True: the breakpoint won't show up in "info breakpoints" and
        # commands like this.
        super(CheckFmtBreakpoint, self).__init__(
            spec, gdb.BP_BREAKPOINT, internal=True
        )

        # Argument index of the format string (printf = 1, sprintf = 2)
        self.fmt_idx = fmt_idx

    def stop(self):
        """Method called by GDB when the breakpoint is triggered."""

        # Read the i-th argument of an x86_64 function call
        args = ["$rdi", "$rsi", "$rdx", "$rcx"]
        fmt_addr = int(gdb.parse_and_eval(args[self.fmt_idx]))

        # Parse /proc/<pid>/maps for this process
        proc_map = []
        with open("/proc/%d/maps" % gdb.selected_inferior().pid) as fp:
            proc_map = self._parse_map(fp.read())

        # Find the memory range which contains our format address
        for mapping in proc_map:
            if mapping["start"] <= fmt_addr < mapping["end"]:
                break
        else:
            print "%016x belongs to an unknown memory range" % fmt_addr
            return True

        # Check the memory permissions
        if "w" in mapping["perms"]:
            print "Format string in writable memory!"
            return True

        return False

    def _parse_map(self, file_contents):
        """Parse a /proc/<pid>/maps file to a list of dictionaries containing
        these fields:
          - start: the start address of the range
          - end: the end address of the range
          - perms: the permissions string"""

        zones = []
        for line in file_contents.split('\n'):
            if not line:
                continue
            memrange, perms, _ = line.split(None, 2)
            start, end = memrange.split('-')
            zones.append({
                'start': int(start, 16),
                'end': int(end, 16),
                'perms': perms
            })
        return zones

# Set breakpoints on all *printf functions
CheckFmtBreakpoint("printf", 0)
CheckFmtBreakpoint("fprintf", 1)
CheckFmtBreakpoint("sprintf", 1)
CheckFmtBreakpoint("snprintf", 2)
CheckFmtBreakpoint("vprintf", 0)
CheckFmtBreakpoint("vfprintf", 1)
CheckFmtBreakpoint("vsprintf", 1)
CheckFmtBreakpoint("vsnprintf", 2)
