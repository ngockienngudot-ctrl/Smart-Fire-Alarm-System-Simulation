import os
from cocotb_tools.runner import get_runner

def run_simulation():
    sim = os.getenv("SIM", "icarus")
    proj_path = os.getcwd()
    
    # Liệt kê tất cả các file phần cứng Verilog của nhóm
    sources = [
        os.path.join(proj_path, "system_top.v"),
        os.path.join(proj_path, "synchronizer.v"),
        os.path.join(proj_path, "moving_average_filter.v"),
        os.path.join(proj_path, "fire_alarm_fsm.v"),
        os.path.join(proj_path, "signal_stabilizer.v"),
        os.path.join(proj_path, "flame_monitor.v")
    ]
    
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="system_top", # Bo mạch chủ
        always=True,
    )
    
    # Khởi chạy file cầu nối Python
    runner.test(
        hdl_toplevel="system_top",
        test_module="sim_bridge", 
    )

if __name__ == "__main__":
    run_simulation()