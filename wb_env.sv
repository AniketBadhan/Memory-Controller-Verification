/*
Author:Aniket Badhan
*/

class wb_env;
	
	wb_bfm bfm = new();
	wb_gen gen = new();
	wb_mon mon = new();
	wb_cov cov = new();

	task run();
		$display("WBENV");
		fork
			bfm.run();
			gen.run();
			mon.run();
			cov.run();
		join
	endtask
endclass