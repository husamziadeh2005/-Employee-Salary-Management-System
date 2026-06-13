;====================================================================
; Program Name: Employee Salary Management System (ESMS)
; Program Description: A console-based Employee Salary Management System
;              that stores up to 50 employee records, validates
;              all inputs, calculates net salaries, displays pay
;              slips, department statistics, and salary histogram.
;Authors: Mohammad Shaqboua ,
;         Mohammad Dawas ,  
;         Husam Ziadeh
;====================================================================

INCLUDE Irvine32.inc
.data

; ============ Final Values ============
MAX_EMPLOYEES = 50
RECORD_SIZE   = 44

; ============ Arrays ============
empArray        BYTE MAX_EMPLOYEES * RECORD_SIZE DUP(0)
empCount        DWORD 0

; ============ Departmental Statistics ============
deptCount       DWORD 5 DUP(0)    
deptTotal       DWORD 5 DUP(0)    
deptMin         DWORD 5 DUP(0)    
deptMax         DWORD 5 DUP(0)    

; ============ Payroll ============
bracketCount    DWORD 5 DUP(0)    

; ============ Temporary variables ============
tempID          DWORD 0
tempDept        DWORD 0
tempSalary      DWORD 0
tempAllow       DWORD 0
tempDeduct      DWORD 0
tempNet         DWORD 0
tempName        BYTE 21 DUP(0)
testDeptCount   BYTE "Dept count: ",0
testDeptTotal   BYTE "Dept total: ",0
testBracket     BYTE "Bracket 4: ",0

; ============ Prompts ============
menuTitle       BYTE "================================================",0
menuHeader      BYTE " EMPLOYEE SALARY MANAGEMENT SYSTEM",0
menu1           BYTE "1. Add New Employee",0
menu2           BYTE "2. Display Pay Slip",0
menu3           BYTE "3. Department Statistics",0
menu4           BYTE "4. Exit Program",0
menuPrompt      BYTE "Enter your choice (1-4): ",0

; ============ Input messages ============
promptName      BYTE "Enter employee name: ",0
promptID        BYTE "Enter employee ID (6 digits): ",0
promptDept      BYTE "Enter department code (1-5): ",0
promptSalary    BYTE "Enter basic salary (500-20000 JOD): ",0
promptAllow     BYTE "Enter allowances (0-5000 JOD): ",0
promptDeduct    BYTE "Enter deductions (0-3000 JOD): ",0

; ============ Error messages ============
errID           BYTE "ERROR: ID must be 6 digits (100000-999999)!",0
errDept         BYTE "ERROR: Department must be between 1 and 5!",0
errSalary       BYTE "ERROR: Salary must be between 500 and 20000!",0
errFull         BYTE "ERROR: Maximum employees reached!",0
successAdd      BYTE "Employee added successfully!",0
pressKey        BYTE "Press any key to continue...",0
errAllow        BYTE "ERROR: Allowances must be between 0 and 5000 JOD!",0
errDeduct       BYTE "ERROR: Deductions must be between 0 and 3000 JOD!",0

; ============ Pay Slip ============
promptPaySlip   BYTE "Enter Employee ID for Pay Slip: ",0
errNotFound     BYTE "ERROR: Employee not found!",0
slipBorder      BYTE "============================================",0
slipSubLine     BYTE "--------------------------------------------",0
slipTitle2      BYTE "          EMPLOYEE PAY SLIP",0
slipLblName     BYTE "Name       : ",0
slipLblID       BYTE "ID         : ",0
slipLblDept     BYTE "Department : ",0
slipLblBasic    BYTE "Basic Sal  : ",0
slipLblAllow    BYTE "Allowances : ",0
slipLblDeduct   BYTE "Deductions : ",0
slipLblNet      BYTE "Net Salary : ",0
slipLblBracket  BYTE "Tax Bracket: Bracket ",0
slipJOD         BYTE " JOD",0

; ========= Department Statistics & Histogram Strings ==========
statsHeader     BYTE "          DEPARTMENT STATISTICS",0
statsLblDept    BYTE "Dept ",0
statsLblCount   BYTE "  Count: ",0
statsLblTotal   BYTE "  Total: ",0
statsLblMin     BYTE "  Min:   ",0
statsLblMax     BYTE "  Max:   ",0
histHeader      BYTE "          SALARY HISTOGRAM",0
histBracket1    BYTE "Bracket 1 (<500)   : ",0
histBracket2    BYTE "Bracket 2 (500-999) : ",0
histBracket3    BYTE "Bracket 3 (1000-1499): ",0
histBracket4    BYTE "Bracket 4 (1500-1999): ",0
histBracket5    BYTE "Bracket 5 (2000+)   : ",0


.code

;====================================================================
; Initialize: Clear all arrays and counters
;====================================================================
Initialize PROC
                            mov     empCount, 0
                            mov     esi, 0

    InitLoop:
                            mov     deptCount[esi*4], 0
                            mov     deptTotal[esi*4], 0
                            mov     deptMin[esi*4],   99999
                            mov     deptMax[esi*4],   0
                            mov     bracketCount[esi*4], 0
                            inc     esi
                            cmp     esi, 5
                            jl      InitLoop
                            ret
Initialize ENDP

;====================================================================
; ValidateID: Check if ID is between 100000 and 999999
; Input:  EAX = entered ID
; Output: EAX = 1 (valid) or 0 (invalid)
;====================================================================
ValidateID PROC
                            cmp     eax, 100000                                        ;check if ID is less than 100000
                            jl      IDInvalid
                            cmp     eax, 999999                                        ;check if ID is greater than 999999
                            jg      IDInvalid
                            mov     eax, 1                                             ;valid
                            ret

    IDInvalid:
                            mov     edx, offset errID                                  ;display error message
                            call    WriteString
                            call    Crlf
                            mov     eax, 0                                             ;invalid
                            ret
ValidateID ENDP

;====================================================================
; ValidateDepartment: Check if department code is between 1 and 5
; Input:  EAX = entered department code
; Output: EAX = 1 (valid) or 0 (invalid)
;====================================================================
ValidateDepartment PROC
                            cmp     eax, 1                                             ;check if department is less than 1
                            jl      DeptInvalid
                            cmp     eax, 5                                             ;check if department is greater than 5
                            jg      DeptInvalid
                            mov     eax, 1                                             ;valid
                            ret

    DeptInvalid:
                            mov     edx, offset errDept                                ;display error message
                            call    WriteString
                            call    Crlf
                            mov     eax, 0                                             ;invalid
                            ret
ValidateDepartment ENDP

;====================================================================
; ValidateSalaryRange: MASTER  checks if EAX is between EBX and ECX
; Input:  EAX = value to check
;         EBX = minimum allowed
;         ECX = maximum allowed
; Output: EAX = 1 (valid) or 0 (invalid)
;====================================================================
ValidateSalaryRange PROC
    cmp     eax, ebx            ; Is value < minimum?
    jl      Invalid             ; Yes → jump to Invalid label
    cmp     eax, ecx            ; Is value > maximum?
    jg      Invalid             ; Yes → jump to Invalid label
    mov     eax, 1              ; No to both → valid!
    ret

Invalid:
    mov     eax, 0              ; Return 0 (invalid)
    ret
ValidateSalaryRange ENDP


;====================================================================
; ValidateSalary: WRAPPER - Basic Salary must be 500-20000
; Input:  EAX = salary from user
; Output: EAX = 1 (valid) or 0 (invalid)
;====================================================================
ValidateSalary PROC
    mov     ebx, 500        ; Load minimum
    mov     ecx, 20000      ; Load maximum
    call    ValidateSalaryRange
    ret
ValidateSalary ENDP


;====================================================================
; ValidateAllowances: Check if allowances is 0-5000
; Input:  EAX = allowances from user
; Output: EAX = 1 (valid) or 0 (invalid)
;====================================================================
ValidateAllowances PROC
    mov     ebx, 0
    mov     ecx, 5000
    call    ValidateSalaryRange
    ret
ValidateAllowances ENDP


;====================================================================
; ShowError: Display error message
; Input: EDX = offset of error string
;====================================================================
ShowError PROC
    call    WriteString
    call    Crlf
    ret
ShowError ENDP

;====================================================================
; CalcNetSalary: Calculate Net Salary
; Formula: Net = Basic + Allowances - Deductions
; Input:  EBX = Basic Salary
;         ECX = Allowances
;         EDX = Deductions
; Output: EAX = Net Salary
;====================================================================
CalcNetSalary PROC
    mov     eax, ebx
    add     eax, ecx
    sub     eax, edx
    ret
CalcNetSalary ENDP


;====================================================================
; ValidateDeductions: Check if deductions is 0-3000
; Input:  EAX = deductions from user
; Output: EAX = 1 (valid) or 0 (invalid)
;====================================================================
ValidateDeductions PROC
    mov     ebx, 0
    mov     ecx, 3000
    call    ValidateSalaryRange
    ret
ValidateDeductions ENDP








;====================================================================
; FindEmployeeByID: Linear search through employee array
; Input:  EAX = Target ID to search for
; Output: EAX = Array index (0-based) if found, -1 if not found
;====================================================================
FindEmployeeByID PROC
    push    ebx
    push    ecx
    push    esi
    push    edx

    mov     ebx, eax
    mov     ecx, empCount
    cmp     ecx, 0
    je      NotFound

    mov     esi, 0

SearchLoop:
    imul    edx, esi, RECORD_SIZE
    mov     eax, DWORD PTR empArray[edx + 20]
    cmp     eax, ebx
    je      Found
    inc     esi
    loop    SearchLoop

NotFound:
    mov     eax, -1
    jmp     SearchDone

Found:
    mov     eax, esi

SearchDone:
    pop     edx
    pop     esi
    pop     ecx
    pop     ebx
    ret
FindEmployeeByID ENDP


;====================================================================
; UpdateStatistics: Update department stats and salary histogram
; Input:  EAX = Net Salary
;         EBX = Department Code (1-5)
; Modifies: deptCount, deptTotal, deptMin, deptMax, bracketCount
;====================================================================
UpdateStatistics PROC
    push    esi
    push    edi

    ; ----- Part 1: Department Stats -----
    dec     ebx                 ; Convert 1-based to 0-based (0-4)
    mov     edi, ebx
    shl     edi, 2              ; EDI = deptIndex * 4 (DWORD offset)

    inc     DWORD PTR deptCount[edi]    ; deptCount[deptIndex]++
    add     DWORD PTR deptTotal[edi], eax ; deptTotal[deptIndex] += net

    ; Update MIN
    cmp     eax, deptMin[edi]
    jge     SkipMin
    mov     deptMin[edi], eax
SkipMin:

    ; Update MAX
    cmp     eax, deptMax[edi]
    jle     SkipMax
    mov     deptMax[edi], eax
SkipMax:

    ; ----- Part 2: Histogram Brackets -----
    ; Bracket 0: <500 | 1: 500-999 | 2: 1000-1499 | 3: 1500-1999 | 4: 2000+
    mov     esi, 0              ; Start at bracket 0

    cmp     eax, 500
    jl      SetBracket          ; < 500 → bracket 0

    inc     esi                 ; Bracket 1 candidate
    cmp     eax, 1000
    jl      SetBracket          ; 500-999 → bracket 1

    inc     esi                 ; Bracket 2 candidate
    cmp     eax, 1500
    jl      SetBracket          ; 1000-1499 → bracket 2

    inc     esi                 ; Bracket 3 candidate
    cmp     eax, 2000
    jl      SetBracket          ; 1500-1999 → bracket 3

    inc     esi                 ; Bracket 4 (2000+)

SetBracket:
    shl     esi, 2              ; ESI = bracketIndex * 4
    inc     DWORD PTR bracketCount[esi]

    pop     edi
    pop     esi
    ret
UpdateStatistics ENDP


;====================================================================
; MainMenu: Display main menu and read user choice
; Output: EAX = user choice (1-4)
;====================================================================
MainMenu PROC
    MenuLoop:
                            call    Clrscr

                            mov     edx, offset menuTitle                              ;print top border
                            call    WriteString
                            call    Crlf
                            mov     edx, offset menuHeader                             ;print title
                            call    WriteString
                            call    Crlf
                            mov     edx, offset menuTitle                              ;print bottom border
                            call    WriteString
                            call    Crlf

                            mov     edx, offset menu1                                  ;print option 1
                            call    WriteString
                            call    Crlf
                            mov     edx, offset menu2                                  ;print option 2
                            call    WriteString
                            call    Crlf
                            mov     edx, offset menu3                                  ;print option 3
                            call    WriteString
                            call    Crlf
                            mov     edx, offset menu4                                  ;print option 4
                            call    WriteString
                            call    Crlf

                            mov     edx, offset menuPrompt                             ;prompt user for choice
                            call    WriteString
                            call    ReadInt                                            ;read choice

                            cmp     eax, 1                                             ;check if less than 1
                            jl      MenuLoop
                            cmp     eax, 4                                             ;check if greater than 4
                            jg      MenuLoop
                            ret
MainMenu ENDP

;====================================================================
; AddEmployee: Get and validate employee data then store in array
;====================================================================
AddEmployee PROC
                            mov     eax, empCount                                      ;check if array is full
                            cmp     eax, MAX_EMPLOYEES
                            jl      CanAdd
                            mov     edx, offset errFull                                ;display max capacity error
                            call    WriteString
                            call    Crlf
                            ret

CanAdd:
                            ; --- Input Name ---
                            mov     edx, offset promptName
                            call    WriteString
                            mov     edx, offset tempName
                            mov     ecx, 20
                            call    ReadString

                            ; --- Input ID ---
GetID:
                            mov     edx, offset promptID
                            call    WriteString
                            call    ReadInt
                            mov     tempID, eax
                            call    ValidateID
                            cmp     eax, 0
                            je      GetID

                            ; --- Input Dept ---
GetDept:
                            mov     edx, offset promptDept
                            call    WriteString
                            call    ReadInt
mov     tempDept, eax

call    ValidateDepartment
cmp     eax, 0
je      GetDept

                            ; --- Input Salary ---
GetSalary:
                            mov     edx, offset promptSalary
                            call    WriteString
                            call    ReadInt
                            mov     tempSalary, eax
                            call    ValidateSalary
                            cmp     eax, 0
                            je      GetSalary
                            ; --- Input Allowances ---
GetAllow:
                            mov     edx, offset promptAllow
                            call    WriteString
                            call    ReadInt
                            mov     tempAllow, eax
                            call    ValidateAllowances
                            cmp     eax, 0
                            je      GetAllow

                            ; --- Input Deductions ---
GetDeduct:
                            mov     edx, offset promptDeduct
                            call    WriteString
                            call    ReadInt
                            mov     tempDeduct, eax
                            call    ValidateDeductions
                            cmp     eax, 0
                            je      GetDeduct

                            ; --- Calculate Net Salary ---
                            mov     ebx, tempSalary
                            mov     ecx, tempAllow
                            mov     edx, tempDeduct
                            call    CalcNetSalary
                            mov     tempNet, eax

                            ; --- Update Statistics ---
                            mov     ebx, tempDept
                            call    UpdateStatistics

                            ; --- Store in Array ---
                            mov     eax, empCount
                            imul    edi, eax, RECORD_SIZE
                            
                            ; Store Name (offset 0)
                            mov     esi, OFFSET tempName
                            lea     edx, empArray[edi]
                            mov     ecx, 20
CopyNameLoop:
                            mov     al, [esi]
                            mov     [edx], al
                            inc     esi
                            inc     edx
                            loop    CopyNameLoop
                        
                            ; Store ID (offset 20)
                            mov     eax, tempID
                            mov     DWORD PTR empArray[edi + 20], eax
                        
                            ; Store Department (offset 24)
                            mov     eax, tempDept
                            mov     BYTE PTR empArray[edi + 24], al
                        
                            ; Store Basic Salary (offset 28)
                            mov     eax, tempSalary
                            mov     DWORD PTR empArray[edi + 28], eax
                        
                            ; Store Allowances (offset 32)
                            mov     eax, tempAllow
                            mov     DWORD PTR empArray[edi + 32], eax
                        
                            ; Store Deductions (offset 36)
                            mov     eax, tempDeduct
                            mov     DWORD PTR empArray[edi + 36], eax

                            ; Store Net Salary (offset 40)
                            mov     eax, tempNet
                            mov     DWORD PTR empArray[edi + 40], eax

                            ; Increment Counter
                            inc     empCount

                            ; ----- Success Message -----
                            mov     edx, offset successAdd
                            call    WriteString
                            call    Crlf

                            ret
AddEmployee ENDP

;====================================================================
; DisplayPaySlip: Ask for employee ID, find record, print pay slip
;====================================================================
DisplayPaySlip PROC
    push    edi
    push    ecx
    push    eax

    ; Prompt for ID
    mov     edx, OFFSET promptPaySlip
    call    WriteString
    call    ReadInt

    ; Search array
    call    FindEmployeeByID
    cmp     eax, -1
    je      PaySlipNotFound

    ; Compute base offset: index * RECORD_SIZE
    imul    eax, RECORD_SIZE
    mov     edi, eax

    ; ---- Header ----
    call    Crlf
    mov     edx, OFFSET slipBorder
    call    WriteString
    call    Crlf
    mov     edx, OFFSET slipTitle2
    call    WriteString
    call    Crlf
    mov     edx, OFFSET slipBorder
    call    WriteString
    call    Crlf

    ; Name (offset 0)
    mov     edx, OFFSET slipLblName
    call    WriteString
    lea     edx, empArray[edi]
    call    WriteString
    call    Crlf

    ; ID (offset 20)
    mov     edx, OFFSET slipLblID
    call    WriteString
    mov     eax, DWORD PTR empArray[edi + 20]
    call    WriteDec
    call    Crlf

    ; Department (offset 24)
    mov     edx, OFFSET slipLblDept
    call    WriteString
    movzx   eax, BYTE PTR empArray[edi + 24]
    call    WriteDec
    call    Crlf

    mov     edx, OFFSET slipSubLine
    call    WriteString
    call    Crlf

    ; Basic Salary (offset 28)
    mov     edx, OFFSET slipLblBasic
    call    WriteString
    mov     eax, DWORD PTR empArray[edi + 28]
    call    WriteDec
    mov     edx, OFFSET slipJOD
    call    WriteString
    call    Crlf

    ; Allowances (offset 32)
    mov     edx, OFFSET slipLblAllow
    call    WriteString
    mov     eax, DWORD PTR empArray[edi + 32]
    call    WriteDec
    mov     edx, OFFSET slipJOD
    call    WriteString
    call    Crlf

    ; Deductions (offset 36)
    mov     edx, OFFSET slipLblDeduct
    call    WriteString
    mov     eax, DWORD PTR empArray[edi + 36]
    call    WriteDec
    mov     edx, OFFSET slipJOD
    call    WriteString
    call    Crlf

    mov     edx, OFFSET slipSubLine
    call    WriteString
    call    Crlf

    ; Net Salary (offset 40)
    mov     edx, OFFSET slipLblNet
    call    WriteString
    mov     eax, DWORD PTR empArray[edi + 40]
    call    WriteDec
    mov     edx, OFFSET slipJOD
    call    WriteString
    call    Crlf

    ; ---- Tax Bracket ----
    mov     edx, OFFSET slipBorder
    call    WriteString
    call    Crlf
    mov     edx, OFFSET slipLblBracket
    call    WriteString

    mov     eax, DWORD PTR empArray[edi + 40]  ; net salary
    cmp     eax, 500
    jl      ShowBkt1
    cmp     eax, 1000
    jl      ShowBkt2
    cmp     eax, 1500
    jl      ShowBkt3
    cmp     eax, 2000
    jl      ShowBkt4
    mov     eax, 5
    jmp     PrintBkt
ShowBkt1:
    mov     eax, 1
    jmp     PrintBkt
ShowBkt2:
    mov     eax, 2
    jmp     PrintBkt
ShowBkt3:
    mov     eax, 3
    jmp     PrintBkt
ShowBkt4:
    mov     eax, 4
PrintBkt:
    call    WriteDec
    call    Crlf

    mov     edx, OFFSET slipBorder
    call    WriteString
    call    Crlf
    jmp     PaySlipDone

PaySlipNotFound:
    mov     edx, OFFSET errNotFound
    call    WriteString
    call    Crlf

PaySlipDone:
    pop     eax
    pop     ecx
    pop     edi
    ret
DisplayPaySlip ENDP


;====================================================================
; DisplayDepartmentStats: Show stats for all 5 departments
;====================================================================
DisplayDepartmentStats PROC
    call    Clrscr
    mov     edx, OFFSET slipBorder
    call    WriteString
    call    Crlf
    mov     edx, OFFSET statsHeader
    call    WriteString
    call    Crlf
    mov     edx, OFFSET slipBorder
    call    WriteString
    call    Crlf

    mov     esi, 0              ; Department index (0-4)
PrintStatsLoop:
    ; Print "Dept X"
    mov     edx, OFFSET statsLblDept
    call    WriteString
    mov     eax, esi
    inc     eax                 ; Display as 1-5
    call    WriteDec
    call    Crlf

    ; Print Count
    mov     edx, OFFSET statsLblCount
    call    WriteString
    mov     eax, deptCount[esi*4]
    call    WriteDec
    call    Crlf

    ; Print Total
    mov     edx, OFFSET statsLblTotal
    call    WriteString
    mov     eax, deptTotal[esi*4]
    call    WriteDec
    mov     edx, OFFSET slipJOD
    call    WriteString
    call    Crlf

    ; Print Min
    mov     edx, OFFSET statsLblMin
    call    WriteString
    mov     eax, deptMin[esi*4]
    cmp     eax, 99999          ; Check if initialized
    jne     ShowMin
    mov     eax, 0
ShowMin:
    call    WriteDec
    mov     edx, OFFSET slipJOD
    call    WriteString
    call    Crlf

    ; Print Max
    mov     edx, OFFSET statsLblMax
    call    WriteString
    mov     eax, deptMax[esi*4]
    call    WriteDec
    mov     edx, OFFSET slipJOD
    call    WriteString
    call    Crlf

    mov     edx, OFFSET slipSubLine
    call    WriteString
    call    Crlf

    inc     esi
    cmp     esi, 5
    jl      PrintStatsLoop

    call    Crlf
    call    DisplayHistogram    ; Call histogram as part of stats
    ret
DisplayDepartmentStats ENDP

;====================================================================
; DisplayHistogram: Display salary distribution
;====================================================================
DisplayHistogram PROC
    mov     edx, OFFSET slipBorder
    call    WriteString
    call    Crlf
    mov     edx, OFFSET histHeader
    call    WriteString
    call    Crlf
    mov     edx, OFFSET slipBorder
    call    WriteString
    call    Crlf

    mov     esi, 0              ; Bracket index
PrintHistLoop:
    ; Select label based on ESI
    cmp     esi, 0
    je      Lbl1
    cmp     esi, 1
    je      Lbl2
    cmp     esi, 2
    je      Lbl3
    cmp     esi, 3
    je      Lbl4
    mov     edx, OFFSET histBracket5
    jmp     PrintLabel
Lbl1:
 mov edx, OFFSET histBracket1
    jmp     PrintLabel
Lbl2:
 mov edx, OFFSET histBracket2
    jmp     PrintLabel
Lbl3:
 mov edx, OFFSET histBracket3
    jmp     PrintLabel
Lbl4: 
mov edx, OFFSET histBracket4

PrintLabel:
    call    WriteString
    
    ; Print stars
    mov     ecx, bracketCount[esi*4]
    cmp     ecx, 0
    je      NoStars
StarLoop:
    mov     al, '*'
    call    WriteChar
    loop    StarLoop
NoStars:
    call    Crlf
    
    inc     esi
    cmp     esi, 5
    jl      PrintHistLoop

    mov     edx, OFFSET slipBorder
    call    WriteString
    call    Crlf
    ret
DisplayHistogram ENDP


;====================================================================
; main: Program entry point
;====================================================================
main PROC
                            call    Initialize                                         ;initialize all arrays

    MainLoop:
                            call    MainMenu                                           ;display menu and get choice

                            cmp     eax, 1                                             ;check for option 1
                            je      DoAdd
                            cmp     eax, 2                                             ;check for option 2
                            je      DoSlip
                            cmp     eax, 3                                             ;check for option 3
                            je      DoStats
                            cmp     eax, 4                                             ;check for option 4
                            je      DoExit

    DoAdd:
                            call    AddEmployee                                        ;add new employee
                            mov     edx, offset pressKey
                            call    WriteString
                            call    ReadChar
                            jmp     MainLoop

    DoSlip:
                            call    DisplayPaySlip
                            mov     edx, offset pressKey
                            call    WriteString
                            call    ReadChar
                            jmp     MainLoop

    DoStats:
                            call    DisplayDepartmentStats
                            mov     edx, offset pressKey
                            call    WriteString
                            call    ReadChar
                            jmp     MainLoop

    DoExit:
                            exit

main ENDP
END main
