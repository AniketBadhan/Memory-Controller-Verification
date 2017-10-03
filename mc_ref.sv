/*
Author:Aniket Badhan
*/

class mc_ref;
	/*
	1. transaction will come from wb monitor to ref model
	2. enable mc_reg layer here for writing into mc_reg for 
		i. to store the design configuration information to retrieve at later point to understand the DUT stage
		ii. collecting the coverage
	3. identify whether the tx is for registers or for memory, if tx is for memory convert the transaction into mem transaction type and send it to checker using mailbox
	*/
	
	/*
	1) Identify the CS targetted
	2) Retrieve the register configuration information from register layer
	3) Identfy the type of memory (SRAM/SDRAM/SYNC_CS/Flash)
	4) Convert the wb transaction into mem transaction
		1) Identiying the CS targetted
		2) Retreiving that CS specific register configuration
		3) Identify the memory type, bw
		4) convert the wb tx into that particulat memory tx
	*/
	mem_tx memTx;
	wb_tx tx;
	mcReg mcReg_i = new();
	
	task run(); 
		bit [2:0] chipSelect;
		bit [2:0] memType;
		bit [1:0] burstWidth;
		$display("MCREF");
		
		forever begin
			mc_cfg::mon2ref.get(tx);
			if(tx.writeReadVar==1'b1) begin
				case(tx.addr[31:29])
					3'b011	:	begin
									mcReg_i.writeReg(tx.addr, tx.data);		//writing to registers
								end
					3'b000	:	begin
									mc_cfg::ref2mc_mon.put(mcReg_i);							//register configuration is required only while doing a memory transaction and hence only put in the mailbox when the tx is memory type
									memTx = new();												// no need to create this object when the wishbone transaction is a register address
									chipSelect = identifyChipSelect(tx.addr);					//Identiying the CS targetted
									memType = mcReg_i.cscReg[chipSelect].memType;				//Retreiving that CS specific register configuration, fields of importance are memory type and burst width
									burstWidth = mcReg_i.cscReg[chipSelect].bw;
									//converting wishbone transaction to memory transaction
									memTx.memAddress = calcAddress(tx.addr, memType);
									memTx.memData = tx.data;
									memTx.writeRead = 1'b1;
									mc_cfg::ref2ckr.put(memTx);
								end
				endcase
			end
			if(tx.writeReadVar==1'b0) begin
				case(tx.addr[31:29])
					3'b011	:	begin
									mcReg_i.readReg(tx.addr);		//writing to registers
									$display("Reading from Registers in reference design");
								end
					3'b000	:	begin
									mc_cfg::ref2mc_mon.put(mcReg_i);							//register configuration is required only while doing a memory transaction and hence only put in the mailbox when the tx is memory type
									memTx = new();												// no need to create this object when the wishbone transaction is a register address
									chipSelect = identifyChipSelect(tx.addr);					//Identiying the CS targetted
									memType = mcReg_i.cscReg[chipSelect].memType;				//Retreiving that CS specific register configuration, fields of importance are memory type and burst width
									burstWidth = mcReg_i.cscReg[chipSelect].bw;
									//converting wishbone transaction to memory transaction
									memTx.memAddress = calcAddress(tx.addr, memType);
									memTx.memData = tx.data;
									memTx.writeRead = 1'b0;
									mc_cfg::ref2ckr.put(memTx);
								end
				endcase 
			end
		end
	endtask
	
	//Base Address (csc.sel is the base address)  . This field is ANDed with address mask and compared with the address input [28:21]. If there is match, this chip select is enabled/asserted.
	//to figure out which chip select is targetted based on the csc.sel field and the ba mask value 
	function bit [2:0] identifyChipSelect(bit [31:0] addr);
		if(mcReg_i.cscReg[0].sel && mcReg_i.baMaskReg.baMask == addr[28:21]) return 0;
		if(mcReg_i.cscReg[1].sel && mcReg_i.baMaskReg.baMask == addr[28:21]) return 1;
		if(mcReg_i.cscReg[2].sel && mcReg_i.baMaskReg.baMask == addr[28:21]) return 2;
		if(mcReg_i.cscReg[3].sel && mcReg_i.baMaskReg.baMask == addr[28:21]) return 3;
		if(mcReg_i.cscReg[4].sel && mcReg_i.baMaskReg.baMask == addr[28:21]) return 4;
		if(mcReg_i.cscReg[5].sel && mcReg_i.baMaskReg.baMask == addr[28:21]) return 5;
		if(mcReg_i.cscReg[6].sel && mcReg_i.baMaskReg.baMask == addr[28:21]) return 6;
		if(mcReg_i.cscReg[7].sel && mcReg_i.baMaskReg.baMask == addr[28:21]) return 7;
	endfunction 
	
	function bit [23:0] calcAddress(bit[31:0] addr, bit [2:0] memoryType);
		case(memoryType)
			`SSRAM	:	begin
							return addr[25:2];
						end
			`SDRAM	:	begin
							
						end
			`ACSD	:	begin
			
						end
			`SCSD	:	begin
			
						end
		endcase
	endfunction
	
endclass