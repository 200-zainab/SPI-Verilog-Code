module SPI_WRAPPER(
  input    MOSI,
  input    clk,
  input    rst_n,
  input    SS_n,
  output   MISO
);

wire        rx_valid, tx_valid;
wire [9:0]  rx_data;
wire [7:0]  tx_data;

SPI_SLAVE SPISLAVE (
    .clk(clk),
    .rst_n(rst_n),
    .MOSI(MOSI),
    .rx_data(rx_data),
    .tx_data(tx_data),
    .SS_n(SS_n),
    .rx_valid(rx_valid),
    .tx_valid(tx_valid),
    .MISO(MISO)
);

RAM #(
    .ADDR_SIZE(8),
    .MEM_DEPTH(256)
) ram_mem (
    .clk(clk),
    .rst_n(rst_n),
    .din(rx_data),
    .dout(tx_data),      
    .rx_valid(rx_valid),
    .tx_valid(tx_valid)
);

endmodule
