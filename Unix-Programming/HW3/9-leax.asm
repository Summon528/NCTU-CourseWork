; leax:
;         eax = edi * 2
;         ebx = edi * 3
;         ecx = edi * 5
;         edx = edi * 9
; ======

section	.text
    global _start

_start:
    ; straightforward implementation 
    lea eax, [edi * 2]
    lea ebx, [edi * 2 + edi]
    lea ecx, [edi * 4 + edi]
    lea edx, [edi * 8 + edi]

done: