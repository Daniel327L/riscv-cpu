module hex_to_7seg_6digit(
input [3:0] hex0, hex1, hex2, hex3, hex4, hex5,
output [6:0] seg0, seg1, seg2, seg3, seg4, seg5
);

hex_to_7seg_1digit d0(
.hex(hex0),
.seg(seg0)
);

hex_to_7seg_1digit d1(
.hex(hex1),
.seg(seg1)
);

hex_to_7seg_1digit d2(
.hex(hex2),
.seg(seg2)
);

hex_to_7seg_1digit d3(
.hex(hex3),
.seg(seg3)
);

hex_to_7seg_1digit d4(
.hex(hex4),
.seg(seg4)
);

hex_to_7seg_1digit d5(
.hex(hex5),
.seg(seg5)
);


endmodule