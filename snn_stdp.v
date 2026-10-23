// snn_stdp_layer
// 8-Neuron SNN Layer with On-Chip STDP Learning Rule
module snn_stdp #(
    parameter NEURONS = 8, // Number of output neurons
    parameter INPUTS = 8, // Number of input synapses per neuron
    parameter WEIGHT_WIDTH = 8, // Bit-width of synaptic weights (unsigned)
    parameter V_WIDTH = 16 // Bit-width of membrane potential
)(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire learning_enable, // Global enable for STDP weight updates
    
    // External Configuration Parameters
    input wire [V_WIDTH-1:0] v_thresh, // Spike firing threshold
    input wire [V_WIDTH-1:0] v_rest, // Reset membrane potential
    input wire [1:0] leak_shift, // Leak rate (V_mem = V_mem >> leak_shift)
    input wire [WEIGHT_WIDTH-1:0] stdp_lr, // STDP Learning rate delta
    
    // Spike Interfaces
    input wire [INPUTS-1:0] in_spikes, // Pre-synaptic input spikes
    output reg [NEURONS-1:0] out_spikes // Post-synaptic output spikes
);

    integer i, j;
    wire rst_n;
    assign rst_n = ~reset;
    // Local Registers & Arrays
    reg [V_WIDTH-1:0] v_mem [0:NEURONS-1];
    reg [WEIGHT_WIDTH-1:0] weights [0:NEURONS-1][0:INPUTS-1];
    reg [7:0] pre_trace [0:INPUTS-1]; // Pre-synaptic spike history trace
    reg [7:0] post_trace[0:NEURONS-1]; // Post-synaptic spike history trace
    
    // Internal Combinational Accumulators
    reg [V_WIDTH-1:0] synaptic_current [0:NEURONS-1];

    // 1. Synaptic Weight Integration (Combinational Summing)
    always @(*) begin
        for (i = 0; i < NEURONS; i = i + 1) begin
            synaptic_current[i] = {V_WIDTH{1'b0}};
            for (j = 0; j < INPUTS; j = j + 1) begin
                if (in_spikes[j]) begin
                    synaptic_current[i] = synaptic_current[i] + weights[i][j];
                end
            end
        end
    end

    // 2. STDP Trace Decay & Tracking Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (j = 0; j < INPUTS; j = j + 1) pre_trace[j] <= 8'd0;
            for (i = 0; i < NEURONS; i = i + 1) post_trace[i] <= 8'd0;
        end else if (enable) begin
            // Decay existing pre-synaptic traces and set on new spike
            for (j = 0; j < INPUTS; j = j + 1) begin
                pre_trace[j] <= in_spikes[j] ? 8'd255 : (pre_trace[j] >> 1);
            end
            // Decay existing post-synaptic traces and set on new spike
            for (i = 0; i < NEURONS; i = i + 1) begin
                post_trace[i] <= out_spikes[i] ? 8'd255 : (post_trace[i] >> 1);
            end
        end
    end

    // 3. LIF State Machine & STDP Weight Update Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_spikes <= {NEURONS{1'b0}};
            for (i = 0; i < NEURONS; i = i + 1) begin
                v_mem[i] <= v_rest;
                for (j = 0; j < INPUTS; j = j + 1) begin
                    weights[i][j] <= 8'd128; // Initialize weights to mid-scale
                end
            end
        end else if (enable) begin
            for (i = 0; i < NEURONS; i = i + 1) begin
                
                // --- LIF Membrane Potential Update ---
                if (v_mem[i] >= v_thresh) begin
                    out_spikes[i] <= 1'b1;
                    v_mem[i] <= v_rest;
                end else begin
                    out_spikes[i] <= 1'b0;
                    v_mem[i] <= (v_mem[i] - (v_mem[i] >> leak_shift)) + synaptic_current[i];
                end

                // --- STDP Weight Plasticity Mechanism ---
                if (learning_enable) begin
                    for (j = 0; j < INPUTS; j = j + 1) begin
                        // Long-Term Potentiation (LTP): Pre-spike arrived right before Post-spike
                        if (out_spikes[i] && pre_trace[j] > 8'd32) begin
                            if (weights[i][j] + stdp_lr <= 8'd255)
                                weights[i][j] <= weights[i][j] + stdp_lr;
                            else
                                weights[i][j] <= 8'd255; // Saturation Cap
                        end
                        // Long-Term Depression (LTD): Post-spike arrived right before Pre-spike
                        else if (in_spikes[j] && post_trace[i] > 8'd32) begin
                            if (weights[i][j] >= stdp_lr)
                                weights[i][j] <= weights[i][j] - stdp_lr;
                            else
                                weights[i][j] <= 8'd0; // Saturation Floor
                        end
                    end
                end

            end
        end else begin
            out_spikes <= {NEURONS{1'b0}};
        end
    end

endmodule

