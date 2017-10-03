/*
Author:Aniket Badhan
*/

//program block contains the env so that it happens in the reactive region of the execution
`include "timescale.v"
`include "sync_cs_dev.v"
`include "mt48lc16m16a2.v"
`include "mt58l1my18d.v"
`include "adv_bb.v"
`include "mc_defines.v"
`include "mc_adr_sel.v"
`include "mc_cs_rf.v"
`include "mc_dp.v"
`include "mc_incn_r.v"
`include "mc_mem_if.v"
`include "mc_obct.v"
`include "mc_obct_top.v"
`include "mc_rd_fifo.v"
`include "mc_refresh.v"
`include "mc_rf.v"
`include "mc_timing.v"
`include "mc_wb_if.v"
`include "mc_top.v"

`include "mc_cfg.sv"
`include "wb_tx.sv"
`include "wb_bfm.sv"
`include "wb_gen.sv"
`include "wb_mon.sv"
`include "wb_cov.sv"
`include "wb_intf.sv"
`include "mem_intf.sv"
`include "wb_env.sv"
`include "mem_tx.sv"
`include "mcReg.sv"
`include "mc_sbd.sv"
`include "mc_ckr.sv"
`include "mc_ref.sv"
`include "mc_mon.sv"
`include "mc_env.sv"
`include "mc_tb.sv"
`include "mc_assert.sv"

module top;
	
	reg mc_clk, rst;
	reg wb_clk;
	wire [31:0] dataToMemory;
	
	wb_intf wpif(wb_clk, rst);			//physical interface
	mem_intf mpif(mc_clk);				//physical interface
	
	mc_top dut(
		.clk_i(wpif.wb_clk), 
		.rst_i(wpif.rst),
		.wb_data_i(wpif.wb_data_i), 
		.wb_data_o(wpif.wb_data_o), 
		.wb_addr_i(wpif.wb_addr_i), 
		.wb_sel_i(wpif.wb_sel_i), 
		.wb_we_i(wpif.wb_we_i), 
		.wb_cyc_i(wpif.wb_cyc_i),
		.wb_stb_i(wpif.wb_stb_i), 
		.wb_ack_o(wpif.wb_ack_o), 
		.wb_err_o(wpif.wb_err_o), 
		.susp_req_i(wpif.susp_req_i), 
		.resume_req_i(wpif.resume_req_i), 
		.suspended_o(wpif.suspended_o), 
		.poc_o(wpif.poc_o),
		.mc_clk_i(mpif.mc_clk), 
		.mc_br_pad_i(mpif.mc_br_i),
		.mc_bg_pad_o(mpif.mc_bg_o), 
		.mc_ack_pad_i(mpif.mc_ack_i),
		.mc_addr_pad_o(mpif.mc_addr_o), 
		.mc_data_pad_i(mpif.mc_data_i), 
		.mc_data_pad_o(mpif.mc_data_o), 
		.mc_dp_pad_i(mpif.mc_dp_i),
		.mc_dp_pad_o(mpif.mc_dp_o),
		.mc_doe_pad_doe_o(mpif.mc_doe_doe_o), 
		.mc_dqm_pad_o(mpif.mc_dqm_o), 
		.mc_oe_pad_o_(mpif.mc_oe_o_),
		.mc_we_pad_o_(mpif.mc_we_o_), 
		.mc_cas_pad_o_(mpif.mc_cas_o_), 
		.mc_ras_pad_o_(mpif.mc_ras_o_), 
		.mc_cke_pad_o_(mpif.mc_cke_o_),
		.mc_cs_pad_o_(mpif.mc_cs_o_),
		.mc_sts_pad_i(mpif.mc_sts_i), 
		.mc_rp_pad_o_(mpif.mc_rp_o_),  
		.mc_vpen_pad_o(mpif.mc_vpen_o),
		.mc_adsc_pad_o_(mpif.mc_adsc_o_), 
		.mc_adv_pad_o_(mpif.mc_adv_o_), 
		.mc_zz_pad_o(mpif.mc_zz_o), 
		.mc_coe_pad_coe_o(mpif.mc_coe_coe_o));
	
	mc_tb tb();
	
	mc_assert mc_assert_i();
	
	//write mode
	assign dataToMemory = (mpif.mc_doe_doe_o == 1) ? mpif.mc_data_o : 32'hz;
	//read mode
	assign mpif.mc_data_i = (mpif.mc_doe_doe_o == 1) ? 32'hz : dataToMemory;
		
	initial begin
		wb_clk = 0;
		forever #2.5 wb_clk = ~wb_clk;
	end
	
	initial begin
		mc_clk = 0;
		forever #5 mc_clk = ~ mc_clk;
	end
	
	initial begin
		mc_cfg::mvif = mpif;					//assigning the physical interface to the virtual interface
		mc_cfg::wvif = wpif;					//assigning the physical interface to the virtual interface
		$value$plusargs("testName=%s",mc_cfg::testName);
		rst = 1;		//asserting reset
		repeat(5) @ (posedge wb_clk);
		rst = 0;		//releasing reset
	end
	
	initial begin
		#10000;
		$finish;
	end

	genvar i;
	generate
		for(i=0;i<8;i++) begin
			mt58l1my18d memSRAM_A(
				.Dq(dataToMemory[15:0]), 
				.Addr(mpif.mc_addr_o[20:0]),
				.Mode(1'b0), 			
				.Adv_n(mpif.mc_adv_o_), 
				.Clk(mpif.mc_clk), 
				.Adsc_n(mpif.mc_adsc_o_), 
				.Adsp_n(1'b1), 
				.Bwa_n(mpif.mc_dqm_o[0]), 
				.Bwb_n(mpif.mc_dqm_o[1]), 
				.Bwe_n(mpif.mc_we_o_), 
				.Gw_n(1'b1), 
				.Ce_n(mpif.mc_cs_o_[i]), 
				.Ce2(1'b1), 
				.Ce2_n(1'b0), 
				.Oe_n(mpif.mc_oe_o_), 
				.Zz(mpif.mc_zz_o));
				
			mt58l1my18d memSRAM_B(
				.Dq(dataToMemory[31:16]), 
				.Addr(mpif.mc_addr_o[20:0]),
				.Mode(1'b0), 			
				.Adv_n(mpif.mc_adv_o_), 
				.Clk(mpif.mc_clk), 
				.Adsc_n(mpif.mc_adsc_o_), 
				.Adsp_n(1'b1), 
				.Bwa_n(mpif.mc_dqm_o[0]), 
				.Bwb_n(mpif.mc_dqm_o[1]), 
				.Bwe_n(mpif.mc_we_o_), 
				.Gw_n(1'b1), 
				.Ce_n(mpif.mc_cs_o_[i]), 
				.Ce2(1'b1), 
				.Ce2_n(1'b0), 
				.Oe_n(mpif.mc_oe_o_),
				.Zz(mpif.mc_zz_o));
		end
	endgenerate 
	
endmodule