module SPI_SLAVE(
    input            clk,
    input            rst_n,
    input            MOSI,
    input            SS_n,
    input      [7:0] tx_data,
    input            tx_valid,
    output reg [9:0] rx_data,
    output reg       rx_valid,
    output reg       MISO
);

localparam IDLE      = 3'b000;
localparam CHK_CMD   = 3'b001;
localparam WRITE     = 3'b011;
localparam READ_ADD  = 3'b010;
localparam READ_DATA = 3'b110;

reg [2:0] cs, ns;
reg [7:0] tx_shift;
reg signed [3:0] counter;
reg       read_add_flg;
reg [9:0] P_rx_data;
// STATE REGISTER
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cs <= IDLE;
    else
        cs <= ns;
end

// NEXT STATE LOGIC
always @(*) begin
    case(cs)
        IDLE:      ns = (SS_n == 0) ? CHK_CMD : IDLE;

        CHK_CMD: begin
            if (SS_n == 0 && MOSI == 0)
                ns = WRITE;
            else if (SS_n == 0 && MOSI == 1 && !read_add_flg)
                ns = READ_ADD;
            else if (SS_n == 0 && MOSI == 1 && read_add_flg)
                ns = READ_DATA;
            else
                ns = IDLE;
        end

        WRITE:      ns = (SS_n == 0) ? WRITE : IDLE;
        READ_ADD:   ns = (SS_n == 0) ? READ_ADD : IDLE;
        READ_DATA:  ns = (SS_n == 0) ? READ_DATA : IDLE;

        default:    ns = IDLE;
    endcase
end

// OUTPUT & COUNTERS
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rx_data      <= 0;
        rx_valid     <= 0;
        MISO         <= 0;
        counter      <= -1;
        read_add_flg <= 0;
        tx_shift     <= 0;
         P_rx_data <=0;
        
    end else begin
        // default
        rx_valid <= 0;   // pulse only when done

        case (cs)
            IDLE: begin
                rx_data      <= 0;
                MISO         <= 0;
                counter      <= -1;
                rx_valid <= 0; 
                tx_shift     <= 0;
                 P_rx_data <=0;

            end

            WRITE: begin
                counter <= counter + 1;
                P_rx_data <= {P_rx_data[8:0], MOSI};
                if (counter == 4'd9) begin
                    rx_valid <= 1;
                    rx_data  <= P_rx_data;
                    counter  <= -1;
                end
            end

            READ_ADD: begin
                counter <= counter + 1;
                P_rx_data <= {P_rx_data[8:0], MOSI};
                if (counter == 4'd9) begin
                    rx_valid <= 1;
                    rx_data  <= P_rx_data;
                    counter  <= -1;
                    read_add_flg <= 1;
                    
                end
            end

            READ_DATA: begin
                if (tx_valid) begin
                    rx_valid     <= 0;
                    if (counter == -1) begin
                        tx_shift <= tx_data;  // load 8-bit into 10-bit
                        counter  <= 4'd7;
                    end else begin
                        MISO     <= tx_shift[0];
                        tx_shift <= tx_shift >> 1;
                        counter  <= counter - 1;
                    end
                end
                else begin 
                          counter <= counter + 1;
                P_rx_data <= {P_rx_data[8:0], MOSI};
                if (counter == 4'd9) begin
                    rx_valid     <= 1;
                    counter      <= -1;
                    read_add_flg <= 0;
                    rx_data  <= P_rx_data;


                end
            end
            end
        endcase
    end
end

endmodule
