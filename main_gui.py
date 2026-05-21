import pygame
import sys

# Các biến toàn cục để Cocotb lấy dữ liệu truyền xuống Verilog
sim_temp = 25
sim_smoke = 0
sim_gas = 10
sim_flame = 0
sim_manual = 0

pygame.init()
screen = pygame.display.set_mode((800, 600))
pygame.display.set_caption("Mô phỏng Báo Cháy - HUST")
font = pygame.font.SysFont("Times New Roman", 24)

def draw_ui(outputs):
    screen.fill((240, 240, 240)) # Nền xám nhạt
    
    # Vẽ các thông số môi trường hiện tại
    texts = [
        f"Nhiệt độ (Tăng/Giảm bằng phím Mũi tên Lên/Xuống): {sim_temp}°C",
        f"Nồng độ Gas (Phím Trái/Phải): {sim_gas}",
        f"Có Khói (Phím K): {'CÓ' if sim_smoke else 'KHÔNG'}",
        f"Có Lửa hồng ngoại (Phím L): {'CÓ' if sim_flame else 'KHÔNG'}",
        f"Nút khẩn cấp (Phím E): {'ĐÃ NHẤN' if sim_manual else 'BÌNH THƯỜNG'}"
    ]
    
    for i, t in enumerate(texts):
        surface = font.render(t, True, (0, 0, 0))
        screen.blit(surface, (20, 20 + i*40))

    # Vẽ trạng thái phản hồi từ mạch Verilog
    state_str = ["BÌNH THƯỜNG", "CẢNH BÁO", "CHÁY!"]
    try:
        current_st = state_str[outputs['state']]
    except:
        current_st = "UNKNOWN"

    pygame.draw.rect(screen, (200, 200, 200), (20, 250, 750, 200))
    st_surf = font.render(f"Trạng thái FSM: {current_st}", True, (0, 0, 255))
    screen.blit(st_surf, (40, 270))

    # Vẽ Đèn, Chuông, Bơm nước
    pygame.draw.circle(screen, (255, 0, 0) if outputs['led'] else (100, 100, 100), (100, 360), 30)
    screen.blit(font.render("ĐÈN LED", True, (0,0,0)), (60, 400))

    pygame.draw.circle(screen, (255, 165, 0) if outputs['bell'] else (100, 100, 100), (300, 360), 30)
    screen.blit(font.render("CHUÔNG", True, (0,0,0)), (260, 400))

    pygame.draw.circle(screen, (0, 0, 255) if outputs['sprinkler'] else (100, 100, 100), (500, 360), 30)
    screen.blit(font.render("MÁY BƠM", True, (0,0,0)), (450, 400))

    pygame.display.flip()

def process_events():
    global sim_temp, sim_gas, sim_smoke, sim_flame, sim_manual
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_UP: sim_temp = min(255, sim_temp + 5)
            if event.key == pygame.K_DOWN: sim_temp = max(0, sim_temp - 5)
            if event.key == pygame.K_RIGHT: sim_gas = min(255, sim_gas + 5)
            if event.key == pygame.K_LEFT: sim_gas = max(0, sim_gas - 5)
            if event.key == pygame.K_k: sim_smoke = 1 - sim_smoke
            if event.key == pygame.K_l: sim_flame = 1 - sim_flame
            if event.key == pygame.K_e: sim_manual = 1 - sim_manual