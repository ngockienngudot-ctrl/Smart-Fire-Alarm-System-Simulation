## 🔥 Smart Fire Alarm System Co-Simulation

## 📌 Overview
This project is a hardware-software co-simulation of a Smart Fire Alarm System. It combines **Verilog HDL** for core hardware logic and signal processing with a **Python (Pygame)** graphical interface for real-time interaction. The communication between the software GUI and the hardware simulation is seamlessly handled by **Cocotb**.

Rather than a simple logic circuit, this system mimics real-world data pipelines: capturing raw analog/digital inputs, filtering out noise, making state-based decisions, and returning visual outputs.

## 📂 Project Structure & Core Files
The system is highly modularized into 12 specific files. Here is what each file does:

### 1. Hardware Modules (Verilog)
- `system_top.v`: The top-level module that wires all sub-modules together.
- `fire_alarm_fsm.v`: The "brain" of the system. A Finite State Machine with 3 states (NORMAL, WARNING, ALARM) that evaluates filtered sensor data to trigger the bell, sprinkler, or LED.
- `moving_average_filter.v`: A 4-tap moving average DSP filter to smooth out continuous 8-bit analog data (Temperature and Gas).
- `signal_stabilizer.v`: A digital debounce filter to eliminate physical noise from discrete inputs (Infrared signals).
- `synchronizer.v`: A 2-stage flip-flop synchronizer to safely bring asynchronous external button presses into the system's clock domain.
- `flame_monitor.v`: Processes infrared data and applies a timer delay to confirm the presence of a real fire before triggering an alert.
- `tb_system_top.v`: A traditional Verilog testbench used to simulate edge cases and generate `.vcd` waveforms for logic verification.

### 2. Software & Simulation Bridge (Python)
- `main_gui.py`: The Pygame-based dashboard. It reads keyboard events to simulate environmental changes (e.g., rising temperature, smoke) and draws the system's real-time hardware status.
- `sim_bridge.py`: The Cocotb testbench. It acts as the bridge, ticking the hardware clock and passing data back and forth between `main_gui.py` and `system_top.v` at a controlled FPS to prevent CPU overload.
- `run.py`: The execution script that automatically compiles the Verilog files using Icarus Verilog and attaches the Cocotb bridge.

### 3. Config Files
- `circuit-4.digitaljs`: Circuit schematic data for DigitalJS visualization.
- `.gitignore`: Ignores compilation artifacts like `sim_build/` and `__pycache__/`.

## 🔄 Data Flow Architecture
1. **Input Generation:** User presses keys on the Pygame GUI (`main_gui.py`) to simulate raw sensor values.
2. **Bridge Transfer:** `sim_bridge.py` captures these values and drives the Verilog `system_top` ports.
3. **Signal Cleaning:** 
   - Discrete signals (Smoke, Manual Button) pass through `synchronizer.v`.
   - Continuous signals (Temp, Gas) pass through `moving_average_filter.v`.
4. **Decision Making:** Clean data enters `fire_alarm_fsm.v` to determine the next safety state.
5. **Output Visualization:** Output signals (Bell, LED, Sprinkler) are read by `sim_bridge.py` and sent back to `main_gui.py` to update the graphics.

## 💻 How to Run Locally

### Prerequisites
Make sure you have the following installed:
- Python 3.x
- `pygame` and `cocotb` (install via `pip install pygame cocotb cocotb-bus`)
- Icarus Verilog (`iverilog`)

### Execution
1. Clone the repository:
   ```bash
   git clone [https://github.com/ngockienngudot-ctrl/Smart-Fire-Alarm-System-Simulation.git](https://github.com/ngockienngudot-ctrl/Smart-Fire-Alarm-System-Simulation.git)
   cd Smart-Fire-Alarm-System-Simulation
   
2. Run the simulation:
   ```bash
   python run.py

3. GUI Controls:
  - Up/Down Arrows: Adjust Temperature
  - Left/Right Arrows: Adjust Gas Concentration
  - K: Toggle Smoke Sensor
  - L: Toggle Infrared Flame Sensor
  - E: Trigger Manual Emergency Button




