/*
Author:Aniket Badhan
*/

class mc_ckr;
	
	
	mem_tx expectedTransaction, actualTransaction;
	mem_tx expectedTransactionRetreived, actualTransactionRetreived;
	mem_tx expectedTransactionQ[$], actualTransactionQ[$];
	bit compareFlag;
	int countMatch = 0;
	int countMismatch = 0;
	task run();
		$display("MC CKR");
		fork
			forever begin
				mc_cfg::ref2ckr.get(expectedTransaction);
				$display("From Reference Design");
				expectedTransactionQ.push_back(expectedTransaction);
				expectedTransaction.print();
				$display("Reference Design transaction End");			
			end
			forever begin
				mc_cfg::mon2ckr.get(actualTransaction);
				$display("From Memory Monitor Design");
				actualTransactionQ.push_back(actualTransaction);
				actualTransaction.print();
				$display("Memory Monitor Transaction End");
			end
			forever begin
				wait(expectedTransactionQ.size > 0 && actualTransactionQ.size > 0);
				expectedTransactionRetreived = expectedTransactionQ.pop_front();
				actualTransactionRetreived = actualTransactionQ.pop_front();
				compareFlag = expectedTransactionRetreived.compare(actualTransactionRetreived);
				if(compareFlag==1) begin
					$display("Transaction Matched");
					$display("Expected address = %h, Actual Address = %h", expectedTransactionRetreived.memAddress, actualTransactionRetreived.memAddress);
					$display("Expected Data = %h, Actual Data = %h", expectedTransactionRetreived.memData, actualTransactionRetreived.memData);
					$display("Expected Write/Read = %h, Actual Write/Read = %h", expectedTransactionRetreived.writeRead, actualTransactionRetreived.writeRead);
					countMatch++;
					$display("Matched Count = %d", countMatch);
				end
				else begin
					$display("Transaction Mismatched");
					$display("Expected address = %h, Actual Address = %h", expectedTransactionRetreived.memAddress, actualTransactionRetreived.memAddress);
					$display("Expected Data = %h, Actual Data = %h", expectedTransactionRetreived.memData, actualTransactionRetreived.memData);
					$display("Expected Write/Read = %h, Actual Write/Read = %h", expectedTransactionRetreived.writeRead, actualTransactionRetreived.writeRead);
					countMismatch++;
					$display("Mismatched Count = %d", countMismatch);
				end
			end
		join_any
	endtask
endclass