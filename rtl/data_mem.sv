module data_mem #(
    parameter DEPTH = 256                 //256 is a deliberate choice, keep the memory small no need bigger
) (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [3:0]  byte_enable,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    (* ramstyle = "M9K" *) logic [3:0][7:0] mem [0:DEPTH-1];

    always_ff@(posedge clk) begin  //storing must be syncrhonized 
        if(mem_write) begin
           if(byte_enable[0]) mem[addr[9:2]][0] <= write_data[7:0]; //do this instead of [i*8 +: 8] because Quartus is picky
           if(byte_enable[1]) mem[addr[9:2]][1] <= write_data[15:8];
           if(byte_enable[2]) mem[addr[9:2]][2] <= write_data[23:16];
           if(byte_enable[3]) mem[addr[9:2]][3] <= write_data[31:24]; //also, using a 2D array helps Quartus to recognize it adds up to a 4 byte data
        end
        if(mem_read) begin //syncrhonize mem_read to use BRAM
            read_data <= mem[addr[9:2]];
        end
    end    

 //don't need initialization, M9K BRAM initialize as 0 already

endmodule
