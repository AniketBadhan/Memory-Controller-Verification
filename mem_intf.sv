/*
Author:Aniket Badhan
*/

interface mem_intf(input logic mc_clk);

	logic		mc_br_i;
	logic		mc_bg_o;
	logic		mc_ack_i;
	logic	[23:0]	mc_addr_o;
	logic	[31:0]	mc_data_i;
	logic	[31:0]	mc_data_o;
	logic	[3:0]	mc_dp_i;
	logic	[3:0]	mc_dp_o;
	logic		mc_doe_doe_o;
	logic	[3:0]	mc_dqm_o;
	logic		mc_oe_o_;
	logic		mc_we_o_;
	logic		mc_cas_o_;
	logic		mc_ras_o_;
	logic		mc_cke_o_;
	logic	[7:0]	mc_cs_o_;
	logic		mc_sts_i;
	logic		mc_rp_o_;
	logic		mc_vpen_o;
	logic		mc_adsc_o_;
	logic		mc_adv_o_;
	logic		mc_zz_o;
	logic		mc_coe_coe_o;
	 
endinterface