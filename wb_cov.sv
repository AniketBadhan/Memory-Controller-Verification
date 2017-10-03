/*
Author:Aniket Badhan
*/

class wb_cov;

	wb_tx tx;	
	
	//coverpoint to check which chip is selected
	/*covergroup chipSelect_cg @ (mc_cfg::mvif.mc_cs_o_);			//here we tell when the covergroup has to be executed when we mention @ (signal_name). we don't need to explicitly sample this ccovergroup
		CS_CP	:	coverpoint mc_cfg::mvif.mc_cs_o_{
			ignore_bins NO_CHIP_SELECTED = {8'b11111111};
			bins CS0_SELECTED = {8'b11111110};
			bins CS1_SELECTED = {8'b11111101};
			bins CS2_SELECTED = {8'b11111011};
			bins CS3_SELECTED = {8'b11110111};
			bins CS4_SELECTED = {8'b11101111};
			bins CS5_SELECTED = {8'b11011111};
			bins CS6_SELECTED = {8'b10111111};
			bins CS7_SELECTED = {8'b01111111};
			illegal_bins MULTIPLE_CS_SELECTED = default;
		}
	endgroup*/

	covergroup wbAddressOperation;
		//coverpoint to address corresponding to which chip is selected
		ADDRESS_CP	:	coverpoint tx.addr iff (tx.regMemF==0) {
			bins CS0ADDRESS = {[`CS0_START:`CS0_END]};
			bins CS1ADDRESS = {[`CS1_START:`CS1_END]};
			bins CS2ADDRESS = {[`CS2_START:`CS2_END]};
			bins CS3ADDRESS = {[`CS3_START:`CS3_END]};
			bins CS4ADDRESS = {[`CS4_START:`CS4_END]};
			bins CS5ADDRESS = {[`CS5_START:`CS5_END]};
			bins CS6ADDRESS = {[`CS6_START:`CS6_END]};
			bins CS7ADDRESS = {[`CS7_START:`CS7_END]};
		} 
		//coverpoint to check which operation is it, rea or write
		READWRITE			:	coverpoint tx.writeReadVar iff(tx.regMemF==0){
			bins WRITE = {WRITE};
			bins READ = {READ};
		}
		//cross coverage between above two coverpoints
		MEMOPERATION		: cross ADDRESS_CP, READWRITE;
	endgroup;
	
	function new();
		chipSelect_cg = new();
		wbAddressOperation = new();
	endfunction
	
	task run();
		$display("WBCOV");
		forever begin
			tx=new();
			mc_cfg::wb_mon2cov.get(tx);
			wbAddressOperation.sample();			//covergroup wbAddressOperation needs to be explicitly sampled as no condition has been specified in the covergroup statement ( using "@", as done in covergroup chipSelect)
		end
	endtask
endclass