/**********************************************************************/
//      COPYRIGHT (C)  National Chung-Cheng University
//
// MODULE:        To Capture image pixel sequence generated from DUT
//
// FILE NAME:     image_capture.v
// CODE TYPE:     RTL model
//
// DESCRIPTION:   Use to verify image processing blocks
//                Capture output of Circuit Under Test into .tbl file
//                then convert to *.bmp file for comparing
//      
/**********************************************************************/

module image_capture(

  input        clk,
  input        rst_n,
  input [26:0] DPi,
  input [11:0] Hsize,
  input [10:0] Vsize);

// Output filename
parameter file_name = "./image_out/img_out.bmp";

// Output channels control
// (R, G, B) or (Y, Cb, Cr) or (Y, U, V) or (Y, I, Q) channels
parameter r_channel = 1;
parameter g_channel = 1;
parameter b_channel = 1;

// File handle
integer fp;

// Pixel position
integer x, y, count;

// Image size
wire [31:0] img_size = Hsize*Vsize*3;

// Header size (file header + DIB header)
// Windows and OS/2 Bitmap headers: 14 bytes (file header)
// Windows BITMAPINFOHEADER: 40 bytes (DIB header)

parameter file_header_size = 14;
parameter DIB_header_size = 40;
parameter header_size = file_header_size+DIB_header_size;

initial #1 begin


 fp = $fopen ("../image_out/img_out.bmp", "wb");
 $display ("File %s opened for writing", "../image_out/img_out.bmp");



   //fp = $fopen (file_name, "wb");
   //$display ("File %s opened for writing", file_name);

   // BMP Header
   $fwrite (fp, "%s", "BM");                 // MB header
   $fwrite (fp, "%u", img_size+header_size); // File size
   $fwrite (fp, "%u", "");                   // Reserved 1 and 2 (4 bytes in total)
   $fwrite (fp, "%u", header_size);          // Starting address of the bitmap image
   $fwrite (fp, "%u", DIB_header_size);      // DIB header size
   $fwrite (fp, "%u", Hsize);                // The bitmap width in pixels (4 bytes signed integer)
   $fwrite (fp, "%u", Vsize);                // The bitmap height in pixels (4 bytes signed integer)
   $fwrite (fp, "%c", 8'h01);                // The number of color planes must be 1 (2 bytes in total)
   $fwrite (fp, "%c", 8'h00);                // 16'h00_01 in little endian => 16'h01_00
   $fwrite (fp, "%c", 8'h18);                // The number of bits per pixel, which is the color depth of the image. (2 bytes in total)
   $fwrite (fp, "%c", 8'h00);                // 16'h00_18 in little endian => 4'h18_00 
   $fwrite (fp, "%u", "");                   // Compression method being used (4 bytes in total)
   $fwrite (fp, "%u", img_size);             // The image size. (size of the raw bitmap data)
   $fwrite (fp, "%u", 32'd3780);             // The horizontal resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp, "%u", 32'd3780);             // The vertical resolution of the image. (pixel per meter, signed integer) => 96 dpi = 3780 ppm
   $fwrite (fp, "%u", "");                   // The number of colors in the color palette, or 0 to default
   $fwrite (fp, "%u", "");                   // The number of important colors used, or 0 when every color is important; generally ignored

   count = 0;

   for (y=0;y<Vsize;y=y+1) begin
      @(posedge DPi[24]); // wait for data enable
      x = 0;
      for (x=0;x<Hsize;x=x+1) begin
         @(posedge clk); // wait for clk edge
         if (b_channel) $fwrite (fp, "%c", DPi[7:0]);
         else $fwrite (fp, "%c", 8'b0);
         if (g_channel) $fwrite (fp, "%c", DPi[15:8]);
         else $fwrite (fp, "%c", 8'b0);
         if (r_channel) $fwrite (fp, "%c", DPi[23:16]);
         else $fwrite (fp, "%c", 8'b0);
         count = count + 1;
      end
   end

   $fclose (fp);
end

endmodule
