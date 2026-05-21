import pygame
import cocotb
from cocotb.triggers import Timer, FallingEdge
import main_gui 

async def generate_clock(dut):
    """Tạo xung nhịp clk cho mạch"""
    while True:
        dut.clk.value = 0
        await Timer(10, "ns") # Đã bỏ chữ units= để tắt cảnh báo vàng
        dut.clk.value = 1
        await Timer(10, "ns")

@cocotb.test()
async def test_fire_alarm_system(dut):
    """Kịch bản chạy liên tục để nối Verilog với Pygame"""
    cocotb.start_soon(generate_clock(dut))
    
    dut.rst_n.value = 0
    await Timer(40, "ns")
    dut.rst_n.value = 1
    await Timer(20, "ns")
    
    # Thêm đồng hồ để khống chế nhịp độ (FPS) của cửa sổ giao diện
    clock = pygame.time.Clock()
    
    while True:
        # Bắt sự kiện của Windows để chống đơ cửa sổ
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                return

        # Đọc thao tác phím
        keys = pygame.key.get_pressed()
        dut.rst_n.value = 0 if keys[pygame.K_r] else 1  
        if keys[pygame.K_UP]: main_gui.sim_temp = min(main_gui.sim_temp + 1, 255)
        if keys[pygame.K_DOWN]: main_gui.sim_temp = max(main_gui.sim_temp - 1, 0)
        if keys[pygame.K_RIGHT]: main_gui.sim_gas = min(main_gui.sim_gas + 1, 255)
        if keys[pygame.K_LEFT]: main_gui.sim_gas = max(main_gui.sim_gas - 1, 0)
        main_gui.sim_smoke = 1 if keys[pygame.K_k] else 0
        main_gui.sim_manual = 1 if keys[pygame.K_e] else 0
        main_gui.sim_flame = 1 if keys[pygame.K_l] else 0
        
        dut.raw_smoke.value = main_gui.sim_smoke
        dut.raw_manual.value = main_gui.sim_manual
        dut.raw_temp.value = main_gui.sim_temp
        dut.raw_gas.value = main_gui.sim_gas
        dut.raw_ir_data.value = 600 if main_gui.sim_flame else 0 
        
        # SỬA LỖI ĐƠ: Chỉ bắt mạch Verilog tính toán 100 micro-giây (us) = 10.000 chu kỳ
        # CPU xử lý rất nhẹ nhàng, đủ để mạch cập nhật trạng thái
        await Timer(100, "us")
        
        if dut.sys_alarm_bell.value.is_resolvable:
            outputs = {
                "bell": int(dut.sys_alarm_bell.value),
                "sprinkler": int(dut.sys_sprinkler.value),
                "led": int(dut.sys_warning_led.value),
                "state": int(dut.current_state_out.value)
            }
            
            main_gui.draw_ui(outputs)
            pygame.display.flip()
            
        # Giới hạn Pygame chạy ở 30 khung hình/giây (Để CPU nghỉ ngơi thực sự)
        clock.tick(30)