; this code is public domain
; http://creativecommons.org/publicdomain/zero/1.0/

; to compile with visual studio x86 build tools in command prompt:
; >ml /coff gmsched.asm /link /dll /nocoffgrpinfo /entry:dllmain /def:gmsched.def /out:gmsched.dll
; this will produce a whole load of files, but you only need gmsched.dll

.386
.model flat

; prototypes
timeBeginPeriod PROTO STDCALL :DWORD
timeEndPeriod PROTO STDCALL :DWORD
timeGetDevCaps PROTO STDCALL :DWORD,:DWORD
includelib winmm.lib

.data?
currentTimePeriod DWORD ?

.code
; info
InfoText db 13,10,"=======================================",13,10," https://github.com/skyfloogle/gmsched ",13,10,"=======================================",13,10

dllmain proc stdcall instance:dword,reason:dword,unused:dword
    mov eax,1
    ret
dllmain endp

; set period to 1 on init
gmsched_init proc c
	mov eax,1
	mov currentTimePeriod,eax
	invoke timeBeginPeriod,eax
	ret
gmsched_init endp

; returns 0 on success, 1 on out of range (as a double)
scheduler_resolution_set proc c FPeriod:real8
LOCAL IPeriod:dword ; integer version of new period
    ; convert FPeriod to dword and store in IPeriod
    fld FPeriod
    fistp IPeriod
	; set new period
	invoke timeBeginPeriod,[IPeriod]
	; don't end old period on error
	test eax,eax
	jnz did_err
	; end old period
	invoke timeEndPeriod,[currentTimePeriod]
	; update stored period
	mov eax,[IPeriod]
	mov [currentTimePeriod],eax
	; return 0 for no error
	fldz
	jmp exit
did_err:
	; return 1 for error
	fld1
exit:
	ret
scheduler_resolution_set endp

scheduler_resolution_get proc c
    fild currentTimePeriod
    ret
scheduler_resolution_get endp

scheduler_resolution_get_min proc c
LOCAL timecaps[2]:dword
	lea eax,timecaps
	invoke timeGetDevCaps, eax, 8
	fild timecaps[0]
	ret
scheduler_resolution_get_min endp

scheduler_resolution_get_max proc c
LOCAL timecaps[2]:dword
	lea eax,timecaps
	invoke timeGetDevCaps, eax, 8
	fild timecaps[4]
	ret
scheduler_resolution_get_max endp

end
