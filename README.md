This extension backports GameMaker Studio 2.3.2's handling of the Windows
scheduler to earlier versions of GameMaker, including Studio 1.4.
This allows for games to run at full speed without setting the sleep margin to
high numbers and wasting CPU.

For optimal performance, import the latest version of this extension from the
[Releases](https://github.com/skyfloogle/gmsched/releases/latest) section
and set the sleep margin to 1ms.

Note that this extension is for GMS developers. If you have a compiled game you
want to improve the performance of, check out
[gms_scheduler_fix (aka DBGHELP.dll)](https://github.com/omicronrex/gms_scheduler_fix).

# Functions
- **scheduler_resolution_set(res):** Sets the scheduler resolution to the given
resolution, in milliseconds. Returns 0 on success and 1 if the resolution is
out of range.
- **scheduler_resolution_get():** Returns the current scheduler resolution.
Defaults to 1ms.
- **scheduler_resolution_get_min():** Returns the minimum possible scheduler
resolution on the current machine.
- **scheduler_resolution_get_max():** Returns the maximum possible scheduler
resolution on the current machine.

# Why is this a problem?
Every 16ms (at 60fps), GameMaker will perform the necessary calculations for
one frame, and wait for the next 16ms interval. The way this waiting happens is
the problem here. You can call a function in Windows to
[*Sleep*](https://docs.microsoft.com/en-us/windows/win32/api/synchapi/nf-synchapi-sleep)
for a certain
amount of time, in a power-efficient manner. However, this *Sleep* function is
not very accurate. For this reason, GameMaker will take the time remaining
until the next 16ms interval, subtract the sleep margin, and *Sleep* for that
amount of time. For the rest of the interval, it continuously checks whether
the time has elapsed, i.e. it busywaits. This uses 100% of one CPU core.

The inaccuracy of *Sleep* gave many users bad performance issues, especially
after its behaviour changed in certain Windows updates. As the sleep margin was
the only known way to affect this, it became consensus that the sleep margin
should be set to a high enough value that it would busywait for most, if not
all, of the interval. This is a massive waste of CPU resources, and will drain
the batteries and burn the thighs of laptop users.

Fortunately, there is a better way. It is possible to improve the accuracy of
the *Sleep* function, sometimes known as the "scheduler resolution", using the
[*timeBeginPeriod*](https://docs.microsoft.com/en-us/windows/win32/api/timeapi/nf-timeapi-timebeginperiod)
and
[*timeEndPeriod*](https://docs.microsoft.com/en-us/windows/win32/api/timeapi/nf-timeapi-timeendperiod)
functions.
This allows you to have accurate timers without draining laptop batteries.
Calling these functions has a slight performance cost of its own, especially on
older versions of Windows. It doesn't compare to the cost of busywaiting all
the time, but it is worth giving it a breather when performance isn't a
priority (e.g. if the game is out of focus or paused).

This functionality was finally added to GameMaker Studio 2 in version 2.3.2.
Now, people no longer have to set their sleep margin to obscene numbers to get
good performance. This extension allows Studio 1 users to take advantage of the
same functionality.
