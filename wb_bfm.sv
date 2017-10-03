/*
Author:Aniket Badhan
*/

class wb_bfm;

	//BFM is independant of the DUT. It depends on the protocol. for example, in this case it is connected to wishbone interface.
	wb_tx tx;
	
	virtual wb_intf vif;
	task run();
		vif = mc_cfg::wvif; 								//getting the virtual interface handle (wishbone interface handle) 
		$display("WB BFM");
		@(negedge vif.rst);									//reset goes from 1->0 (reset is released)
		forever begin
			mc_cfg::gen2bfm.get(tx);
			tx.print();
			drive_tx(tx);
		end
	endtask
	
	task drive_tx(wb_tx tx);
		bit ackFlag;
		$display("Wishbone Interface - drive tx");
		//For the wishbone interface to initiate a transfer, wb_cyc_i and wb_stb_i should be 1. wb_stb_i indicated burst transfer
		vif.wb_cyc_i = 1'b1;				//handshaking signal
		vif.wb_stb_i = 1'b1;				//handshaking signal
		vif.wb_addr_i = tx.addr;
		vif.wb_we_i = tx.writeReadVar;
		vif.wb_sel_i = 4'hF;									//all byte access is valid
		//only when ack is asserted transaction is complete
		if(tx.writeReadVar==WRITE) begin
			vif.wb_data_i = tx.data;
		end
		ackFlag = 0;
		while(ackFlag==0) begin
			@(posedge vif.wb_clk);
			if (vif.wb_ack_o) begin
				ackFlag = 1;
				if(tx.writeReadVar==READ) begin
					tx.data = vif.wb_data_o;
					mc_cfg::bfm2gen.put(tx);						//writing back to bfm2gen so as to compare the read and write values 
				end
			end
		end
		
		//wb_cyc_i and wb_stb_i should be made zero after the transaction is complete otherwise it will be considered as another valid transaction
		@(negedge vif.wb_clk);
		ackFlag = 0;
		vif.wb_cyc_i = 1'b0;
		vif.wb_stb_i = 1'b0;
		if (tx.regMemF == 0) #100;
	endtask
	
endclass