/* Copyright 2014 Brian Swetland <swetland@frotz.net>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* reusable verilator testbench driver
 * - expects the top module to be testbench(clk);
 * - provides clk to module
 * - handles vcd tracing if compiled with TRACE
 * - allows tracefilename to be specified via -o
*/

#include <sys/types.h>

#include "Vtestbench.h"
#include "verilated.h"
#include <verilated_vcd_c.h>

#ifdef TRACE
static vluint64_t now = 0;

double sc_time_stamp() {
	return now;
}
#endif

int main(int argc, char **argv) {
	const char *vcdname = "trace.vcd";

	while (argc > 1) {
		if (!strcmp(argv[1], "-o")) {
#ifdef TRACE
			if (argc < 3) {
				fprintf(stderr,"error: -o requires argument\n");
				return -1;
			}
			vcdname = argv[2];
			argv += 2;
			argc -= 2;
			continue;
#else
			fprintf(stderr,"error: no trace support\n");
			return -1;
#endif
		} else {
			break;
		}
	}

	Verilated::commandArgs(argc, argv);
	Verilated::debug(0);
	Verilated::randReset(2);

	Vtestbench *testbench = new Vtestbench;
	testbench->clk = 0;

#ifdef TRACE
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	testbench->trace(tfp, 99);
	tfp->open(vcdname);
#endif

	while (!Verilated::gotFinish()) {
		testbench->clk = !testbench->clk;
		testbench->eval();
#ifdef TRACE
		tfp->dump(now);
		now += 5;
#endif
	}
#ifdef TRACE
	tfp->close();
#endif
	testbench->final();
	delete testbench;
	return 0;
}
