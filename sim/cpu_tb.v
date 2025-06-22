// `timescale` 定義了時間單位和精度
// 1ns 是時間單位，1ps 是時間精度
`timescale 1ns / 1ps

// 包含你的 cpu 模組，這樣 testbench 才能實例化它
`include "./src/cpu.v"

module testbench;

    // Testbench 內部的 registers，用來驅動 CPU 的輸入
    reg clk;
    reg rst;

    // 實例化待測單元 (Unit Under Test, UUT)，也就是你的 cpu
    cpu uut (
        .clk(clk),
        .rst(rst)
    );

    // =================================================================
    //  時脈產生器 (Clock Generator)
    // =================================================================
    // 定義時脈週期為 10ns (頻率為 100MHz)
    localparam CLOCK_PERIOD = 10;

    // always 區塊會一直執行，每半個週期將 clk 反相，產生方波
    always begin
        clk = 1'b0;
        #(CLOCK_PERIOD / 2); // 等待半個週期
        clk = 1'b1;
        #(CLOCK_PERIOD / 2); // 再等待半個週期
    end
    reg [3:0] mem;
    // =================================================================
    //  測試程序 (Test Procedure)
    // =================================================================
    initial begin
        // 1. 初始化與重置
        $display("================== Simulation Start ==================");
        rst = 1'b1; // 在一開始，啟動重置信號
        # (CLOCK_PERIOD * 2); // 保持重置信號有效兩個時脈週期，確保所有元件都重置完成
        rst = 1'b0; // 取消重置，CPU 開始執行
        $display("================== Reset Released, CPU Start ==================");

        // 2. 執行並觀察
        // 你的 instruction_memory 中有 8 條指令，我們至少執行 10 個週期來觀察
        // 也可以設定一個更長的時間來結束模擬
        repeat (12) begin
            @(posedge clk); // 在每個時脈的正緣觸發
        end

        // 3. 結束模擬
        $display("================== Simulation End ==================");
        $finish; // 結束模擬程序
    end

    // =================================================================
    //  狀態監控 (State Monitoring)
    // =================================================================
    // 這個 always 區塊會在每個時脈正緣後被觸發，用來印出 CPU 的內部狀態
    // $timeformat 可以設定時間顯示的格式
    initial begin
        $timeformat(-9, 2, " ns", 10);
    end
    
    always @(posedge clk) begin
        // 只有在重置結束後才開始顯示資訊
        if (!rst) begin
            $display("------------------------------------------------------------------");
            $display("Time: %t", $time);
            $display("PC: 0x%h, Instruction: 0x%h", uut.pc_current, uut.instruction);

            // 顯示控制信號，這對於除錯非常有用
            $display("Control Signals: RegWrite=%b, Branch=%b, Jump=%b, MemRead=%b, MemWrite=%b, ALUSrc=%b",
                     uut.reg_write, uut.branch, uut.jump, uut.mem_read, uut.mem_write, uut.alu_src);

            // 顯示 Register File 的幾個關鍵暫存器的值
            // 為了能存取到 reg_file 內部的 registers 陣列，你需要使用 hierarchical name
            // 語法是：<uut_name>.<module_name>.<signal_name>
            $display("Registers: R1=0x%h (%d), R2=0x%h (%d), R3=0x%h (%d), R4=0x%h (%d), R5=0x%h (%d)",
                     uut.reg_file_inst.registers[1], uut.reg_file_inst.registers[1],
                     uut.reg_file_inst.registers[2], uut.reg_file_inst.registers[2],
                     uut.reg_file_inst.registers[3], uut.reg_file_inst.registers[3],
                     uut.reg_file_inst.registers[4], uut.reg_file_inst.registers[4],
                     uut.reg_file_inst.registers[5], uut.reg_file_inst.registers[5]
            );

            mem = {uut.data_mem.mem[3], uut.data_mem.mem[2], uut.data_mem.mem[1], uut.data_mem.mem[0]};
            // 顯示資料記憶體在地址 0 的值 (因為 SW 指令寫在這個位置)
            $display("Data Memory [Addr 0]: 0x%h", mem);
        end
    end

endmodule