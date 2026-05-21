module flame_monitor (
    input wire clk,
    input wire reset_n,
    input wire [9:0] ir_data, // Dữ liệu từ ADC
    output reg [7:0] hz_out,
    output reg fire_alarm
);

    // --- 1. KHAI BÁO CÁC THAM SỐ VÀ BIẾN NỘI BỘ ---
    parameter ONE_SECOND_LIMIT = 50_000_000;
    
    // Tạo một dây dẫn để chứa tín hiệu đã được làm sạch
    wire ir_signal_clean; 
    
    // Giả sử bạn có một logic so sánh ngưỡng để tạo ra tín hiệu thô (1-bit)
    wire raw_ir_input = (ir_data > 512); 

    // --- 2. CHÈN MODULE LỌC VÀO ĐÂY ---
     signal_stabilizer #( .FILTER_LIMIT(1000) ) filter_inst (
        .clk(clk),
        .reset_n(reset_n),
        .raw_signal(raw_ir_input), // Lấy tín hiệu thô
        .clean_signal(ir_signal_clean) // Xuất ra tín hiệu sạch
    );

    // --- 3. LOGIC XỬ LÝ CHÍNH ---
    reg [25:0] timer_cnt;
    reg [7:0]  pulse_cnt;

    always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        // Reset logic: Bắt buộc phải đưa các bộ đếm về 0 khi khởi động
        timer_cnt <= 26'd0;
        pulse_cnt <= 8'd0;
    end else begin
        // QUAN TRỌNG: Thay vì dùng raw_ir_input,
        // sử dụng ir_signal_clean để đếm xung hồng ngoại (đã xóa điều kiện state ảo)
        if (ir_signal_clean) begin
            pulse_cnt <= pulse_cnt + 1;
        end
    end
end

endmodule
