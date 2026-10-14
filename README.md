# 🔥 Smart Fire Alarm System Co-Simulation

## 📌 Overview
This project is a hardware-software co-simulation of a Smart Fire Alarm System. It combines **Verilog HDL** for core hardware logic and signal processing with a **Python (Pygame)** graphical interface for real-time interaction. The communication between the software GUI and the hardware simulation is handled via **Cocotb**.

## 📂 Project Structure & Core Files

### 1. Hardware Modules (Verilog)
- `system_top.v`: The top-level module connecting all sub-modules and exposing ports to Python.
- `fire_alarm_fsm.v`: The FSM controller managing 3 states (`NORMAL`, `WARNING`, `ALARM`) and pulse alarm generation.
- `moving_average_filter.v`: A 4-tap moving average filter applied to 8-bit continuous data (Temperature and Gas).
- `signal_stabilizer.v`: A digital debounce filter to stabilize discrete signals based on a parameter `FILTER_LIMIT`.
- `synchronizer.v`: A 2-stage synchronizer (`q1`, `sync_out`) to safely bring asynchronous inputs into the clock domain.
- `flame_monitor.v`: Processes 10-bit infrared data (`ir_data`), applies the signal stabilizer, and counts a timer delay (`FLAME_DELAY_LIMIT`) to confirm a fire.
- `tb_system_top.v`: A traditional Verilog testbench generating waveforms (`waveform.vcd`) to verify edge cases.

### 2. Software & Simulation Bridge (Python)
- `main_gui.py`: The Pygame-based dashboard rendering environmental metrics and hardware outputs (LED, Bell, Sprinkler, FSM state).
- `sim_bridge.py`: The Cocotb testtestbench that drives clock signals and maps Pygame keyboard events to Verilog input ports.
- `run.py`: The execution script that compiles Verilog files using Icarus Verilog via `cocotb_tools.runner` and launches the simulation.

### 3. Config Files
- `circuit-4.digitaljs`: Circuit schematic data for DigitalJS.
- `.gitignore`: Ignores `sim_build/` and `__pycache__/`.

## 🔄 Data Flow Architecture
1. **Input Generation:** User presses keys in Pygame (`main_gui.py`) to adjust temperature, gas, smoke, flame, or manual emergency.
2. **Bridge Transfer:** `sim_bridge.py` reads these values and updates the Verilog test signals (`raw_temp`, `raw_gas`, `raw_smoke`, `raw_ir_data`, `raw_manual`).
3. **Signal Conditioning:**
   - Asynchronous buttons/smoke pass through `synchronizer.v`.
   - Continuous 8-bit data (Temp, Gas) pass through `moving_average_filter.v`.
   - Infrared data passes through `flame_monitor.v` (which uses `signal_stabilizer.v` and a timer).
4. **Decision Making:** Cleaned and threshold-checked signals enter `fire_alarm_fsm.v` to update states and outputs (Bell, Sprinkler, LED).
5. **Feedback Loop:** `sim_bridge.py` reads the output signals and state (`current_state_out`) back into Pygame to update the GUI at 30 FPS.

## ⚙️ FSM Thresholds & Logic
- **Temperature Threshold:** `TEMP_THRESHOLD = 8'd68` (in `system_top.v`)
- **Gas Threshold:** `GAS_THRESHOLD = 8'd50` (in `system_top.v`)
- **States:**
  - `NORMAL (2'b00)`: Default monitoring state.
  - `WARNING (2'b01)`: Triggered by temperature > 68, gas > 50, or initial anomalies. Activates Warning LED and pulsing alarm bell if gas is detected.
  - `ALARM (2'b10)`: Triggered by manual call (`manual_call`), sustained smoke (after `SMOKE_DELAY_LIMIT`), or confirmed flame. Activates continuous LED, Sprinkler, and Bell. Once in ALARM, it stays until a hardware reset (`rst_n`).

## 💻 How to Run Locally

### Prerequisites
- Python 3.x
- Icarus Verilog (`iverilog`)
- Python packages:
```bash
  pip install pygame cocotb cocotb-bus
```

### Execution
1. Clone the repository:
```bash
   git clone https://github.com/ngockienngudot-ctrl/Smart-Fire-Alarm-System-Simulation.git
   cd Smart-Fire-Alarm-System-Simulation
```

2. Run the simulation:
```bash
   python run.py
```

3. GUI Controls:
   - **↑ / ↓**: Adjust temperature
   - **← / →**: Adjust gas concentration
   - **K**: Toggle smoke sensor
   - **L**: Toggle infrared flame sensor
   - **E**: Trigger manual emergency button
   - **R**: Hard Reset (rst_n)


