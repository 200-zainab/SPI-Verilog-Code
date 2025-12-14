module RAM #(parameter ADDR_SIZE=8,
		    parameter MEM_DEPTH=256)(
    input            clk,
    input            rst_n,
    input      [9:0] din,
    input            rx_valid,
    output reg [7:0] dout,
    output reg       tx_valid
);


reg [ADDR_SIZE-1:0] MEM [0:MEM_DEPTH-1];
reg [ADDR_SIZE-1:0] ADDR;
//reg STRT_COUNT;
//reg [3:0] counter;


always @(posedge clk or negedge rst_n)
begin 
    if (!rst_n) begin 
        dout     <= 0;
      //  MEM [0] <= 0;
        ADDR     <= 0;
      //STRT_COUNT <=0;
        tx_valid <= 0;

    end
    else begin 
        if(rx_valid) begin 
            if (din[9:8] == 2'b00) begin 
               ADDR <= din [7:0];
               tx_valid <= 0;
               dout <= 0;
            end
            else if (din [9:8] == 2'b01)
            begin 
            MEM[ADDR] <= din[7:0];
             tx_valid <= 0;
               dout <= 0;
            end 
            else if (din [9:8] == 2'b10)
            begin 
                ADDR <= din [7:0];
                 tx_valid <= 0;
               dout <= 0;
            end
            else if (din[9:8] == 2'b11)
           begin 
           dout <= MEM[ADDR];
           //STRT_COUNT <=1;
           tx_valid <= 1;
          end
           

        end 
    end 
end

//for the tx_valid high
//always @(posedge clk or negedge rst_n)
//begin 
//    if(!rst_n) begin 
//        counter  <= 0;
//        tx_valid <= 0;
//
//    end
//    else begin 
//        if(STRT_COUNT) begin 
//            
//            if(counter==10) begin 
//                counter <=0;
//                tx_valid <=0;
//            end
//            else begin 
//            counter <= counter +1;
//            tx_valid <= 1;
//
//            end
//        end
//    end
//end



endmodule