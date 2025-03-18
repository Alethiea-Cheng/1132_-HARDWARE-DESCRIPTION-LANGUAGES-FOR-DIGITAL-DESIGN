module top(
            input [3:0] A,
            input [3:0] B,
            input Cin,
            output [3:0] S,
            output Cout
);

reg [3:0] P, G, Ctmp, PandCis1;

and(G[0], A[0], B[0]);
xor(P[0], A[0], B[0]);
and(G[1], A[1], B[1]);
xor(P[1], A[1], B[1]);
and(G[2], A[2], B[2]);
xor(P[2], A[2], B[2]);
and(G[3], A[3], B[3]);
xor(P[3], A[3], B[3]);

xor(S[0], P[0], Cin);
xor(S[1], P[1], Ctmp[0]);
xor(S[2], P[2], Ctmp[1]);
xor(S[3], P[3], Ctmp[2]);

and(PandCis1[0], P[0], Cin);
or(Ctmp[0], G[0], PandCis1[0]);
and(PandCis1[1], P[1], Ctmp[0]);
or(Ctmp[1], G[1], PandCis1[1]);
and(PandCis1[2], P[2], Ctmp[1]);
or(Ctmp[2], G[2], PandCis1[2]);
and(PandCis1[3], P[3], Ctmp[2]);
or(Ctmp[3], G[3], PandCis1[3]);

buf(Cout, Ctmp[3]);
// genvar i;

// // P, G
// generate 
//         for( i = 0; i < 4; i = i + 1)begin: gen_P_G
//                 and(G[i], A[i], B[i]);
//                 xor(P[i], A[i], B[i]);
//         end
// endgenerate

// // S
// xor(S[0], P[0], Cin);
// generate 
//         for(i = 1 ; i < 4; i = i + 1)begin:gen_S
//                 xor(S[i], P[i], Ctmp[i-1]);
//         end
// endgenerate

// // C
// and(PandCis1[0], P[0], Cin);
// or(Ctmp[0], G[0], PandCis1[0]);
// generate;
//         for(i = 1 ; i < 4; i = i + 1 )begin: gen_C
//                 and(PandCis1[i], P[i], Ctmp[i-1]);
//                 or(Ctmp[i], G[i], PandCis1[i]);
//         end
// endgenerate

// assign Cout = Ctmp[3];


endmodule