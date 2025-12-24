# Reaction Time Game – Verilog on DE10-Lite

An interactive reaction-time game implemented in **Verilog** and deployed on the **DE10-Lite FPGA** using **Intel Quartus Prime**.  
The game lights up one of two LEDs, and the player must press the correct push button before the LED turns off to score points.

---

## Gameplay Overview
- Two LEDs are reaction targets
- Two push buttons correspond to each LED
- Press the correct button while the LED is ON → **+1 point**
- Miss or press incorrectly → **−1 point**
- Score ranges from **00 to 99** and updates live on the **HEX seven-segment displays**
- Game can be stopped anytime using **Switch 9**, which also resets the score

---

## Timing & Difficulty
- LED activation starts at **1.5s**, decreasing as score increases
- Minimum activation time is **0.3s** at score ≥ 32
- Random delay between LED activations:
  - Generated using a **32-bit shift-register random number generator**
  - Samples bits `[3:0]` each clock cycle
  - Chooses randomly between:
    - 0.25s  
    - 0.50s  
    - 1.00s  
    - 1.50s  
- Randomization prevents predictability and keeps gameplay fair

---

## Hardware Mapping
- **LEDs**
  - `LEDR[0]` → LEDR6  
  - `LEDR[1]` → LEDR5  
- **Push Buttons**
  - `KEY[0]`, `KEY[1]`
- **Seven-Segment Display**
  - `HEX0` → Ones digit  
  - `HEX1` → Tens digit  

---

## Architecture

### 🔹 Top-Level
**`ReactionGame.v`**  
Integrates the game controller, random generator, input edge detection, and display logic.  
Reset switch freezes the game and clears the score.

---

### 🔹 Random Generator
**`RandomGen.v`**
- 32-bit shift register with XOR feedback taps
- Produces:
  - Random LED selection
  - Random idle interval duration

---

### 🔹 Game Controller
**`GameController.v`**
- Finite State Machine controlling:
  - LED activation
  - Timing windows
  - Score calculation

Key states include:
- **Off**
- **Wait**
- **On**
- **Active**
- **Result**

---

### 🔹 Seven-Segment Display
**`bin2bcd.v`** and **`lab2.v`**
- Convert binary score to BCD
- Drive HEX displays in real time

---

## ✅ What This Project Demonstrates
- FPGA-based digital system design
- Finite State Machines
- Timing and delay control
- Hardware randomization techniques
- Real-time visual output
- Clean modular Verilog architecture

---

**Author:** Mazen Rashrash
