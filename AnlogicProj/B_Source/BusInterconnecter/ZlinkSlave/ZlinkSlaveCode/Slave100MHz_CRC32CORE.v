module Slave100MHz_CRC32CORE(
    input               clk,
    input               rst,

    input       [7:0]   ByteStream, 
    input               ByteActive, 
    input       [15:0]  FrameBytesCount,
    input               clr,//同步清零

    output      [31:0]  CRC_Result//crc校验结果
    );
    reg     [31:0]  crc_temp;

    reg     [7:0]   table_index;
    reg     [31:0]  teble_out;

    always @ (*)begin
        case(table_index)
            8'd0 :teble_out = 32'h00000000; 8'd1 :teble_out = 32'h77073096; 8'd2 :teble_out = 32'hEE0E612C; 8'd3 :teble_out = 32'h990951BA; 8'd4 :teble_out = 32'h076DC419; 8'd5 :teble_out = 32'h706AF48F;
            8'd6 :teble_out = 32'hE963A535; 8'd7 :teble_out = 32'h9E6495A3; 8'd8 :teble_out = 32'h0EDB8832; 8'd9 :teble_out = 32'h79DCB8A4; 8'd10 :teble_out = 32'hE0D5E91E; 8'd11 :teble_out = 32'h97D2D988;
            8'd12 :teble_out = 32'h09B64C2B; 8'd13 :teble_out = 32'h7EB17CBD; 8'd14 :teble_out = 32'hE7B82D07; 8'd15 :teble_out = 32'h90BF1D91; 8'd16 :teble_out = 32'h1DB71064; 8'd17 :teble_out = 32'h6AB020F2;
            8'd18 :teble_out = 32'hF3B97148; 8'd19 :teble_out = 32'h84BE41DE; 8'd20 :teble_out = 32'h1ADAD47D; 8'd21 :teble_out = 32'h6DDDE4EB; 8'd22 :teble_out = 32'hF4D4B551; 8'd23 :teble_out = 32'h83D385C7;
            8'd24 :teble_out = 32'h136C9856; 8'd25 :teble_out = 32'h646BA8C0; 8'd26 :teble_out = 32'hFD62F97A; 8'd27 :teble_out = 32'h8A65C9EC; 8'd28 :teble_out = 32'h14015C4F; 8'd29 :teble_out = 32'h63066CD9;
            8'd30 :teble_out = 32'hFA0F3D63; 8'd31 :teble_out = 32'h8D080DF5; 8'd32 :teble_out = 32'h3B6E20C8; 8'd33 :teble_out = 32'h4C69105E; 8'd34 :teble_out = 32'hD56041E4; 8'd35 :teble_out = 32'hA2677172;
            8'd36 :teble_out = 32'h3C03E4D1; 8'd37 :teble_out = 32'h4B04D447; 8'd38 :teble_out = 32'hD20D85FD; 8'd39 :teble_out = 32'hA50AB56B; 8'd40 :teble_out = 32'h35B5A8FA; 8'd41 :teble_out = 32'h42B2986C;
            8'd42 :teble_out = 32'hDBBBC9D6; 8'd43 :teble_out = 32'hACBCF940; 8'd44 :teble_out = 32'h32D86CE3; 8'd45 :teble_out = 32'h45DF5C75; 8'd46 :teble_out = 32'hDCD60DCF; 8'd47 :teble_out = 32'hABD13D59;
            8'd48 :teble_out = 32'h26D930AC; 8'd49 :teble_out = 32'h51DE003A; 8'd50 :teble_out = 32'hC8D75180; 8'd51 :teble_out = 32'hBFD06116; 8'd52 :teble_out = 32'h21B4F4B5; 8'd53 :teble_out = 32'h56B3C423;
            8'd54 :teble_out = 32'hCFBA9599; 8'd55 :teble_out = 32'hB8BDA50F; 8'd56 :teble_out = 32'h2802B89E; 8'd57 :teble_out = 32'h5F058808; 8'd58 :teble_out = 32'hC60CD9B2; 8'd59 :teble_out = 32'hB10BE924;
            8'd60 :teble_out = 32'h2F6F7C87; 8'd61 :teble_out = 32'h58684C11; 8'd62 :teble_out = 32'hC1611DAB; 8'd63 :teble_out = 32'hB6662D3D; 8'd64 :teble_out = 32'h76DC4190; 8'd65 :teble_out = 32'h01DB7106;
            8'd66 :teble_out = 32'h98D220BC; 8'd67 :teble_out = 32'hEFD5102A; 8'd68 :teble_out = 32'h71B18589; 8'd69 :teble_out = 32'h06B6B51F; 8'd70 :teble_out = 32'h9FBFE4A5; 8'd71 :teble_out = 32'hE8B8D433;
            8'd72 :teble_out = 32'h7807C9A2; 8'd73 :teble_out = 32'h0F00F934; 8'd74 :teble_out = 32'h9609A88E; 8'd75 :teble_out = 32'hE10E9818; 8'd76 :teble_out = 32'h7F6A0DBB; 8'd77 :teble_out = 32'h086D3D2D;
            8'd78 :teble_out = 32'h91646C97; 8'd79 :teble_out = 32'hE6635C01; 8'd80 :teble_out = 32'h6B6B51F4; 8'd81 :teble_out = 32'h1C6C6162; 8'd82 :teble_out = 32'h856530D8; 8'd83 :teble_out = 32'hF262004E;
            8'd84 :teble_out = 32'h6C0695ED; 8'd85 :teble_out = 32'h1B01A57B; 8'd86 :teble_out = 32'h8208F4C1; 8'd87 :teble_out = 32'hF50FC457; 8'd88 :teble_out = 32'h65B0D9C6; 8'd89 :teble_out = 32'h12B7E950;
            8'd90 :teble_out = 32'h8BBEB8EA; 8'd91 :teble_out = 32'hFCB9887C; 8'd92 :teble_out = 32'h62DD1DDF; 8'd93 :teble_out = 32'h15DA2D49; 8'd94 :teble_out = 32'h8CD37CF3; 8'd95 :teble_out = 32'hFBD44C65;
            8'd96 :teble_out = 32'h4DB26158; 8'd97 :teble_out = 32'h3AB551CE; 8'd98 :teble_out = 32'hA3BC0074; 8'd99 :teble_out = 32'hD4BB30E2; 8'd100 :teble_out = 32'h4ADFA541; 8'd101 :teble_out = 32'h3DD895D7;
            8'd102 :teble_out = 32'hA4D1C46D; 8'd103 :teble_out = 32'hD3D6F4FB; 8'd104 :teble_out = 32'h4369E96A; 8'd105 :teble_out = 32'h346ED9FC; 8'd106 :teble_out = 32'hAD678846; 8'd107 :teble_out = 32'hDA60B8D0;
            8'd108 :teble_out = 32'h44042D73; 8'd109 :teble_out = 32'h33031DE5; 8'd110 :teble_out = 32'hAA0A4C5F; 8'd111 :teble_out = 32'hDD0D7CC9; 8'd112 :teble_out = 32'h5005713C; 8'd113 :teble_out = 32'h270241AA;
            8'd114 :teble_out = 32'hBE0B1010; 8'd115 :teble_out = 32'hC90C2086; 8'd116 :teble_out = 32'h5768B525; 8'd117 :teble_out = 32'h206F85B3; 8'd118 :teble_out = 32'hB966D409; 8'd119 :teble_out = 32'hCE61E49F;
            8'd120 :teble_out = 32'h5EDEF90E; 8'd121 :teble_out = 32'h29D9C998; 8'd122 :teble_out = 32'hB0D09822; 8'd123 :teble_out = 32'hC7D7A8B4; 8'd124 :teble_out = 32'h59B33D17; 8'd125 :teble_out = 32'h2EB40D81;
            8'd126 :teble_out = 32'hB7BD5C3B; 8'd127 :teble_out = 32'hC0BA6CAD; 8'd128 :teble_out = 32'hEDB88320; 8'd129 :teble_out = 32'h9ABFB3B6; 8'd130 :teble_out = 32'h03B6E20C; 8'd131 :teble_out = 32'h74B1D29A;
            8'd132 :teble_out = 32'hEAD54739; 8'd133 :teble_out = 32'h9DD277AF; 8'd134 :teble_out = 32'h04DB2615; 8'd135 :teble_out = 32'h73DC1683; 8'd136 :teble_out = 32'hE3630B12; 8'd137 :teble_out = 32'h94643B84;
            8'd138 :teble_out = 32'h0D6D6A3E; 8'd139 :teble_out = 32'h7A6A5AA8; 8'd140 :teble_out = 32'hE40ECF0B; 8'd141 :teble_out = 32'h9309FF9D; 8'd142 :teble_out = 32'h0A00AE27; 8'd143 :teble_out = 32'h7D079EB1;
            8'd144 :teble_out = 32'hF00F9344; 8'd145 :teble_out = 32'h8708A3D2; 8'd146 :teble_out = 32'h1E01F268; 8'd147 :teble_out = 32'h6906C2FE; 8'd148 :teble_out = 32'hF762575D; 8'd149 :teble_out = 32'h806567CB;
            8'd150 :teble_out = 32'h196C3671; 8'd151 :teble_out = 32'h6E6B06E7; 8'd152 :teble_out = 32'hFED41B76; 8'd153 :teble_out = 32'h89D32BE0; 8'd154 :teble_out = 32'h10DA7A5A; 8'd155 :teble_out = 32'h67DD4ACC;
            8'd156 :teble_out = 32'hF9B9DF6F; 8'd157 :teble_out = 32'h8EBEEFF9; 8'd158 :teble_out = 32'h17B7BE43; 8'd159 :teble_out = 32'h60B08ED5; 8'd160 :teble_out = 32'hD6D6A3E8; 8'd161 :teble_out = 32'hA1D1937E;
            8'd162 :teble_out = 32'h38D8C2C4; 8'd163 :teble_out = 32'h4FDFF252; 8'd164 :teble_out = 32'hD1BB67F1; 8'd165 :teble_out = 32'hA6BC5767; 8'd166 :teble_out = 32'h3FB506DD; 8'd167 :teble_out = 32'h48B2364B;
            8'd168 :teble_out = 32'hD80D2BDA; 8'd169 :teble_out = 32'hAF0A1B4C; 8'd170 :teble_out = 32'h36034AF6; 8'd171 :teble_out = 32'h41047A60; 8'd172 :teble_out = 32'hDF60EFC3; 8'd173 :teble_out = 32'hA867DF55;
            8'd174 :teble_out = 32'h316E8EEF; 8'd175 :teble_out = 32'h4669BE79; 8'd176 :teble_out = 32'hCB61B38C; 8'd177 :teble_out = 32'hBC66831A; 8'd178 :teble_out = 32'h256FD2A0; 8'd179 :teble_out = 32'h5268E236;
            8'd180 :teble_out = 32'hCC0C7795; 8'd181 :teble_out = 32'hBB0B4703; 8'd182 :teble_out = 32'h220216B9; 8'd183 :teble_out = 32'h5505262F; 8'd184 :teble_out = 32'hC5BA3BBE; 8'd185 :teble_out = 32'hB2BD0B28;
            8'd186 :teble_out = 32'h2BB45A92; 8'd187 :teble_out = 32'h5CB36A04; 8'd188 :teble_out = 32'hC2D7FFA7; 8'd189 :teble_out = 32'hB5D0CF31; 8'd190 :teble_out = 32'h2CD99E8B; 8'd191 :teble_out = 32'h5BDEAE1D;
            8'd192 :teble_out = 32'h9B64C2B0; 8'd193 :teble_out = 32'hEC63F226; 8'd194 :teble_out = 32'h756AA39C; 8'd195 :teble_out = 32'h026D930A; 8'd196 :teble_out = 32'h9C0906A9; 8'd197 :teble_out = 32'hEB0E363F;
            8'd198 :teble_out = 32'h72076785; 8'd199 :teble_out = 32'h05005713; 8'd200 :teble_out = 32'h95BF4A82; 8'd201 :teble_out = 32'hE2B87A14; 8'd202 :teble_out = 32'h7BB12BAE; 8'd203 :teble_out = 32'h0CB61B38;
            8'd204 :teble_out = 32'h92D28E9B; 8'd205 :teble_out = 32'hE5D5BE0D; 8'd206 :teble_out = 32'h7CDCEFB7; 8'd207 :teble_out = 32'h0BDBDF21; 8'd208 :teble_out = 32'h86D3D2D4; 8'd209 :teble_out = 32'hF1D4E242;
            8'd210 :teble_out = 32'h68DDB3F8; 8'd211 :teble_out = 32'h1FDA836E; 8'd212 :teble_out = 32'h81BE16CD; 8'd213 :teble_out = 32'hF6B9265B; 8'd214 :teble_out = 32'h6FB077E1; 8'd215 :teble_out = 32'h18B74777;
            8'd216 :teble_out = 32'h88085AE6; 8'd217 :teble_out = 32'hFF0F6A70; 8'd218 :teble_out = 32'h66063BCA; 8'd219 :teble_out = 32'h11010B5C; 8'd220 :teble_out = 32'h8F659EFF; 8'd221 :teble_out = 32'hF862AE69;
            8'd222 :teble_out = 32'h616BFFD3; 8'd223 :teble_out = 32'h166CCF45; 8'd224 :teble_out = 32'hA00AE278; 8'd225 :teble_out = 32'hD70DD2EE; 8'd226 :teble_out = 32'h4E048354; 8'd227 :teble_out = 32'h3903B3C2;
            8'd228 :teble_out = 32'hA7672661; 8'd229 :teble_out = 32'hD06016F7; 8'd230 :teble_out = 32'h4969474D; 8'd231 :teble_out = 32'h3E6E77DB; 8'd232 :teble_out = 32'hAED16A4A; 8'd233 :teble_out = 32'hD9D65ADC;
            8'd234 :teble_out = 32'h40DF0B66; 8'd235 :teble_out = 32'h37D83BF0; 8'd236 :teble_out = 32'hA9BCAE53; 8'd237 :teble_out = 32'hDEBB9EC5; 8'd238 :teble_out = 32'h47B2CF7F; 8'd239 :teble_out = 32'h30B5FFE9;
            8'd240 :teble_out = 32'hBDBDF21C; 8'd241 :teble_out = 32'hCABAC28A; 8'd242 :teble_out = 32'h53B39330; 8'd243 :teble_out = 32'h24B4A3A6; 8'd244 :teble_out = 32'hBAD03605; 8'd245 :teble_out = 32'hCDD70693;
            8'd246 :teble_out = 32'h54DE5729; 8'd247 :teble_out = 32'h23D967BF; 8'd248 :teble_out = 32'hB3667A2E; 8'd249 :teble_out = 32'hC4614AB8; 8'd250 :teble_out = 32'h5D681B02; 8'd251 :teble_out = 32'h2A6F2B94;
            8'd252 :teble_out = 32'hB40BBE37; 8'd253 :teble_out = 32'hC30C8EA1; 8'd254 :teble_out = 32'h5A05DF1B; 8'd255 :teble_out = 32'h2D02EF8D;
        endcase
    end



    always @ (posedge clk or negedge rst)
    begin
        if(!rst)
            crc_temp<=32'd0;
        else begin
            if(!clr)
                crc_temp<=32'd0;
            else begin
                if(ByteActive)
                    crc_temp<=teble_out^{8'd0,crc_temp[31:8]};
            end
        end
    end
    assign CRC_Result = ~crc_temp;

    always @ (*)
    begin
        if(FrameBytesCount<='d4)
            table_index = crc_temp[7:0] ^ (~ByteStream);
        else
            table_index = crc_temp[7:0] ^ ByteStream;

    end


endmodule


