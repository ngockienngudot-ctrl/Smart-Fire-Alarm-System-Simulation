`timescale 1ns / 1ps

module system_top (
    input wire clk,                  // Xung nhịp hệ thống
    input wire rst_n,                // Reset tích cực mức thấp
    
    // Tín hiệu thô từ môi trường (Đầu vào cho Python/Pygame điều khiển)    
    input wire raw_smoke,            // Khói thô (1-bit)
    input wire raw_manual,           // Nút khẩn cấp thô (1-bit)
    input wire [7:0] raw_temp,       // Nhiệt độ thô 8-bit từ ADC
    input wire [7:0] raw_gas,        // Nồng độ gas thô 8-bit từ ADC
    input wire [9:0] raw_ir_data,    // Dữ liệu hồng ngoại ngọn lửa 10-bit từ ADC

    // Ngõ ra điều khiển hệ thống (Đầu ra để Pygame đọc và vẽ đồ họa)
    output wire sys_alarm_bell,      // Chuông báo hệ thống
    output wire sys_sprinkler,       // Vòi phun nước
    output wire sys_warning_led,     // Đèn LED cảnh báo
    output wire [1:0] current_state_out // Xuất trạng thái FSM ra cho Python theo dõi
);

    // Ngưỡng so sánh cho các cảm biến
    parameter TEMP_THRESHOLD = 8'd68;
    parameter GAS_THRESHOLD  = 8'd50;

    // Dây nối nội bộ giữa các module
    wire sync_smoke;
    wire sync_manual;
    wire [7:0] clean_temp;
    wire [7:0] clean_gas;
    
    wire temp_alert_internal;
    wire gas_alert_internal;
    wire flame_alert_internal;
    
    wire final_temp_or_flame_alert; // Cờ gộp giữa Nhiệt độ và Ngọn lửa

    // 1. Đồng bộ hóa các tín hiệu nút bấm/cảm biến On-Off (Module 1)
    synchronizer sync_smoke_inst (
        .clk(clk), .rst_n(rst_n), .async_in(raw_smoke), .sync_out(sync_smoke)
    );
    synchronizer sync_manual_inst (
        .clk(clk), .rst_n(rst_n), .async_in(raw_manual), .sync_out(sync_manual)
    );

    // 2. Lọc số làm mịn dữ liệu Analog Nhiệt độ & Gas (Module 2)
    moving_average_filter filter_temp_inst (
        .clk(clk), .rst_n(rst_n), .data_in(raw_temp), .data_out(clean_temp)
    );
    moving_average_filter filter_gas_inst (
        .clk(clk), .rst_n(rst_n), .data_in(raw_gas), .data_out(clean_gas)
    );

    // 3. Giám sát tần số ngọn lửa từ ADC Hồng ngoại (Module Phần IV)
    flame_monitor flame_monitor_inst (
        .clk(clk),
        .reset_n(rst_n),
        .ir_data(raw_ir_data),
        .hz_out(), // Không cần dùng ngõ ra tần số thuần ở đây
        .fire_alarm(flame_alert_internal)
    );

    // 4. Logic so sánh ngưỡng tạo cờ cảnh báo
    assign temp_alert_internal = (clean_temp > TEMP_THRESHOLD);
    assign gas_alert_internal  = (clean_gas > GAS_THRESHOLD);
    
    // Gộp cờ: Hệ thống coi như có cảnh báo nhiệt nếu Nhiệt cao HOẶC Phát hiện ngọn lửa
    assign final_temp_or_flame_alert = temp_alert_internal || flame_alert_internal;

    // 5. Kết nối toàn bộ vào Bộ não FSM (Module 3)
    fire_alarm_fsm fsm_core_inst (
        .clk(clk),
        .rst_n(rst_n),
        .smoke_alert(sync_smoke),
        .temp_alert(final_temp_or_flame_alert), // Nhận cờ đã gộp
        .gas_alert(gas_alert_internal),
        .manual_call(sync_manual),
        .alarm_bell(sys_alarm_bell),
        .sprinkler(sys_sprinkler),
        .warning_led(sys_warning_led)
    );

    // Xuất trạng thái hiện tại của FSM ra ngoài chip để Python đọc trực tiếp
    assign current_state_out = fsm_core_inst.current_state;

endmodule