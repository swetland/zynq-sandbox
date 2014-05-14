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
#include <unistd.h>
#include <fcntl.h>

#include "Vtestbench.h"
#include "verilated.h"
#include <verilated_vcd_c.h>

static unsigned memory[4096];

void dpi_mem_write(int addr, int data) {
	memory[addr & 0xFFF] = data;
}

void dpi_mem_read(int addr, int *data) {
	*data = (int) memory[addr & 0xFFF];
}

#ifdef TRACE
static vluint64_t now = 0;

double sc_time_stamp() {
	return now;
}
#endif

int main(int argc, char **argv) {
	const char *vcdname = "trace.vcd";
	const char *memname = NULL;
	int fd;

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
		} else if (!strcmp(argv[1], "-om")) {
			if (argc < 3) {
				fprintf(stderr, "error: -om requires argument\n");
				return -1;
			}
			memname = argv[2];
			argv += 2;
			argc -= 3;
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

	if (memname != NULL) {
		fd = open(memname, O_WRONLY | O_CREAT | O_TRUNC, 0640);
		if (fd < 0) {
			fprintf(stderr, "cannot open '%s' for writing\n", memname);
			return -1;
		}
		write(fd, memory, sizeof(memory));
		close(fd);
	}
	return 0;
}

