module geofence (clk,reset,X,Y,valid,is_inside);
input			clk;
input			reset;
input	[10:0]	X;
input	[10:0]	Y;
output	reg		valid;
output	reg		is_inside;

localparam INIT = 0;
localparam READ = 1;
localparam SORT0 = 2;
localparam SORT1 = 3;
localparam AREA = 4;
localparam OUTPUT0 = 5;
localparam OUTPUT1 = 6;

reg signed [10:0] proc_buf_X [0:5];
reg signed [10:0] proc_buf_Y [0:5];


reg [2:0] cstate;
reg [2:0] nstate;

wire signed [11:0] Vx [0:4];
wire signed [11:0] Vy [0:4];

assign Vx[0] = $signed(proc_buf_X[1])-$signed(proc_buf_X[0]); // 終點-起點
assign Vx[1] = $signed(proc_buf_X[2])-$signed(proc_buf_X[0]);
assign Vx[2] = $signed(proc_buf_X[3])-$signed(proc_buf_X[0]);
assign Vx[3] = $signed(proc_buf_X[4])-$signed(proc_buf_X[0]);
assign Vx[4] = $signed(proc_buf_X[5])-$signed(proc_buf_X[0]);

assign Vy[0] = $signed(proc_buf_Y[1])-$signed(proc_buf_Y[0]);
assign Vy[1] = $signed(proc_buf_Y[2])-$signed(proc_buf_Y[0]);
assign Vy[2] = $signed(proc_buf_Y[3])-$signed(proc_buf_Y[0]);
assign Vy[3] = $signed(proc_buf_Y[4])-$signed(proc_buf_Y[0]);
assign Vy[4] = $signed(proc_buf_Y[5])-$signed(proc_buf_Y[0]);


// debug glue logic
wire [23:0] mula[0:4], mulb[0:4];
assign mula[0] = $signed(Vx[0])*$signed(Vy[1]);
assign mulb[0] = $signed(Vx[1])*$signed(Vy[0]);
assign mula[1] = $signed(Vx[1])*$signed(Vy[2]);
assign mulb[1] = $signed(Vx[2])*$signed(Vy[1]);
assign mula[2] = $signed(Vx[2])*$signed(Vy[3]);
assign mulb[2] = $signed(Vx[3])*$signed(Vy[2]);
assign mula[3] = $signed(Vx[3])*$signed(Vy[4]);
assign mulb[3] = $signed(Vx[4])*$signed(Vy[3]);
assign mula[4] = $signed(Vx[4])*$signed(Vy[0]);
assign mulb[4] = $signed(Vx[0])*$signed(Vy[4]);

wire [25:0] plane_cross[0:4];
assign plane_cross[0] = $signed(mula[0]) - $signed(mulb[0]);//$signed($signed(Vx[0])*$signed(Vy[1])) - $signed($signed(Vx[1])*$signed(Vy[0]));
assign plane_cross[1] = $signed(mula[1]) - $signed(mulb[1]);//$signed($signed(Vx[1])*$signed(Vy[2])) - $signed($signed(Vx[2])*$signed(Vy[1]));
assign plane_cross[2] = $signed(mula[2]) - $signed(mulb[2]);//$signed($signed(Vx[2])*$signed(Vy[3])) - $signed($signed(Vx[3])*$signed(Vy[2]));
assign plane_cross[3] = $signed(mula[3]) - $signed(mulb[3]);//$signed($signed(Vx[3])*$signed(Vy[4])) - $signed($signed(Vx[4])*$signed(Vy[3]));
assign plane_cross[4] = $signed(mula[4]) - $signed(mulb[4]);//$signed($signed(Vx[4])*$signed(Vy[0])) - $signed($signed(Vx[0])*$signed(Vy[4]));


wire plane_cross_any_neg = (plane_cross[0][24]|plane_cross[1][24]|plane_cross[2][24]|plane_cross[3][24]|plane_cross[4][24]);

reg [2:0] cnt; // 0-5
reg [2:0] cnt_offset;
reg signed [10:0] x0, y0, x1, y1, x2, y2;
reg signed [11:0] Ax, Ay, Bx, By;
reg signed [23:0] mul1, mul2;
reg signed [24:0] cross_product;
// reg signed [24:0] Aobj1, Aobj2, Aobj3, Aobj4;
// reg signed [25:0] Aobj1_abs, Aobj2_abs, Aobj3_abs, Aobj4_abs;
assign Ax = $signed(x1)-$signed(x0);
assign Ay = $signed(y1)-$signed(y0);
assign Bx = $signed(x2)-$signed(x0);
assign By = $signed(y2)-$signed(y0);
assign mul1 = $signed(Ax)*$signed(By);
assign mul2 = $signed(Bx)*$signed(Ay);
assign cross_product = $signed(mul1) - $signed(mul2);

// reg signed [30:0] Asix, Aobj;

// assign Aobj1 = (($signed(proc_buf_X[0])-$signed(proc_buf_X[2]))*($signed(proc_buf_Y[1])-$signed(proc_buf_Y[2]))) - (($signed(proc_buf_Y[0])-$signed(proc_buf_Y[2]))*($signed(proc_buf_X[1])-$signed(proc_buf_X[2])));
// assign Aobj2 = (($signed(proc_buf_X[0])-$signed(proc_buf_X[3]))*($signed(proc_buf_Y[2])-$signed(proc_buf_Y[3]))) - (($signed(proc_buf_Y[0])-$signed(proc_buf_Y[3]))*($signed(proc_buf_X[2])-$signed(proc_buf_X[3])));
// assign Aobj3 = (($signed(proc_buf_X[0])-$signed(proc_buf_X[4]))*($signed(proc_buf_Y[3])-$signed(proc_buf_Y[4]))) - (($signed(proc_buf_Y[0])-$signed(proc_buf_Y[4]))*($signed(proc_buf_X[3])-$signed(proc_buf_X[4])));
// assign Aobj4 = (($signed(proc_buf_X[0])-$signed(proc_buf_X[5]))*($signed(proc_buf_Y[4])-$signed(proc_buf_Y[5]))) - (($signed(proc_buf_Y[0])-$signed(proc_buf_Y[5]))*($signed(proc_buf_X[4])-$signed(proc_buf_X[5])));

// assign Aobj1_abs = $signed(Aobj1) > 0 ? Aobj1 : -Aobj1;
// assign Aobj2_abs = $signed(Aobj2) > 0 ? Aobj2 : -Aobj2;
// assign Aobj3_abs = $signed(Aobj3) > 0 ? Aobj3 : -Aobj3;
// assign Aobj4_abs = $signed(Aobj4) > 0 ? Aobj4 : -Aobj4;


int i, j;

always@(posedge clk or posedge reset)begin
        if(reset)begin
                cstate <= READ;
                valid <= 0;
                is_inside <= 0;
                cnt <= 0;
                cnt_offset <= 1;
        end
        else begin
                cstate <= nstate;
                case(cstate)
                        INIT:begin
                                
                        end
                        READ:begin
                                // Asix <= 'bx;
                                // Aobj <= 'bx;
                                is_inside <= 'bx;
                                cnt <= cnt == 5 ? 2 : cnt + 1; // cnt=2 for SORT
                                proc_buf_X[cnt] <= X;
                                proc_buf_Y[cnt] <= Y;
                        end
                        SORT0:begin // 將接收器排序
                                x0 <= proc_buf_X[1];
                                y0 <= proc_buf_Y[1];
                                x1 <= proc_buf_X[cnt];
                                y1 <= proc_buf_Y[cnt];
                                x2 <= proc_buf_X[cnt+cnt_offset];
                                y2 <= proc_buf_Y[cnt+cnt_offset];
                        end
                        SORT1:begin
                                cnt <= cnt == 4 ? 0 : cnt+cnt_offset==5 ? cnt + 1 : cnt;
                                cnt_offset <= cnt+cnt_offset==5 ? 1 : cnt_offset + 1;
                                if($signed(cross_product) < 0)begin
                                        // swap
                                        proc_buf_X[cnt] <= proc_buf_X[cnt+cnt_offset];
                                        proc_buf_X[cnt+cnt_offset] <= proc_buf_X[cnt];
                                        proc_buf_Y[cnt] <= proc_buf_Y[cnt+cnt_offset];
                                        proc_buf_Y[cnt+cnt_offset] <= proc_buf_Y[cnt];
                                end
                                
                        end
                        OUTPUT0:begin
                                valid <= 1;
                                is_inside <= plane_cross_any_neg ? 0 : 1;
                        end
                        OUTPUT1:begin
                                valid <= 0;
                                is_inside <= 'bx;;
                                cnt <= 0;
                                cnt_offset <= 1;
                        end
                endcase
        end
end

always@*begin
        if(reset)begin
                nstate = READ;
        end
        else begin
                nstate = 'bx;
                case(cstate)
                        INIT:begin
                                nstate = READ;
                        end
                        READ:begin
                                nstate = cnt == 5 ? SORT0 : READ;
                        end
                        SORT0:begin
                                nstate = SORT1;
                        end
                        SORT1:begin
                                nstate = cnt == 4 && (cnt+cnt_offset==5) ? OUTPUT0 : SORT0;
                        end
                        OUTPUT0:begin
                                nstate = OUTPUT1;
                        end
                        OUTPUT1:begin
                                nstate = READ;
                        end
                endcase
        end
end


endmodule