# 💼 Employee Salary Management System (ESMS)
 
> A console-based payroll management application written in **x86 MASM Assembly** using the Irvine32 library.
 
---
 
## 👥 Authors
 
| Name | 
|------|
| [Mohammad Shaqboua](https://github.com/Mohammadshaqboua) |
| [Mohammad Dawas](https://github.com/DAWAS00) |
| [Husam Ziadeh](https://github.com/husamziadeh2005) |
 
---
 
## 📋 Overview
 
ESMS is a fully functional employee payroll system built in low-level x86 Assembly. It supports storing up to **50 employee records**, performs full input validation, calculates net salaries, and generates detailed pay slips and department statistics — all through a clean console menu.
 
---
 
## ✨ Features
 
- **Add Employees** — Capture name, ID, department, salary, allowances, and deductions with full validation
- **Pay Slip Display** — Formatted pay slip with tax bracket classification per employee
- **Department Statistics** — Per-department count, total payroll, min/max salary
- **Salary Histogram** — Visual star-based distribution across 5 salary brackets
- **Input Validation** — All fields are range-checked with error messages on bad input
---
 
## 🗂️ Record Structure
 
Each employee record is **44 bytes**, stored in a flat array:
 
| Offset | Size | Field |
|--------|------|-------|
| 0 | 20 bytes | Name (string) |
| 20 | 4 bytes | Employee ID (DWORD) |
| 24 | 1 byte | Department Code (BYTE) |
| 28 | 4 bytes | Basic Salary (DWORD) |
| 32 | 4 bytes | Allowances (DWORD) |
| 36 | 4 bytes | Deductions (DWORD) |
| 40 | 4 bytes | Net Salary (DWORD) |
 
---
 
## ✅ Validation Rules
 
| Field | Valid Range |
|-------|-------------|
| Employee ID | 100000 – 999999 (6 digits) |
| Department | 1 – 5 |
| Basic Salary | 500 – 20,000 JOD |
| Allowances | 0 – 5,000 JOD |
| Deductions | 0 – 3,000 JOD |
 
---
 
## 💰 Salary Formula
 
```
Net Salary = Basic Salary + Allowances - Deductions
```
 
---
 
## 📊 Tax Brackets
 
| Bracket | Net Salary Range |
|---------|-----------------|
| 1 | < 500 JOD |
| 2 | 500 – 999 JOD |
| 3 | 1,000 – 1,499 JOD |
| 4 | 1,500 – 1,999 JOD |
| 5 | ≥ 2,000 JOD |
 
---
 
## 🛠️ Requirements
 
- **Assembler:** MASM (Microsoft Macro Assembler)
- **Library:** [Irvine32](http://asmirvine.com/) — must be installed and linked
- **OS:** Windows (32-bit or 32-bit compatible mode)
- **IDE:** Visual Studio or any MASM-compatible build environment
---
 
## 🚀 Getting Started
 
1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/esms-assembly.git
   cd esms-assembly
   ```
 
2. **Set up Irvine32**  
   Download and install the [Irvine32 library](http://asmirvine.com/gettingStartedVS2019/index.htm) and configure your include/lib paths.
3. **Build and run**  
   Open the project in Visual Studio, set the build target to **x86 Release**, and press **Run**.
---

