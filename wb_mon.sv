/*
Author:Aniket Badhan
*/


//take data from the generator and pass it to coverage and reference model
class wb_mon;
	
	wb_tx txReceived;
	virtual wb_intf vif;
	
	task run();
		vif = mc_cfg::wvif;
		$display("WBMON");
		forever begin
			@(negedge vif.wb_clk);
			if(vif.wb_cyc_i && vif.wb_stb_i && vif.wb_ack_o) begin
				txReceived = new();
				txReceived.addr = vif.wb_addr_i;
				if(vif.wb_we_i) begin
					txReceived.writeReadVar = WRITE;
					txReceived.data = vif.wb_data_i;
				end
				else begin
					txReceived.writeReadVar = READ;
					txReceived.data = vif.wb_data_o;
				end
				if(vif.wb_addr_i[31:29] == 3'b011) begin
					txReceived.regMemF=1;
				end
				if(vif.wb_addr_i[31:29] == 3'b000) begin
					txReceived.regMemF=0;
				end
				mc_cfg::wb_mon2ref.put(txReceived);
				mc_cfg::wb_mon2cov.put(txReceived);
			end
		end
	endtask
	
endclass