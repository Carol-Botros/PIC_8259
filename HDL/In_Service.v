/***********************************************************
 * File: In_Service.v
 * Developer: Carol Botros
 * Description: In-Service Register Functions
 ************************************************************/

module In_Service (
    input   logic           clock,
    input   logic           reset,

    // Inputs
    input   logic   [7:0]   interrupt_request,        // Interrupt Request Lines (IRQ0 to IRQ7)
    input   logic           end_of_interrupt,    

    // Outputs
    output  logic   [7:0]   in_service_interrupt       // In-Service Register (ISR)
);
    // In-service register

    logic   [7:0]   next_in_service_register;
    logic   [7:0]   next_highest_level_in_service;

    always_ff @(posedge clock or negedge reset) begin
        if (~reset) begin
            // Reset ISR on reset signal
            in_service_interrupt <= 8'b00000000;
        end else begin
            // Update ISR on positive clock edge
            in_service_interrupt <= next_in_service_register;
        end
    end

    // Logic to compute the next values for the registers
    always_ff @(posedge clock or negedge reset) begin
        if (~reset) begin
            next_in_service_register <= 8'b00000000;
            next_highest_level_in_service <= 8'b00000000;
        end else begin
            // Update the In-Service Register based on interrupt_request and end_of_interrupt signals
            {next_in_service_register, next_highest_level_in_service} <= update_isr(in_service_interrupt, interrupt_request, end_of_interrupt);
        end
    end

    // Additional logic for computing the next ISR 
    function logic [7:0] update_isr(logic [7:0] isr, logic [7:0] irq, logic eoi);
        logic [7:0] next_isr;
        logic [7:0] next_highest;

        // Find the highest priority interrupt request
        next_highest = 8'b00000000;
        for (int i = 0; i < 8; i = i + 1) begin
            if (irq[i] && ~isr[i]) begin
                next_highest = i + 1;
                break;
            end
        end

        // Update the ISR based on EOI and priority
        next_isr = isr;
        if (eoi) begin
            // If EOI is true, clear the highest priority interrupt
            next_isr[next_highest - 1] = 0;
        end else if (next_highest != 8'b00000000) begin
            // If there is a valid highest priority interrupt, set it in the ISR
            next_isr[next_highest - 1] = 1;
        end

        // Return the computed values
        update_isr = next_isr;
    endfunction

endmodule
