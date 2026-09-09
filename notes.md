## Things to still Understand

[tb_control_unit.v](file:///e:/Clent/Learning/Mini-RV32I/tb_control_unit.v) aapka **"Testing Inspector" (Examiner)** hai.

Iska ek hi kaam hai: **Control Unit ko alag-alag instructions ke "dummy samples" dena aur check karna ki kya Control Unit ne sahi switches on/off kiye ya nahi.**

Chaliye is file ko 3 simple parts mein samajhte hain:

---

### Part 1: Setup aur Wiring (Lines 1–33)

```verilog
reg [6:0] opcode;
reg [2:0] funct3;
reg [6:0] funct7;
wire reg_write;
...
control_unit uut ( ... );
```

1. **`reg` vs `wire` ka Logic:**
   - Jo cheez **Testbench apne haath se badlega** (Inputs: `opcode`, `funct3`, `funct7`), unhe `reg` banaya.
   - Jo Control Unit se **nateeja (Output) bahar aayega**, unhe dekhne ke liye `wire` banaya.
2. **`control_unit uut`:** Yeh aapke original module ko testbench ke andar laakar wire-up kar raha hai (`uut` = Unit Under Test).
3. **`$dumpfile` aur `$dumpvars`:** Yeh simulation ki picture (waves) record karta hai taaki aap baad mein wave viewer (EPWave / GTKWave) par graph dekh sakein.

---

### Part 2: Ek-ek Test ka Logic (Asli Testing)

Yahan testbench ek ke baad ek 6 alag-alag real instructions banakar Control Unit ko test kar raha hai:

#### 1. Test: R-Type `ADD` (`add x1, x2, x3`)

- **Action:** `opcode` aur `funct` bheje addition ke liye. `#10` (10 nanosecond ka wait kiya taaki circuit process kar le).
- **Check kya kar raha hai?**
  - Kya `RegWrite = 1` hua? (Kyunki result register mein save karna hai).
  - Kya `ALUSrc = 0` hua? (Kyunki dusra operand register se aana chahiye).
  - Kya `ALUCtrl = 0000` aaya? (ALU ko addition ka order mila ya nahi).

---

#### 2. Test: R-Type `SUB` (`sub x1, x2, x3`)

- **Action:** Is baar `funct7` mein subtraction wali bit `1` karke bhej di.
- **Check kya kar raha hai?**
  - Kya Control Unit ne `funct7` ko dhyan se dekha aur `ALUCtrl = 0001` (SUB) ka order diya?

---

#### 3. Test: I-Type `ADDI` (`addi x1, x2, 10`)

- **Action:** I-Type ka opcode bheja (`0010011`).
- **Check kya kar raha hai?**
  - Yahan sabse zaroori cheez hai: **`ALUSrc = 1`** hona chahiye!
  - Testbench yeh dekh raha hai ki kya Control Unit ne ALU ko bola ki *"Ab register se nahi, number (10) se add karo!"*

---

#### 4. Test: LOAD (`lw x1, 8(x2)`)

- **Action:** Memory Load ka opcode bheja (`0000011`).
- **Check kya kar raha hai?**
  - RAM ka address nikalne ke liye base address mein 8 jodna padega.
  - Toh kya ALU ko `ALUCtrl = 0000` (ADD) ka signal mila?

---

#### 5. Test: STORE (`sw x1, 8(x2)`)

- **Action:** Memory Store ka opcode bheja (`0100011`).
- **Check kya kar raha hai?**
  - Kya `MemRead = 0` aur **`MemWrite = 1`** hua? (Kyunki RAM ke andar data likhna hai, padhna nahi).

---

#### 6. Test: BRANCH (`beq x1, x2, Loop`)

- **Action:** Branch ka opcode bheja (`1100011`).
- **Check kya kar raha hai?**
  - Kya **`Branch = 1`** ka signal high hua?
  - Aur kya ALU ko `0001` (SUB) ka order mila taaki wo check kar sake ki dono numbers barabar hain ya nahi?

---

### Part 3: `$finish;` (Line 77)

Jab saari instructions test ho gayi, toh `$finish` simulator ko bolta hai: *"Testing khatam, ab report band kar do!"*

**Nateeja:**
Yeh testbench terminal par `$display` ke through har test ka **Actual Result** aur **Expected Result** print karega, jisse aap ek nazar mein dekh sakein ki har instruction par CPU ka dimaag sahi kaam kar raha hai!
