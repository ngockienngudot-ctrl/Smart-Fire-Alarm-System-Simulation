module fire_alarm_fsm (
    input clk,          // Xung nhịp hệ thống
    input rst_n,        // Reset hệ thống
    input smoke_alert,  // Cờ báo có khói
    input temp_alert,   // Cờ báo nhiệt độ cao
    input gas_alert,    // Cờ báo rò rỉ gas
    input manual_call,  // Cờ từ nút nhấn khẩn cấp bằng tay
    
    output reg alarm_bell,  // Điều khiển chuông (1: Kêu, 0: Tắt)
    output reg sprinkler,   // Điều khiển vòi phun nước (1: Phun)
    output reg warning_led  // Điều khiển đèn LED cảnh báo
);

    // Định nghĩa mã hóa cho các trạng thái
    parameter NORMAL  = 2'b00; // Trạng thái bình thường
    parameter WARNING = 2'b01; // Trạng thái cảnh báo (có dấu hiệu cháy)
    parameter ALARM   = 2'b10; // Trạng thái báo động cháy thật

    reg [1:0] current_state, next_state; // Thanh ghi lưu trạng thái hiện tại và kế tiếp
    
    // --- 1. BỘ ĐẾM XÁC NHẬN KHÓI ---
    reg [31:0] smoke_timer;              
    parameter SMOKE_DELAY_LIMIT = 32'd50000; // Giới hạn đếm 

    // --- 2. BỘ ĐẾM CHUÔNG NGẮT QUÃNG ---
    reg [31:0] beep_counter;             
    wire beep_on;                        
    parameter BEEP_HALF_PERIOD = 32'd5000;   // Nhịp chớp của chuông
    assign beep_on = (beep_counter < BEEP_HALF_PERIOD); 

    // Khối logic tuần tự: Cập nhật trạng thái và bộ đếm
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin                // Khi reset
            current_state <= NORMAL;     // Quay về trạng thái bình thường
            smoke_timer <= 32'd0;        // Xóa bộ đếm khói
            beep_counter <= 32'd0;       // Xóa bộ đếm chuông
        end else begin                   // Khi hoạt động
            current_state <= next_state; // Chuyển sang trạng thái tiếp theo
            
            // Logic đếm khói: Chỉ đếm khi đang cảnh báo và vẫn còn khói
            if (smoke_alert && current_state == WARNING) begin
                if (smoke_timer < SMOKE_DELAY_LIMIT)
                    smoke_timer <= smoke_timer + 1'b1; // Tăng dần bộ đếm
            end else begin
                smoke_timer <= 32'd0;    // Nếu hết khói hoặc thoát cảnh báo thì xóa đếm
            end

            // Logic đếm nhịp chuông: Đếm đến giới hạn thì quay đầu về 0
            if (beep_counter >= (BEEP_HALF_PERIOD * 2)) begin
                beep_counter <= 32'd0;
            end else begin
                beep_counter <= beep_counter + 1'b1;
            end
        end
    end

    // Khối logic tổ hợp: Tính toán trạng thái kế tiếp (Next State Logic)
    always @(*) begin
        next_state = current_state;      // Mặc định giữ nguyên trạng thái hiện tại
        case (current_state)
            NORMAL: begin                // Nếu đang ở trạng thái Bình thường
                if (manual_call) next_state = ALARM; // Nhấn nút tay thì báo động ngay
                else if (smoke_alert || temp_alert || gas_alert) next_state = WARNING; 
            end

            WARNING: begin               // Nếu đang ở trạng thái Cảnh báo
                if (manual_call) next_state = ALARM; 
                // Cháy thật khi: Nhiệt quá cao HOẶC (có Khói và đã đợi đủ lâu)
                else if (temp_alert || (smoke_alert && (smoke_timer >= SMOKE_DELAY_LIMIT))) 
                    next_state = ALARM;
                // Nếu tất cả cảm biến đều hết báo động thì quay về Bình thường
                else if (!smoke_alert && !temp_alert && !gas_alert)
                    next_state = NORMAL;
            end

            ALARM: next_state = ALARM;   // Đã báo động thì ở lỳ tại đây cho đến khi Reset
            default: next_state = NORMAL;
        endcase
    end

    // Khối logic tổ hợp: Điều khiển đầu ra dựa trên trạng thái (Output Logic)
    always @(*) begin
        alarm_bell = 1'b0;               // Mặc định tắt chuông
        sprinkler  = 1'b0;               // Mặc định tắt vòi phun
        warning_led = 1'b0;              // Mặc định tắt đèn LED

        case (current_state)
            WARNING: begin               
                warning_led = 1'b1;      // Luôn bật đèn LED ở trạng thái cảnh báo
                
                // NẾU CÓ RÒ RỈ GAS: Bật thêm chuông kêu tít tít
                if (gas_alert) begin
                    alarm_bell = beep_on; 
                end
            end
            
            ALARM: begin                 // Trạng thái báo động cháy thật
                warning_led = 1'b1;      
                sprinkler   = 1'b1;      // Đã cháy thì bật cả vòi phun
                alarm_bell  = beep_on;   
            end
            default: ;
        endcase
    end
endmodule