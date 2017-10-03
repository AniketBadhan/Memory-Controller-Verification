/*
Author:Aniket Badhan
*/

class wb_gen;
	wb_tx tx;
	wb_tx txActual, txExpected;
	bit writeComplete;
	wb_tx writeTxQ[$];
	task run();
		$display("WBGEN");
		//test case targetting the register reset
		//coding should start from the generator
		$display("testName: %s", mc_cfg::testName);
		case(mc_cfg::testName)
			//test case to check the register values when the reset is applied to the DUT. Registers should take reset values as per the specifications when reset is applied.
			"testRegisterResetCase"	:	begin
											genAllRegReadReset();
										end
			"testRegisterWriteRead"	:	begin
											writeComplete = 0;
											genAllRegWrite();
											if(writeComplete==1) genAllRegReadWrRd();
										end
			"testALLSRAM"			:	begin
											//apply reset - done in the top.sv
											//configure the core registers specific to SRAM requirements
											configureRegistersSRAM();
											//generate the scenarios (transactions)
											generateScenariosSRAM();
										end
		endcase
	endtask
	
	//genAllRegReadReset: reading the core registers after the reset is released
	task genAllRegReadReset();
		//2 different FOR loops are required as the address are not continuous as specified in the mc_doc.pdf. There is a gap after 8, all the addresses specified over there are in hexadecimal
		//2 FOR loops are required if we have to read or write to these core registers
		for(int i=0;i<=2;i++) begin
			tx = new();
			assert(tx.randomize() with {tx.addr[28:0] == 4*i; tx.writeReadVar == 1'b0; tx.regMemF==1;});	//constrained read. reading from the addresses only where the core registers are located.	
			mc_cfg::gen2bfm.put(tx);
		end
		for(int i=4;i<=19;i++) begin
			tx = new();
			assert(tx.randomize() with {tx.addr[28:0] == 4*i; tx.writeReadVar == 1'b0; tx.regMemF==1;});	//constrained read. reading from the addresses only where the core registers are located.
			mc_cfg::gen2bfm.put(tx);
		end
	endtask
	
	//genAllRegReadWrRd: generating the transactions for reading the registers after the write is performed on core registers
	//Here we assign values to the bits 28:0 to addr because the bits 31:29 are assigned from the design (mc_defines.v)
	task genAllRegReadWrRd();
		for(int i=0;i<=2;i++) begin
			tx = new();
			assert(tx.randomize() with {tx.addr[28:0] == 4*i; tx.writeReadVar == 1'b0; tx.regMemF==1;});	//constrained read. reading from the addresses only where the core registers are located.
			mc_cfg::gen2bfm.put(tx);				//It is important to put these transactions to the gen2bfm to initiate a read operation
			mc_cfg::bfm2gen.get(txActual);
			txExpected = writeTxQ.pop_front();
			if(txExpected.data==txActual.data) begin
				$display("MATCH: Data matches at %h, Actual Data: %h, Expected Data: %h", txExpected.addr, txActual.data, txExpected.data);
			end
			else begin
				$display("ERROR: Data mismatch at %h, Actual Data: %h, Expected Data: %h", txExpected.addr, txActual.data, txExpected.data);
			end
		end			
		for(int i=4;i<=19;i++) begin
			tx = new();
			assert(tx.randomize() with {tx.addr[28:0] == 4*i; tx.writeReadVar == 1'b0; tx.regMemF==1;});	//constrained read. reading from the addresses only where the core registers are located.
			mc_cfg::gen2bfm.put(tx);				//It is important to put these transactions to the gen2bfm to initiate a read operation
			mc_cfg::bfm2gen.get(txActual);
			txExpected = writeTxQ.pop_front();
			if(txExpected.data==txActual.data) begin
				$display("MATCH: Data matches at %h, Actual Data: %h, Expected Data: %h", txExpected.addr, txActual.data, txExpected.data);
			end
			else begin
				$display("ERROR: Data mismatch at %h, Actual Data: %h, Expected Data: %h", txExpected.addr, txActual.data, txExpected.data);
			end
		end
	endtask
	
	//genAllRegWrite: generating transactions to write to all the core registers
	task genAllRegWrite();
		for(int i=0;i<=2;i++) begin
			tx = new();
			assert(tx.randomize() with {tx.addr[28:0] == 4*i; tx.writeReadVar == 1'b1; tx.regMemF==1;});	//constrained write. writing to the addresses only where the core registers are located.
			mc_cfg::gen2bfm.put(tx);
			writeTxQ.push_back(tx);
		end
		for(int i=4;i<=19;i++) begin
			tx = new();
			assert(tx.randomize() with {tx.addr[28:0] == 4*i; tx.writeReadVar == 1'b1; tx.regMemF==1;});	//constrained write. writing to the addresses only where the core registers are located.
			mc_cfg::gen2bfm.put(tx);
			writeTxQ.push_back(tx);
		end
		writeComplete = 1;
	endtask
	
	task configureRegistersSRAM();
		bit [28:0] addrTemp;
		bit [31:0] dataTemp;
		bit [7:0] chipSelect;
		//no need to configure CSR reigster as all the fields are related to SDRAM
		//PoC: Read Only register, hence no need to write anything to it.
		//BA_MASK: value stored in it is 8'hFF as it holds the masl for all chip selects (hence all 1's)
		tx = new();
		assert(tx.randomize() with {tx.addr[28:0] == 29'h8; tx.writeReadVar == 1'b1; tx.regMemF==1; tx.data == 8'hFF;});			//BA_MASK address is 8, hence addr = 8, 
		mc_cfg::gen2bfm.put(tx);
		//CSCN
		for(int i=0;i<8;i++) begin
			tx = new();
			addrTemp = 16 + 8*i;
			chipSelect = 2**i;
			dataTemp = {8'h0, chipSelect, 4'h0, 1'b0, 1'b0, 1'b0, 1'b0, 2'h0, 2'h1, 3'h1, 1'b1};
			assert(tx.randomize() with {tx.addr[28:0] == addrTemp; tx.writeReadVar == 1'b1; tx.regMemF==1; tx.data == dataTemp;}); 
			mc_cfg::gen2bfm.put(tx);
		end
	endtask
	
	task generateScenariosSRAM();
		wb_tx wrTxQ[$];
		for(int i=0;i<20;i++) begin
			tx = new();
			assert(tx.randomize() with {tx.addr[31:0] inside {[`CS0_START:`CS0_END],
													[`CS1_START:`CS1_END],
													[`CS2_START:`CS2_END],
													[`CS3_START:`CS3_END],
													[`CS4_START:`CS4_END],
													[`CS5_START:`CS5_END],
													[`CS6_START:`CS6_END],
													[`CS7_START:`CS7_END]}; tx.writeReadVar == 1'b1; tx.regMemF==0;});			
			mc_cfg::gen2bfm.put(tx);
			wrTxQ.push_back(tx);
		end
		for(int i=0;i<20;i++) begin
			tx = new();
			assert(tx.randomize() with {tx.addr[31:0] == wrTxQ[i].addr; tx.writeReadVar == 1'b0; tx.regMemF==0;});	
			mc_cfg::gen2bfm.put(tx); 
		end
	endtask
	
endclass