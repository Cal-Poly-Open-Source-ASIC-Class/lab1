
Welcome to your first lab in Open Source ASIC Design!

# Getting Started
At this point, you should have followed the [Docker Installation](https://github.com/Cal-Poly-Open-Source-ASIC-Class) instructions and have already cloned the [Asic Tools](https://github.com/Cal-Poly-Open-Source-ASIC-Class/asic-tools) repository. 

- Start by __forking__ this repository, __not__ cloning it. This will create a copy that you own.
- Then, clone your forked copy into the `workspace`  folder. In other words, `cd` into `asic-tools/workspace`, and then `git clone <your forked copy>`
>#### Forking:
>![alt text](docs/fork.png)

>#### Cloning:
>![alt text](docs/clone.png)

# Lab 1 Specification

## Part 1 - RTL
Your task is to design a parameterized Fibonacci accelerator. Create a system verilog file in the `rtl` directory, and give it a name ending in `.sv`.

__System Inputs:__
- `clk`, assume positive edge triggers
- `rst_n`, an active low synchronous reset
    - Resets when signal is 0, and only on a clock edge
- `fib_in`, the nth Fibonacci number to calculate
    - This input should be a parameterized width, defaulted to 8 bits
- `vld_in`, valid in
    - goes high when fib_in is valid, indicating to start a new calculation
    - Controlled by whatever device interacts with the accelerator, or by the testbench
- `rdy_out`, ready out
    - goes high when the accelerator's output has successfully been read from 

__System Outputs:__
- `rdy_in`, held high by the accelerator when it is ready to take a new input
- `fib_out`, the final result of the calculated nth fibonacci number
- `vld_out`, held high by the accelerator when its output is ready

### Understanding the Transactions
- If the accelerator is ready to take a new input, it should hold `rdy_in` high.
- A transaction begins when the controller/testbench sets `vld_in` high and writes data to `fib_in`
- The controller/testbench waits for `vld_out` from the accelerator, indicating it can read the resulting `fib_out`.
- The accelerator holds its output as it waits for `rdy_out`, indicating that the controller/testbench has read the output. The transaction is now complete.

### Linting
Now that you have started writing your design, it is time to lint it. This will catch errors such as missed semicolons, unmatched bit widths and types, and issues that may come up later down the line. We will be using the tool Verilator for linting.

 From within the docker container, run:

```
verilator --lint-only --timing <your_verilog_file.sv>
```

It is good to get in the habit of linting every time you are done writing code. If your code is free of lint errors, the above command will give no output.

## Part 2 - Simulation

With your first draft design complete, it is time to test. Create a directory `tests/<testname>`. In that directory create a test file. Your ultimate path should be `tests/<testname>/<testname>.sv`

> [!NOTE]  
> It is important to put seperate tests in their own directories, as later on tests might involve more than one system verilog file. It would create quite a mess to have a bunch of semi-overlapping tests in the same directory.

```
verilator --timing --trace --binary tests/<testname>/<testname>.sv -I"rtl"
```
What are all these flags doing?
- Timing lets verilator simulate delays like `#1`
- Binary tells verilator to make a runnable test file
- Trace tells verilator to save simulation results to a waveform.
- `-I` tells verilator to include the following directory when looking for RTL files, enabling it to look in the `rtl` folder