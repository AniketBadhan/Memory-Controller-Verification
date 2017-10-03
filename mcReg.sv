/*

Reg model is used to store the DUT configuration information.
Test bench can understand the design state by retrieving from register model
To model the functional coverage of DUT features, like SDRAM, SRAM
Implementation: Seperate class for each register, the class contains register bit fields as variable and write and read functions

*/

class csrRegister;
	bit [7:0] refPrescalar;
	bit [2:0] refInterval;
	bit flashSleep;
	bit fVpen;
	bit fReady;
	function void write(bit [31:0] data);
		refPrescalar = data[31:24];
		refInterval = data[10:8];
		flashSleep = data[2];
		fVpen = data[1]; 
	endfunction
	function bit [31:0] read();
		return {refPrescalar, 13'b0, refInterval, 5'b0, flashSleep, fVpen, 1'b0};
	endfunction
endclass

class baMaskRegister;
	bit [7:0] baMask;
	
	function void write(bit[31:0] data);
		baMask = data[7:0];
	endfunction
	
	function bit [31:0] read();
		return {24'b0, baMask};
	endfunction
endclass

class cscRegister;
	bit [7:0] sel;			//base address
	bit pen;				//parity enable
	bit kro;				//keep row open
	bit bas;				//bank address select
	bit wp;					//write protect
	bit [1:0] ms;			//memory size
	bit [1:0] bw;			//bus width
	bit [2:0] memType;		//memory type
	bit en;					//chip select enable
	function void write(bit [31:0] data);
		sel = data[23:16];
		pen = data[11];
		kro = data[10];
		bas = data[9];
		wp = data[8];
		ms = data[7:6];
		bw = data[5:4];
		memType = data[3:1];
		en = data[0];
	endfunction
	function bit [31:0] read();
		return {8'h0, sel, 4'h0, pen, kro, bas, wp, ms, bw, memType, en};
	endfunction
endclass

class tmsRegSDRAM;
	bit [3:0] trfc;
	bit [3:0] trp;
	bit [2:0] trcd;
	bit [1:0] twr;
	bit writeBurstLength;
	bit [1:0] operationMode;
	bit [2:0] casLatency;
	bit burstType;
	bit [2:0] burstLength;
	
	function void write(bit [31:0] data);
		trfc = data[27:24];
		trp = data[23:20];
		trcd = data[19:17];
		twr = data[16:15];
		writeBurstLength = data[9];
		operationMode = data[8:7];
		casLatency = data[6:4];
		burstType = data[3];
		burstLength = data[2:0];
	endfunction
	
	function bit [31:0] read();
		return {4'h0, trfc, trp, trcd, twr, writeBurstLength, operationMode, casLatency, burstType, burstLength};
	endfunction
	
endclass

class tmsRegAsynchCS;
	bit [5:0] twwd;
	bit [3:0] twd;
	bit [3:0] twpw;
	bit [3:0] trdz;
	bit [7:0] trdv;

	function void write(bit [31:0] data);
		twwd = data[25:20];
		twd = data[19:16];
		twpw = data[15:12];
		trdz = data[11:8];
		trdv = data[7:0];
	endfunction
	
	function bit[31:0] read();
		return {6'h0, twwd, twd, twpw, trdz, trdv};
	endfunction
	
endclass

class tmsRegSyncCS;
	bit [8:0] tto;
	bit [3:0] twr;
	bit [3:0] trdz;
	bit [7:0] trdv;
	
	function void write(bit [31:0] data);
		tto = data[24:16];
		twr = data[15:12];
		trdz = data[11:8];
		trdv = data[7:0];
	endfunction
	
	function bit [31:0] read();
		return{7'b0, tto, twr, trdz,trdv};
	endfunction
	
endclass

class mcReg;
	
	csrRegister csr;
	baMaskRegister baMaskReg;
	cscRegister cscReg[8];
	tmsRegAsynchCS tmsAsynchCS[8];
	tmsRegSDRAM tmsSDRAM[8];
	tmsRegSyncCS tmsSyncCS[8];
	
	bit [28:0] tempAddr;
	
	event config_e;
	
	covergroup mcConfig @ (config_e);
		//CSR Register (address = 29'h0)
		REF_PRESCALAR_CP	:	coverpoint csr.refPrescalar iff(tempAddr == 29'h0){
			bins LOW = {[0:50]};																
			bins MID = {[51:95]};																
			bins MID_96 = {96};
			bins MID_97 = {97};
			bins MID_98 = {98};
			bins HIGH = {[99:255]};
		}
		REF_INTERVAL_CP		:	coverpoint csr.refInterval iff(tempAddr == 29'h0);				//it will automatically create 8 bins as the value of refInterval is of size 3 bits
		FS_CP				:	coverpoint csr.flashSleep iff(tempAddr == 29'h0);
		FVPEN_CP			:	coverpoint csr.fVpen iff(tempAddr == 29'h0);
		
		//BA Mask register (address = 29'h8)
		BAMASK_CP			:	coverpoint baMaskReg.baMask iff(tempAddr == 29'h8){
			option.auto_bin_max = 8;															//explicitly asking for creting 8 bins only
		}
		
		//CSCO (address = 29'h10)
		CSC0_SEL_CP 	:	coverpoint cscReg[0].sel iff (tempAddr == 29'h10) {
			option.auto_bin_max = 8;
		}
		CSC0_PEN_CP 	: 	coverpoint cscReg[0].pen iff (tempAddr == 29'h10);
		CSC0_KRO_CP 	: 	coverpoint cscReg[0].kro iff (tempAddr == 29'h10);
		CSC0_BAS_CP 	: 	coverpoint cscReg[0].bas iff (tempAddr == 29'h10);
		CSC0_WP_CP 		: 	coverpoint cscReg[0].wp iff (tempAddr == 29'h10);
		CSC0_MS_CP 		: 	coverpoint cscReg[0].ms  iff(tempAddr == 29'h10){
			ignore_bins ING = {2'b11};
		}
		CSC0_BW_CP : coverpoint cscReg[0].bw  iff(tempAddr == 29'h10){
			ignore_bins ING = {2'b11};
		}
		cross CSC0_BW_CP, CSC0_MS_CP; //9 bins in total
		CSC0_MEMTYPE_CP : coverpoint cscReg[0].memType iff (tempAddr == 29'h10){
			bins SDRAM = {0};
			bins SSRAM = {1};
			bins FLASH = {2};
			bins SCSD = {3};
			ignore_bins ING= {[4:7]};
		}
		cross CSC0_MEMTYPE_CP, CSC0_MS_CP;
		CSC0_EN_CP : coverpoint cscReg[0].en iff (tempAddr == 29'h10);
	endgroup

	function new();
		csr = new();
		baMaskReg = new();
		for(int i=0;i<8;i++) begin
			cscReg[i] = new();
			tmsAsynchCS[i] = new();
			tmsSDRAM[i] = new();
			tmsSyncCS[i] = new();
		end	
	endfunction
	
	function void writeReg(bit [31:0] addr, bit [31:0] data);
		if(addr[28:0]==29'h0) csr.write(data);
		if(addr[28:0]==29'h8) baMaskReg.write(data);
		
		if(addr[28:0]==29'h10) cscReg[0].write(data);
		if(addr[28:0]==29'h14 && cscReg[0].memType == 0) tmsSDRAM[0].write(data);
		if(addr[28:0]==29'h14 && cscReg[0].memType == 2) tmsAsynchCS[0].write(data);
		if(addr[28:0]==29'h14 && cscReg[0].memType == 3) tmsSyncCS[0].write(data);
		
		if(addr[28:0]==29'h18) cscReg[1].write(data);
		if(addr[28:0]==29'h1C && cscReg[1].memType == 0) tmsSDRAM[1].write(data);
		if(addr[28:0]==29'h1C && cscReg[1].memType == 2) tmsAsynchCS[1].write(data);
		if(addr[28:0]==29'h1C && cscReg[1].memType == 3) tmsSyncCS[1].write(data);
		
		if(addr[28:2]==29'h20) cscReg[2].write(data);
		if(addr[28:2]==29'h24 && cscReg[2].memType == 0) tmsSDRAM[2].write(data);
		if(addr[28:2]==29'h24 && cscReg[2].memType == 2) tmsAsynchCS[2].write(data);
		if(addr[28:2]==29'h24 && cscReg[2].memType == 3) tmsSyncCS[2].write(data);
		
		if(addr[28:0]==29'h28) cscReg[3].write(data);
		if(addr[28:0]==29'h2C && cscReg[3].memType == 0) tmsSDRAM[3].write(data);
		if(addr[28:0]==29'h2C && cscReg[3].memType == 2) tmsAsynchCS[3].write(data);
		if(addr[28:0]==29'h2C && cscReg[3].memType == 3) tmsSyncCS[3].write(data);
		
		if(addr[28:0]==29'h30) cscReg[4].write(data);
		if(addr[28:0]==29'h34 && cscReg[4].memType == 0) tmsSDRAM[4].write(data);
		if(addr[28:0]==29'h34 && cscReg[4].memType == 2) tmsAsynchCS[4].write(data);
		if(addr[28:0]==29'h34 && cscReg[4].memType == 3) tmsSyncCS[4].write(data);
		
		if(addr[28:0]==29'h38) cscReg[5].write(data);
		if(addr[28:0]==29'h3C && cscReg[5].memType == 0) tmsSDRAM[5].write(data);
		if(addr[28:0]==29'h3C && cscReg[5].memType == 2) tmsAsynchCS[5].write(data);
		if(addr[28:0]==29'h3C && cscReg[5].memType == 3) tmsSyncCS[5].write(data);
		
		if(addr[28:0]==29'h40) cscReg[6].write(data);
		if(addr[28:0]==29'h44 && cscReg[6].memType == 0) tmsSDRAM[6].write(data);
		if(addr[28:0]==29'h44 && cscReg[6].memType == 2) tmsAsynchCS[6].write(data);
		if(addr[28:0]==29'h44 && cscReg[6].memType == 3) tmsSyncCS[6].write(data);
		
		if(addr[28:0]==29'h48) cscReg[7].write(data);
		if(addr[28:0]==29'h4C && cscReg[7].memType == 0) tmsSDRAM[7].write(data);
		if(addr[28:0]==29'h4C && cscReg[7].memType == 2) tmsAsynchCS[7].write(data);
		if(addr[28:0]==29'h4C  && cscReg[7].memType == 3) tmsSyncCS[7].write(data);
		
		tempAddr = addr[28:0];
		-> config_e;
		
	endfunction
	
	function bit [31:0] readReg(bit [31:0] addr);
		if(addr[28:0]==29'h0) return csr.read();
		if(addr[28:0]==29'h8) return baMaskReg.read();
		
		if(addr[28:0]==29'h10) return cscReg[0].read();
		if(addr[28:0]==29'h14 && cscReg[0].memType == 0) return tmsSDRAM[0].read();
		if(addr[28:0]==29'h14 && cscReg[0].memType == 2) return tmsAsynchCS[0].read();
		if(addr[28:0]==29'h14 && cscReg[0].memType == 3) return tmsSyncCS[0].read();
		
		if(addr[28:0]==29'h18) return cscReg[1].read();
		if(addr[28:0]==29'h1C && cscReg[1].memType == 0) return tmsSDRAM[1].read();
		if(addr[28:0]==29'h1C && cscReg[1].memType == 2) return tmsAsynchCS[1].read();
		if(addr[28:0]==29'h1C && cscReg[1].memType == 3) return tmsSyncCS[1].read();
		
		if(addr[28:2]==29'h20) return cscReg[2].read();
		if(addr[28:2]==29'h24 && cscReg[2].memType == 0) return tmsSDRAM[2].read();
		if(addr[28:2]==29'h24 && cscReg[2].memType == 2) return tmsAsynchCS[2].read();
		if(addr[28:2]==29'h24 && cscReg[2].memType == 3) return tmsSyncCS[2].read();
		
		if(addr[28:0]==29'h28) return cscReg[3].read();
		if(addr[28:0]==29'h2C && cscReg[3].memType == 0) return tmsSDRAM[3].read();
		if(addr[28:0]==29'h2C && cscReg[3].memType == 2) return tmsAsynchCS[3].read();
		if(addr[28:0]==29'h2C && cscReg[3].memType == 3) return tmsSyncCS[3].read();
		
		if(addr[28:0]==29'h30) return cscReg[4].read();
		if(addr[28:0]==29'h34 && cscReg[4].memType == 0) return tmsSDRAM[4].read();
		if(addr[28:0]==29'h34 && cscReg[4].memType == 2) return tmsAsynchCS[4].read();
		if(addr[28:0]==29'h34 && cscReg[4].memType == 3) return tmsSyncCS[4].read();
		
		if(addr[28:0]==29'h38) return cscReg[5].read();
		if(addr[28:0]==29'h3C && cscReg[5].memType == 0) return tmsSDRAM[5].read();
		if(addr[28:0]==29'h3C && cscReg[5].memType == 2) return tmsAsynchCS[5].read();
		if(addr[28:0]==29'h3C && cscReg[5].memType == 3) return tmsSyncCS[5].read();
		
		if(addr[28:0]==29'h40) return cscReg[6].read();
		if(addr[28:0]==29'h44 && cscReg[6].memType == 0) return tmsSDRAM[6].read();
		if(addr[28:0]==29'h44 && cscReg[6].memType == 2) return tmsAsynchCS[6].read();
		if(addr[28:0]==29'h44 && cscReg[6].memType == 3) return tmsSyncCS[6].read();
		
		if(addr[28:0]==29'h48) return cscReg[7].read();
		if(addr[28:0]==29'h4C && cscReg[7].memType == 0) return tmsSDRAM[7].read();
		if(addr[28:0]==29'h4C && cscReg[7].memType == 2) return tmsAsynchCS[7].read();
		if(addr[28:0]==29'h4C  && cscReg[7].memType == 3) return tmsSyncCS[7].read();
	
	endfunction
	
endclass