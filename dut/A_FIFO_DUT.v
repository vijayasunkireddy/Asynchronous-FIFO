//---------------------------------------------2 flip flop synchronizer--------------------------------------------------------------

module synchronizer #(parameter width=3)(input clk, rst_n,[width:0] d_in,output reg [width:0]d_out);
reg [width:0] q1;
always@(posedge clk) begin
if(!rst_n)begin
    q1<=0;
    d_out<=0;
    end
    else begin
        q1<=d_in;
        d_out<=q1;
        end
     end
endmodule



//-----------------------------------------write pointer handler--------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------
module write_handler#(parameter PTR_WIDTH=3)
       (input wclk,wrst_n,w_en,
       input [PTR_WIDTH:0]g_rptr_sync,
       output reg[PTR_WIDTH:0] b_wptr,g_wptr,
       output reg full
       );

reg [PTR_WIDTH:0]b_wptr_next;
reg [PTR_WIDTH:0]g_wptr_next;
wire wfull;  //-----------------//it is wire because it is continuously calucated full condition signal, not a stored register

always @(*)begin
    b_wptr_next= b_wptr+(w_en&!full);
    g_wptr_next= (b_wptr_next>>1)^b_wptr_next;//----------------------//binary to gray conversion
     end

// write pointer update

always@(posedge wclk or negedge wrst_n)begin
  if(!wrst_n)begin
      b_wptr <=0;
      g_wptr <=0;
      end
      else begin
          b_wptr   <= b_wptr_next;    //inc binary write pointer
          g_wptr   <= g_wptr_next;   //inc gray write pointer
          end
        end

 // full flag update 

always@(posedge wclk or negedge wrst_n)begin
  if(!wrst_n)
      full <=0;
      else 
        full <=wfull;
   end
     assign wfull = (g_wptr_next =={~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1],g_rptr_sync[PTR_WIDTH-2:0]});

endmodule


//--------------------------------------------------------read pointer handler-----------------------------------------------------
//-----------------------------------------------------------------------------------------------------------------------------------

 module read_handler#(parameter PTR_WIDTH=3)
       (input rclk,rrst_n,r_en,
       input [PTR_WIDTH:0]g_wptr_sync,
       output reg [PTR_WIDTH:0] b_rptr,g_rptr,
       output reg empty
       );

reg [PTR_WIDTH:0]b_rptr_next;
reg [PTR_WIDTH:0]g_rptr_next;

wire rempty;   

always@(*)
    begin
       b_rptr_next= b_rptr+(r_en&!empty);
       g_rptr_next= (b_rptr_next>>1)^b_rptr_next;//--------//binary to gray conversion
    end
assign rempty=(g_wptr_sync ==g_rptr_next);

// read pointer update
always@(posedge rclk or negedge rrst_n)begin
  if(!rrst_n)begin
      b_rptr <=0;
      g_rptr <=0;
      end
      else begin
          b_rptr <=b_rptr_next;    //inc binary write pointer
          g_rptr  <=g_rptr_next;  //inc gray write pointer
          end
        end
 // empty flag update   
always@(posedge rclk or negedge rrst_n)begin
  if(!rrst_n)
      empty <=1;
      else 
        empty <=rempty;
   end

endmodule


//-------------------------------------------------------------------FIFO memory--------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------
module fifo_mem # (parameter DEPTH=8, DATA_WIDTH=8, PTR_WIDTH=3)
       (input wclk, w_en,rclk,r_en,
       input [PTR_WIDTH:0] b_wptr, b_rptr,
       input[DATA_WIDTH-1:0]data_in,
       input full,empty,
       output reg [DATA_WIDTH-1:0]data_out);

  reg[DATA_WIDTH-1:0] fifo[0:DEPTH-1];


  always@(posedge wclk )begin
       if(w_en&!full)begin
           fifo[b_wptr[PTR_WIDTH-1:0]] <=data_in;
           end
        end
  always@(posedge rclk )begin
       if(r_en&!empty)begin
          data_out <= fifo[b_rptr[PTR_WIDTH-1:0]];
          end
          end
endmodule
