/*
Author:Aniket Badhan
*/

class mc_env;
	
	wb_env wbEnv = new();
	mc_mon memMon = new();
	mc_ref mcRef = new();
	mc_ckr mcCkr = new();
	mc_sbd mcSbd = new();
	
	task run();
		fork
			wbEnv.run();
			memMon.run();
			mcRef.run();
			mcCkr.run();
			mcSbd.run();
		join
	endtask
	
endclass