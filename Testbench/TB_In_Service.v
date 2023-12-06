/***********************************************************
 * File: TB_In_Service.v
 * Developer: 
 * Description: 
 ************************************************************/

module In_Service_Testbench;
    // Testbench clock and reset signals
    reg clock;
    reg reset;

    // ISR module instantiation
    In_Service isr (
        .clock(clock),
        .reset(reset),
        .interrupt_request(interrupt_request),
        .end_of_interrupt(end_of_interrupt),
        .in_service_interrupt(in_service_interrupt)
    );

    // Testbench stimulus
    reg [7:0] interrupt_request;        // Testbench stimulus: Interrupt Request Lines (IRQ0 to IRQ7)
    reg end_of_interrupt;               // Testbench stimulus: End of Interrupt signal
    wire [7:0] in_service_interrupt;     // Testbench observation: In-Service Register (ISR)

    // Clock generation
    always #5 clock = ~clock;

    // Reset generation
    initial begin
        reset = 1;
        #10 reset = 0;
    end

    // Test case 1: Single interrupt request
    initial begin
        // Set an interrupt request on IRQ0
        interrupt_request = 1 << 0;
        end_of_interrupt = 0;
        #20;

        // Check if IRQ0 is in service
        if (in_service_interrupt !== 8'b00000001) begin
            $display("Test case 1 failed! Expected: 8'b00000001, Actual: %b", in_service_interrupt);
        end
    end

    // Test case 2: Multiple interrupt requests
    initial begin
        // Set interrupt requests on IRQ0, IRQ1, and IRQ2
        interrupt_request = 3'b111;
        end_of_interrupt = 0;
        #20;

        // Check if highest priority interrupt (IRQ0) is in service
        if (in_service_interrupt !== 8'b00000001) begin
            $display("Test case 2 failed! Expected: 8'b00000001, Actual: %b", in_service_interrupt);
        end

        // Set end_of_interrupt signal to clear the highest priority interrupt (IRQ0)
        interrupt_request = 0;
        end_of_interrupt = 1;
        #20;

        // Check if the next highest priority interrupt (IRQ1) is in service
        if (in_service_interrupt !== 8'b00000010) begin
            $display("Test case 2 failed! Expected: 8'b00000010, Actual: %b", in_service_interrupt);
        end
    end

    // Add more test cases as needed

    // End simulation
    initial begin
        #100;
        $finish;
    end

endmodule
