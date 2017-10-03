/*
Author:Aniket Badhan
*/

`define SDRAM 0
`define SSRAM 1
`define ACSD 2
`define SCSD 3

`define BA_MASK_VAL 8'b11111111
`define CS0_START	32'h00200000
`define CS0_END		32'h003FFFFF
`define CS1_START	32'h00400000
`define CS1_END		32'h005FFFFF
`define CS2_START	32'h00800000
`define CS2_END		32'h009FFFFF
`define CS3_START	32'h01000000
`define CS3_END		32'h011FFFFF
`define CS4_START	32'h02000000
`define CS4_END		32'h021FFFFF
`define CS5_START	32'h04000000
`define CS5_END		32'h041FFFFF
`define CS6_START	32'h08000000
`define CS6_END		32'h081FFFFF
`define CS7_START	32'h10000000
`define CS7_END		32'h101FFFFF

class mc_cfg;
	static virtual wb_intf wvif;
	static virtual mem_intf mvif;
	static string testName;			//to access it in the wb_gen, to know which test case to run
	static mailbox gen2bfm = new();
	static mailbox bfm2gen = new();
	static mailbox mon2cov = new();
	static mailbox mon2ref = new();
	
	static integer match_count = 0;
	static integer mismatch_count = 0;
	static integer num_txs = 1;
	
	static mailbox ref2ckr = new();
	static mailbox mon2ckr = new();
	static mailbox wb_mon2cov = new();
	static mailbox wb_mon2ref = new();
	static mailbox ref2mc_mon = new();
	static event test_finish;
	
	static bit [31:0] reg_mask[19] = {{'hff,13'h0, 3'b111,5'h0, 1'b1,1'b1, 1'b0},
                                    {32'h0},
                                    {24'h0,8'hff},
                                    {8'h0,8'hff,4'h0,12'hfff},
                                    {32'hff},
                                    {8'h0,8'hff,4'h0,12'hfff},
                                    {32'hff},
                                    {8'h0,8'hff,4'h0,12'hfff},
                                    {32'hff},
                                    {8'h0,8'hff,4'h0,12'hfff},
                                    {32'hff},
                                    {8'h0,8'hff,4'h0,12'hfff},
                                    {32'hff},
                                    {8'h0,8'hff,4'h0,12'hfff},
                                    {32'hff},
                                    {8'h0,8'hff,4'h0,12'hfff},
                                    {32'hff},
                                    {8'h0,8'hff,4'h0,12'hfff},
                                    {32'hff}};
endclass 