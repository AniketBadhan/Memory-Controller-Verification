class mem_tx;
	bit [23:0] memAddress;
	bit [31:0] memData;
	bit writeRead;
	//no need to delcare it as random as we are deriving it from the wishbone transaction or getting it from the memory, we are not going to randomize it
	function void print();
		$display("From Memory Transaction");
		$display("memory address: %h", memAddress);
		$display("memory Data: %h", memData);
		$display("memory Write/Read: %b", writeRead);
	endfunction
	
	function bit compare(mem_tx tx);
		if(this.memAddress!=tx.memAddress) return 0;
		if(this.memData!=tx.memData) return 0;
		if(this.writeRead!=tx.writeRead) return 0;
		return 1;
	endfunction
	
endclass