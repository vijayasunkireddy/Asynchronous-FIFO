`include "A_FIFO_DUT.v"
`include "A_FIFO_TOP.v"

module A_FIFO_tb;

    reg wclk;
    reg rclk;
    reg wrst_n;
    reg rrst_n;
    reg w_en;
    reg r_en;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire full;
    wire empty;

     A_FIFO_TOP dut(
                   .wclk(wclk),
                   .rclk(rclk),
                   .wrst_n(wrst_n),
                   .rrst_n(rrst_n),
                   .w_en(w_en),
                   .r_en(r_en),
                   .data_in(data_in),
                   .data_out(data_out),
                   .full(full),
                   .empty(empty)
                   );

always #5  wclk = ~wclk;
always #8  rclk = ~rclk;

initial begin
     wclk = 0;
     rclk = 0;

    wrst_n = 0;
    rrst_n = 0;

    w_en = 0;
    r_en = 0;
    data_in = 0;

    #20;

    wrst_n = 1;
    rrst_n = 1;

    repeat(5)
    begin
        @(posedge wclk);
        w_en = 1;
        data_in = data_in + 1;
    end

    @(posedge wclk);
    w_en = 0;

    repeat(5)
    begin
        @(posedge rclk);
        r_en = 1;
    end

    @(posedge rclk);
    r_en = 0;

    #100;
    $finish;
end

endmodule
