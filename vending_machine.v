module vendingMachine(
    output drop_out,
    output change_out,
    input clk,
    input reset,
    input hundred_in,
    input fifty_in
);

    wire rst = 1'b1;
    wire rstout;
    reg sel;
    reg [2:0] state, nextstate;

    parameter IDLE       = 3'b000;
    parameter HUNDRED_RS = 3'b001;
    parameter FIFTY_RS   = 3'b010;
    parameter DROPOUT    = 3'b011;
    parameter CHNGOUT    = 3'b100;

    assign rstout = sel ? rst : reset;

    // State Register
    always @ (posedge clk or posedge rstout) begin
        if (rstout)
            state <= IDLE;
        else
            state <= nextstate;
    end

    // Select signal for reset source
    always @ (negedge clk) begin
        sel <= (state == DROPOUT || state == CHNGOUT);
    end

    // Next State Logic
    always @ (*) begin
        case (state)
            IDLE: begin
                if (hundred_in & ~fifty_in)
                    nextstate = HUNDRED_RS;
                else if (fifty_in & ~hundred_in)
                    nextstate = FIFTY_RS;
                else
                    nextstate = IDLE;
            end

            HUNDRED_RS: begin
                if (hundred_in & ~fifty_in)
                    nextstate = CHNGOUT;
                else if (fifty_in & ~hundred_in)
                    nextstate = DROPOUT;
                else if (~hundred_in & ~fifty_in)
                    nextstate = HUNDRED_RS;
                else
                    nextstate = IDLE;
            end

            FIFTY_RS: begin
                if (hundred_in & ~fifty_in)
                    nextstate = DROPOUT;
                else if (fifty_in & ~hundred_in)
                    nextstate = HUNDRED_RS;
                else if (~hundred_in & ~fifty_in)
                    nextstate = FIFTY_RS;
                else
                    nextstate = IDLE;
            end

            DROPOUT: nextstate = IDLE;
            CHNGOUT: nextstate = IDLE;
            default: nextstate = IDLE;
        endcase
    end

    // Output Logic
    assign drop_out = (state == DROPOUT || state == CHNGOUT);
    assign change_out = (state == CHNGOUT);

endmodule
