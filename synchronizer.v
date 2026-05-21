module synchronizer (
    input clk,          // Xung nhịp hệ thống
    input rst_n,        // Reset hệ thống (tích cực mức thấp)
    input async_in,     // Tín hiệu vào không đồng bộ (từ nút nhấn, cảm biến)
    output reg sync_out // Tín hiệu ra đã được đồng bộ với clk
);
    reg q1;             // Thanh ghi tầng 1 để chốt tín hiệu tạm thời
    always @(posedge clk or negedge rst_n) begin // Kích hoạt khi cạnh lên clock hoặc cạnh xuống reset
        if (!rst_n) begin       // Nếu nhấn Reset
            q1 <= 1'b0;         // Xóa giá trị thanh ghi q1 về 0
            sync_out <= 1'b0;   // Xóa giá trị đầu ra về 0
        end else begin          // Nếu không reset (trạng thái hoạt động)
            q1 <= async_in;     // Chốt tín hiệu vào tầng 1
            sync_out <= q1;     // Đưa tín hiệu từ tầng 1 sang tầng 2 để ổn định
        end
    end
endmodule