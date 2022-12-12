module jxli_fp8mul (
  input [7:0] io_in,
  output [7:0] io_out,
);  
  // 7   6   5   4   3   2   1   0
  //###  DATA........... EN  RST CLK

  enum logic [2:0] {
    AHIGH, ALOW,
    BHIGH, BLOW,
    CALC1,

  } state;

  wire clock  = io_in[0];
  wire reset  = io_in[1];
  wire enable  = io_in[2];
  wire [3:0] data = io_in[6:3];

  // E4M3
  // 5 bits exponent registers
  reg [4:0] ae, be, ce;
  // 4 bits mantissa registers
  reg [3:0] am, bm, cm;

  reg [7:0] a, b, c;

  always_ff @(posedge clock) begin
    case(state)
      AHIGH: begin
        if (enable) begin
          a[7:4] <= data
          state <= ALOW
        end
      end

      ALOW: begin
        if (enable) begin
          a[3:0] <= data
          state <= BHIGH
        end
      end

      BHIGH: begin
        if (enable) begin
          b[7:4] <= data
          state <= BLOW
        end
      end

      BLOW: begin
        if (enable) begin
        b[3:0] <= data
        state <= BLOW
        end
      end

      CALC1: begin
        ae <= a[6:3]
        am <= a[]
      end

      CALC2: begin

        assign {as, ae, am} = a;
        assign {bs, be, bm} = b;

        c[7] <= as ^ bs;
        
        if (ae == 3'b111 && am != 3'b000) || (be == 3'b111 && bm != 3'b000) begin 
          // a is NaN or b is NaN, c is NaN
          c[6:0] <= 7'b111_1111
        end else if (ae == 3'b111) begin 
          // a or b is infty, c is infty
          if ({be, bm} == 7'b000_0000) begin
            // b == 0, c = NaN
            c[6:0] <= 7'b111_1111
          end else begin
            // b != 0, c = infty
            c[6:0] <= 7'b111_0000
          end
        end else if (be == 3'b111) begin
          if ({ae, am} == 7'b000_0000) begin
            // a == 0, c = NaN
            c[6:0] <= 7'b111_1111
          end else begin
            // a != 0, c = infty
            c[6:0] <= 7'b111_0000
          end
        end else if ({ae, am} == 7'b000_0000 || {be, bm} == 7'b000_0000) begin
          // a == 0 or b == 0, c = 0
          c[6:0] <= 7'b000_0000
        end else {
          // denormalize numbers
          if (ae == 3'b000) begin

          end else begin

          end

          if (be == 3'b000) begin

          end else begin

          end
        }
      end

      
    endcase

    if(reset) begin
      state <= AHIGH
      c <= 8'b1111_1111
    end
    
  end


endmodule
