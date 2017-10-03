/*
Author:Aniket Badhan
*/


//In the memory monitor, memory interface signals are converted into the tx and sent to the checker for comparison
class mc_mon;
	virtual mem_intf mvif;
	mcReg mcReg_i;
	mem_tx memTx;
	
	//identify the chip select
	//retrieve the register configuration information - 
	//identify the memory type, bus width, etc..	
	//sample the memory signals wrt the memory type
	
	task run();
		bit [2:0] chipSelect;
		bit [2:0] memoryType;
		$display("MCMON");
		mvif = mc_cfg::mvif;
		mc_config::ref2mc_mon.get(mcReg_i);				//we had to implement a mailbox to get the register configuration becuase the register configuration was instantiated in the reference design, to make it available, we put the register conguration (mcReg_i) in mailbox from the reference design and retrieved it here.
		forever begin
			@(negedge mvif.mc_clk); 
			if(mvif.mc_cs_o_!=8'hFF) begin
				chipSelect = findChipSelect();
				memTx = new();
				memoryType = mcReg_i.cscRegister[cs].memType;
				case(memoryType)
					`SSRAM	:	begin
									//Write transaction
									//the signals in the if condition are obtained from the DUT specification
									if(!mc_we_o_ && !mc_adsc_o_ && mvif.mc_doe_doe_o==1) begin
										memTx.memAddress = mvif.mc_addr_o;
										memTx.memData = mvif.mc_data_o;
										memTx.writeRead = 1'b1;
										repeat(2) @(posedge mvif.mc_clk);
										mc_cfg::mon2ckr.put(memTx);
									end
									//Read Transaction
									if(!mc_oe_o_ && !mc_adsc_o_ && mvif.mc_doe_doe_o==0) begin
										memTx.memAddress = mvif.mc_addr_o;
										memTx.writeRead = 1'b0;
										repeat(2) @(negedge mvif.mc_clk);
										memTx.memData = mvif.mc_data_i;
										mc_cfg::mon2ckr.put(memTx);
									end
								end
					`SDRAM	:	begin
								end
					`ACSD	:	begin
					
								end
					`SCSD	:	begin
								end
				endcase
			end
			
		end
	endtask
	
	function bit [2:0] findChipSelect();
		case(mvif.mc_cs_o_)
			8'h11111110	:	begin
								return 0;
							end
			8'h11111101	:	begin
								return 1;
							end
			8'h11111011	:	begin
								return 2;
							end
			8'h11110111	:	begin
								return 3;
							end
			8'h11101111	:	begin
								return 4;
							end
			8'h11011111	:	begin
								return 5;
							end
			8'h10111111	:	begin
								return 6;
							end
			8'h01111111	:	begin
								return 7;
							end
		endcase
	endfunction
	
endclass