`timescale 1ns / 1ps

module signal_stabilizer #(
    parameter FILTER_LIMIT = 500  // Độ trễ lọc (ví dụ: 500 chu kỳ clock)
)(
    input wire clk,            // Clock hệ thống (ví dụ 50MHz)
    input wire reset_n,        // Reset tích cực mức thấp
    input wire raw_signal,     // Tín hiệu thô từ bên ngoài (cảm biến/nút nhấn)
    output reg clean_signal    // Tín hiệu đã được lọc và đồng bộ
);

    //---------------------------------------------------------
    // 1. GIAI ĐOẠN ĐỒNG BỘ HÓA (2-Stage Synchronizer)
    //---------------------------------------------------------
    reg sync_reg1, sync_reg2;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sync_reg1 <= 0;
            sync_reg2 <= 0;
        end else begin
            sync_reg1 <= raw_signal; // Tầng 1: Bắt tín hiệu không đồng bộ
            sync_reg2 <= sync_reg1;   // Tầng 2: Ổn định tín hiệu theo clk
        end
    end

    //---------------------------------------------------------
    // 2. GIAI ĐOẠN LỌC NHIỄU (Digital Debounce Filter)
    //---------------------------------------------------------
    reg [15:0] counter; // Bộ đếm độ trễ

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 0;
            clean_signal <= 0;
        end else begin
            // Nếu tín hiệu đầu vào khác với tín hiệu đầu ra hiện tại
            if (sync_reg2 != clean_signal) begin
                // Nếu tín hiệu giữ nguyên đủ lâu (vượt ngưỡng FILTER_LIMIT)
                if (counter >= (FILTER_LIMIT - 1)) begin
                    clean_signal <= sync_reg2; // Cập nhật trạng thái mới
                    counter <= 0;              // Reset bộ đếm
                end else begin
                    counter <= counter + 1;    // Tiếp tục đếm kiểm tra độ ổn định
                end
            end else begin
                // Tín hiệu ổn định hoặc trùng khớp, reset bộ đếm về 0
                counter <= 0;
            end
        end
    end

endmodule
