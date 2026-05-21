module moving_average_filter (
    input clk,          // Xung nhịp hệ thống
    input rst_n,        // Reset hệ thống
    input [7:0] data_in,// Dữ liệu 8-bit đầu vào từ cảm biến (nhiệt độ/gas)
    output [7:0] data_out // Dữ liệu 8-bit sau khi đã lọc mịn
);
    reg [7:0] tap0, tap1, tap2, tap3; // 4 thanh ghi lưu trữ 4 mẫu dữ liệu gần nhất
    wire [9:0] sum;                   // Biến 10-bit để chứa tổng (tránh tràn số khi cộng 4 số 8-bit)

    always @(posedge clk or negedge rst_n) begin // Hoạt động theo nhịp clock
        if (!rst_n) begin             // Khi reset
            tap0 <= 8'd0; tap1 <= 8'd0; tap2 <= 8'd0; tap3 <= 8'd0; // Xóa toàn bộ mẫu về 0
        end else begin                // Khi hoạt động
            tap0 <= data_in;          // Đưa mẫu mới nhất vào tap0
            tap1 <= tap0;             // Đẩy mẫu cũ từ tap0 sang tap1
            tap2 <= tap1;             // Đẩy mẫu cũ từ tap1 sang tap2
            tap3 <= tap2;             // Đẩy mẫu cũ từ tap2 sang tap3
        end
    end

    // Tính tổng 4 mẫu (Nối thêm 2 bit 0 ở đầu để mở rộng từ 8-bit lên 10-bit)
    assign sum = {2'b00, tap0} + {2'b00, tap1} + {2'b00, tap2} + {2'b00, tap3};
    // Chia cho 4 bằng cách bỏ 2 bit cuối (Lấy từ bit thứ 9 đến bit thứ 2)
    assign data_out = sum[9:2]; 
endmodule
