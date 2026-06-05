`timescale 1ns / 1ps // Định nghĩa 1 đơn vị thời gian = 1ns, độ phân giải 1ps

module tb_system_top();

    // 1. KHAI BÁO BIẾN CHO TESTBENCH
    // Đầu vào (Inputs) dùng kiểu 'reg' để testbench có thể thay đổi giá trị
    reg clk;
    reg rst_n;
    reg raw_smoke;
    reg [7:0] raw_temp;
    reg [7:0] raw_gas;
    reg [9:0] raw_ir_data;
    reg raw_manual;

    // Đầu ra (Outputs) dùng kiểu 'wire' để hứng tín hiệu từ mạch phát ra
    wire sys_alarm_bell;
    wire sys_sprinkler;
    wire sys_warning_led;

    // 2. MANG BO MẠCH CHỦ VÀO PHÒNG THÍ NGHIỆM (Instantiation)
    system_top uut (  // uut = Unit Under Test (Thiết bị đang được test)
        .clk(clk),
        .rst_n(rst_n),
        .raw_smoke(raw_smoke),
        .raw_temp(raw_temp),
        .raw_gas(raw_gas),
        .raw_ir_data(raw_ir_data),
        .raw_manual(raw_manual),
        .sys_alarm_bell(sys_alarm_bell),
        .sys_sprinkler(sys_sprinkler),
        .sys_warning_led(sys_warning_led)
    );

    // 3. TẠO NHỊP TIM (CLOCK GENERATOR)
    // Cứ mỗi 5ns thì đảo trạng thái 1 lần -> Chu kỳ 10ns (Tương đương tần số 100MHz)
    always #5 clk = ~clk;

    // 4. VIẾT KỊCH BẢN TEST (TEST VECTORS)
    initial begin
        // Dòng này để xuất file sóng (Waveform) xem biểu đồ
        $dumpfile("waveform.vcd");
        $dumpvars(0, tb_system_top);

        // --- KHỞI TẠO TRẠNG THÁI BAN ĐẦU ---
        clk = 0;
        rst_n = 0;           // Kéo Reset xuống 0 để reset hệ thống
        raw_smoke = 0;
        raw_temp = 8'd25;    // Nhiệt độ phòng 25 độ
        raw_gas = 8'd10;     // Gas bình thường mức 10
        raw_ir_data = 10'd0; // Không có tia hồng ngoại
        raw_manual = 0;

        // Đợi 20ns, sau đó nhả Reset ra (cấp nguồn)
        #20 rst_n = 1;
        #50; // Đợi hệ thống ổn định thêm 50ns

        // --- KỊCH BẢN 1: TEST CẢM BIẾN NHIỆT ĐỘ ---
        // Giả sử nhiệt độ tăng đột ngột lên 70 độ C (vượt ngưỡng 68)
        raw_temp = 8'd70;
        #100; // Giữ ở 70 độ trong 100ns để xem mạch phản ứng
        raw_temp = 8'd25; // Hạ nhiệt độ về bình thường
        #50;

        // --- KỊCH BẢN 2: TEST RÒ RỈ GAS ---
        // Tăng nồng độ gas lên 60 (vượt ngưỡng 50)
        raw_gas = 8'd60;
        #100; // Giữ nguyên 100ns
        raw_gas = 8'd10; // Hết rò rỉ
        #50;

        // --- KỊCH BẢN 3: TEST PHÍM BẤM BẰNG TAY ---
        raw_manual = 1;
        #50;
        raw_manual = 0;
        #100;

        // Kết thúc quá trình mô phỏng
        $finish;
    end

endmodule