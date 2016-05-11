module data_comp(serial_data, serial_vld, mask, match, prot_trig);
	input [7:0] serial_data, mask, match;
	input serial_vld;
	output prot_trig;
	
	assign prot_trig = (((serial_data | mask) == (match | mask)) ? 1 : 0) & serial_vld; 
	
endmodule