/*
Author:Aniket Badhan
*/

typedef enum bit {READ, WRITE} writeRead;

class wb_tx;
	rand bit [31:0] addr;
	rand bit [31:0] data;
	rand writeRead writeReadVar;
	rand bit regMemF;
	
	function void print();
		$display("Address: %h", addr);
		$display("Data: %h", data);
		$display("Write/Read: %p", writeReadVar);
	endfunction
	
	//regMemF indicates that if it is 1, then register is the target, else Memory is the target. This comes from the design already implemented (refer to mc_defines.v)
	constraint addrMSB{
		(regMemF==1) -> (addr[31:29] == 3'b011);
		(regMemF==0) -> (addr[31:29] == 3'b000);
	}
	
endclass