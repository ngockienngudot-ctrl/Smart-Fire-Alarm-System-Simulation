module flame_monitor (
    input wire clk,           // Clock hệ thống
    input wire reset_n,       // Reset tích cực mức thấp
    input wire [9:0] ir_data, // Dữ liệu ADC từ cảm biến
    output reg [7:0] hz_out,  // Giữ nguyên cổng này để không báo lỗi ở file top
    output reg fire_alarm     // Cờ báo cháy (1 = Có lửa)
);

    wire ir_signal_clean;
    wire raw_ir_input = (ir_data > 512); 

    // --- 1. MODULE LỌC NHIỄU (Giữ nguyên) ---
    signal_stabilizer #( .FILTER_LIMIT(1000) ) filter_inst (
        .clk(clk),
        .reset_n(reset_n),
        .raw_signal(raw_ir_input),
        .clean_signal(ir_signal_clean)
    );

    // --- 2. LOGIC MỚI: NHẤN GIỮ LIÊN TỤC (Giống cảm biến khói) ---
    reg [31:0] flame_timer; 
    
    // Giới hạn thời gian chờ. Bạn có thể copy con số từ biến SMOKE_DELAY_LIMIT 
    // bên file fire_alarm_fsm.v sang đây để thời gian chờ 2 phím là như nhau.
    parameter FLAME_DELAY_LIMIT = 32'd20000; 

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Khi reset: Xóa bộ đếm và tắt báo động
            flame_timer <= 32'd0;
            fire_alarm  <= 1'b0;
            hz_out      <= 8'd0; // Bỏ tính năng đo Hz, gán cứng bằng 0
        end else begin
            
            // Nếu phát hiện tia hồng ngoại (đã qua lọc nhiễu)
            if (ir_signal_clean == 1'b1) begin
                
                // Cặm cụi đếm lên
                if (flame_timer < FLAME_DELAY_LIMIT) begin
                    flame_timer <= flame_timer + 1'b1;
                end else begin
                    // Nếu giữ đủ lâu, bật cờ báo cháy
                    fire_alarm <= 1'b1;
                end

            end else begin
                // NGAY KHI NHẢ TAY (ir_signal_clean == 0)
                // Lập tức reset toàn bộ bộ đếm và tắt cờ báo cháy
                flame_timer <= 32'd0;
                fire_alarm  <= 1'b0;
            end
            
        end
    end
endmodule