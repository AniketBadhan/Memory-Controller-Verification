/*
Author:Aniket Badhan
*/
//program block contains the env so that it happens in the reactive region of the execution
//to avoid race conditions, by executing the testbench code in reactive region
program mc_tb();
	mc_env env = new;
	
	initial begin
		env.run();
	end
	
endprogram