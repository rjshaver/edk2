;------------------------------------------------------------------------------
;
; Copyright (c) 2007, Intel Corporation. All rights reserved.<BR>
; This program and the accompanying materials
; are licensed and made available under the terms and conditions of the BSD License
; which accompanies this distribution.  The full text of the license may be found at
; http://opensource.org/licenses/bsd-license.php
;
; THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
; WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
;
; Module Name:
;
;   CopyMem.asm
;
; Abstract:
;
;   CopyMem function
;
; Notes:
;
;------------------------------------------------------------------------------

    .code

;------------------------------------------------------------------------------
; VOID *
; EFIAPI
; EfiCommonLibCopyMem (
;   OUT     VOID                      *Destination,
;   IN      VOID                      *Source,
;   IN      UINTN                     Count
;   );
;------------------------------------------------------------------------------
EfiCommonLibCopyMem  PROC    USES    rsi rdi
    cmp     rdx, rcx                    ; if Source == Destination, do nothing
    je      @CopyMemDone
    cmp     r8, 0                       ; if Count == 0, do nothing
    je      @CopyMemDone
    mov     rsi, rdx                    ; rsi <- Source
    mov     rdi, rcx                    ; rdi <- Destination
    lea     r9, [rsi + r8 - 1]          ; r9 <- End of Source
    cmp     rsi, rdi
    mov     rax, rdi                    ; rax <- Destination as return value
    jae     @F
    cmp     r9, rdi
    jae     @CopyBackward               ; Copy backward if overlapped
@@:
    mov     rcx, r8
    and     r8, 7
    shr     rcx, 3                      ; rcx <- # of Qwords to copy
    jz      @CopyBytes
    DB      49h, 0fh, 7eh, 0c2h         ; movd r10, mm0 (Save mm0 in r10)
@@:
    DB      0fh, 6fh, 06h               ; movd mm0, [rsi]
    DB      48h, 0fh, 7eh, 07h          ; movd [rdi], mm0
    add     rsi, 8
    add     rdi, 8
    loop    @B
    DB      49h, 0fh, 6eh, 0c2h         ; movd mm0, r10 (Restore mm0)
    jmp     @CopyBytes
@CopyBackward:
    mov     rsi, r9                     ; rsi <- End of Source
    lea     rdi, [rdi + r8 - 1]         ; rdi <- End of Destination
    std                                 ; set direction flag
@CopyBytes:
    mov     rcx, r8
    rep     movsb                       ; Copy bytes backward
    cld
@CopyMemDone:   
    ret
EfiCommonLibCopyMem  ENDP

    END
