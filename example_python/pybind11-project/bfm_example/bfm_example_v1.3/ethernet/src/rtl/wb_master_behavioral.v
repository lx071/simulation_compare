`include "wb_model_defines.v"
`include "timescale.v"
module WB_MASTER_BEHAVIORAL
(
    CLK_I,
    RST_I,
    TAG_I,
    TAG_O,
    ACK_I,
    ADR_O,
    CYC_O,
    DAT_I,
    DAT_O,
    ERR_I,
    RTY_I,
    SEL_O,
    STB_O,
    WE_O,
    CAB_O
);

    input                    CLK_I;
    input                    RST_I;
    input    `WB_TAG_TYPE    TAG_I;
    output   `WB_TAG_TYPE    TAG_O;
    input                    ACK_I;
    output   `WB_ADDR_TYPE   ADR_O;
    output                   CYC_O;
    input    `WB_DATA_TYPE   DAT_I;
    output   `WB_DATA_TYPE   DAT_O;
    input                    ERR_I;
    input                    RTY_I;
    output   `WB_SEL_TYPE    SEL_O;
    output                   STB_O;
    output                   WE_O;
    output                   CAB_O;

// instantiate low level master module
WB_MASTER32 wbm_low_level
(
    .CLK_I(CLK_I),
    .RST_I(RST_I),
    .TAG_I(TAG_I),
    .TAG_O(TAG_O),
    .ACK_I(ACK_I),
    .ADR_O(ADR_O),
    .CYC_O(CYC_O),
    .DAT_I(DAT_I),
    .DAT_O(DAT_O),
    .ERR_I(ERR_I),
    .RTY_I(RTY_I),
    .SEL_O(SEL_O),
    .STB_O(STB_O),
    .WE_O(WE_O),
    .CAB_O(CAB_O)
) ;

// block read and write buffers definition
// single write buffer
reg `WRITE_STIM_TYPE  blk_write_data    [0:(`MAX_BLK_SIZE - 1)] ;
// read stimulus buffer - addresses, tags, selects etc.
reg `READ_STIM_TYPE   blk_read_data_in  [0:(`MAX_BLK_SIZE - 1)] ;
// read return buffer - data and tags received while performing block reads
reg `READ_RETURN_TYPE blk_read_data_out [0:(`MAX_BLK_SIZE - 1)] ;

// single write task
task wb_single_write ;
    input `WRITE_STIM_TYPE write_data ;
    input `WB_TRANSFER_FLAGS   write_flags ;
    inout `WRITE_RETURN_TYPE ret;
    reg in_use ;
    reg cab ;
    reg ok ;
    integer cyc_count ;
    integer rty_count ;
    reg retry ;
begin:main

    ret`TB_ERROR_BIT = 1'b0 ;
    cab = 0 ;
    ret`CYC_ACTUAL_TRANSFER = 0 ;
    rty_count = 0 ;

    // check if task was called before previous call finished
    if ( in_use === 1 )
    begin
        $display("*E, wb_single_write routine re-entered! Time %t ", $time) ;
        ret`TB_ERROR_BIT = 1'b1 ;
        disable main ;
    end

    in_use = 1 ;

    retry = 1 ;

    while (retry === 1)
    begin
        // synchronize operation to clock
        @(posedge CLK_I) ;

        wbm_low_level.start_cycle(cab, 1'b1, ok) ;
        if ( ok !== 1 )
        begin
            $display("*E, Failed to initialize cycle! Routine wb_single_write, Time %t ", $time) ;
            ret`TB_ERROR_BIT = 1'b1 ;
            disable main ;
        end

        // first insert initial wait states
        cyc_count = write_flags`INIT_WAITS ;
        while ( cyc_count > 0 )
        begin
            @(posedge CLK_I) ;
            cyc_count = cyc_count - 1 ;
        end

        wbm_low_level.wbm_write(write_data, ret) ;

        if ( ret`CYC_ERR === 0 && ret`CYC_ACK === 0 && ret`CYC_RTY === 1 && write_flags`WB_TRANSFER_AUTO_RTY === 1 && ret`TB_ERROR_BIT === 0)
        begin
            if ( rty_count === `WB_TB_MAX_RTY )
            begin
                 $display("*E, maximum number of retries received - access will not be repeated anymore! Routine wb_single_write, Time %t ", $time) ;
                 retry = 0 ;
            end
            else
            begin
                retry     = 1 ;
                rty_count = rty_count + 1 ;
            end
        end
        else
            retry = 0 ;

        // if test bench error bit is set, there is no meaning in introducing subsequent wait states
        if ( ret`TB_ERROR_BIT !== 0 )
        begin
            @(posedge CLK_I) ;
            wbm_low_level.end_cycle ;
            disable main ;
        end

        cyc_count = write_flags`SUBSEQ_WAITS ;
        while ( cyc_count > 0 )
        begin
            @(posedge CLK_I) ;
            cyc_count = cyc_count - 1 ;
        end

        wbm_low_level.end_cycle ;
    end

    in_use = 0 ;

end //main
endtask // wb_single_write

task wb_single_read ;
    input `READ_STIM_TYPE read_data ;
    input `WB_TRANSFER_FLAGS   read_flags ;
    inout `READ_RETURN_TYPE ret;
    reg in_use ;
    reg cab ;
    reg ok ;
    integer cyc_count ;
    integer rty_count ;
    reg retry ;
begin:main

    ret`TB_ERROR_BIT = 1'b0 ;
    cab = 0 ;
    rty_count = 0 ;
    ret`CYC_ACTUAL_TRANSFER = 0 ;

    // check if task was called before previous call finished
    if ( in_use === 1 )
    begin
        $display("*E, wb_single_read routine re-entered! Time %t ", $time) ;
        ret`TB_ERROR_BIT = 1'b1 ;
        disable main ;
    end

    in_use = 1 ;

    retry = 1 ;

    while (retry === 1)
    begin
        // synchronize operation to clock
        @(posedge CLK_I) ;

        wbm_low_level.start_cycle(cab, 1'b0, ok) ;
        if ( ok !== 1 )
        begin
            $display("*E, Failed to initialize cycle! Routine wb_single_read, Time %t ", $time) ;
            ret`TB_ERROR_BIT = 1'b1 ;
            disable main ;
        end

        // first insert initial wait states
        cyc_count = read_flags`INIT_WAITS ;
        while ( cyc_count > 0 )
        begin
            @(posedge CLK_I) ;
            cyc_count = cyc_count - 1 ;
        end

        wbm_low_level.wbm_read(read_data, ret) ;

        if ( ret`CYC_ERR === 0 && ret`CYC_ACK === 0 && ret`CYC_RTY === 1 && read_flags`WB_TRANSFER_AUTO_RTY === 1 && ret`TB_ERROR_BIT === 0)
        begin
           if ( rty_count === `WB_TB_MAX_RTY )
            begin
                 $display("*E, maximum number of retries received - access will not be repeated anymore! Routine wb_single_read, Time %t ", $time) ;
                 retry = 0 ;
            end
            else
            begin
                retry     = 1 ;
                rty_count = rty_count + 1 ;
            end
        end
        else
        begin
            retry = 0 ;
        end

        // if test bench error bit is set, there is no meaning in introducing subsequent wait states
        if ( ret`TB_ERROR_BIT !== 0 )
        begin
            @(posedge CLK_I) ;
            wbm_low_level.end_cycle ;
            disable main ;
        end

        cyc_count = read_flags`SUBSEQ_WAITS ;
        while ( cyc_count > 0 )
        begin
            @(posedge CLK_I) ;
            cyc_count = cyc_count - 1 ;
        end

        wbm_low_level.end_cycle ;
    end

    in_use = 0 ;

end //main
endtask // wb_single_read

task wb_RMW_read ;
    input `READ_STIM_TYPE read_data ;
    input `WB_TRANSFER_FLAGS   read_flags ;
    inout `READ_RETURN_TYPE ret;
    reg in_use ;
    reg cab ;
    reg ok ;
    integer cyc_count ;
    integer rty_count ;
    reg retry ;
begin:main

    ret`TB_ERROR_BIT = 1'b0 ;
    cab = 0 ;
    rty_count = 0 ;
    ret`CYC_ACTUAL_TRANSFER = 0 ;

    // check if task was called before previous call finished
    if ( in_use === 1 )
    begin
        $display("*E, wb_RMW_read routine re-entered! Time %t ", $time) ;
        ret`TB_ERROR_BIT = 1'b1 ;
        disable main ;
    end

    in_use = 1 ;

    retry = 1 ;

    while (retry === 1)
    begin
        // synchronize operation to clock
        @(posedge CLK_I) ;

        wbm_low_level.start_cycle(cab, 1'b0, ok) ;
        if ( ok !== 1 )
        begin
            $display("*E, Failed to initialize cycle! Routine wb_RMW_read, Time %t ", $time) ;
            ret`TB_ERROR_BIT = 1'b1 ;
            disable main ;
        end

        // first insert initial wait states
        cyc_count = read_flags`INIT_WAITS ;
        while ( cyc_count > 0 )
        begin
            @(posedge CLK_I) ;
            cyc_count = cyc_count - 1 ;
        end

        wbm_low_level.wbm_read(read_data, ret) ;

        if ( ret`CYC_ERR === 0 && ret`CYC_ACK === 0 && ret`CYC_RTY === 1 && read_flags`WB_TRANSFER_AUTO_RTY === 1 && ret`TB_ERROR_BIT === 0)
        begin
           if ( rty_count === `WB_TB_MAX_RTY )
            begin
                 $display("*E, maximum number of retries received - access will not be repeated anymore! Routine wb_RMW_read, Time %t ", $time) ;
                 retry = 0 ;
            end
            else
            begin
                retry     = 1 ;
                rty_count = rty_count + 1 ;
            end
        end
        else
        begin
            retry = 0 ;
        end

        // if test bench error bit is set, there is no meaning in introducing subsequent wait states
        if ( ret`TB_ERROR_BIT !== 0 )
        begin
            @(posedge CLK_I) ;
            wbm_low_level.end_cycle ;
            disable main ;
        end

        cyc_count = read_flags`SUBSEQ_WAITS ;
        while ( cyc_count > 0 )
        begin
            @(posedge CLK_I) ;
            cyc_count = cyc_count - 1 ;
        end

        if (retry === 1)
            wbm_low_level.end_cycle ;
        else
            wbm_low_level.modify_cycle ;
    end

    in_use = 0 ;

end //main
endtask // wb_RMW_read

task wb_RMW_write ;
    input `WRITE_STIM_TYPE write_data ;
    input `WB_TRANSFER_FLAGS   write_flags ;
    inout `WRITE_RETURN_TYPE ret;
    reg in_use ;
    reg cab ;
    reg ok ;
    integer cyc_count ;
    integer rty_count ;
    reg retry ;
begin:main

    ret`TB_ERROR_BIT = 1'b0 ;
    cab = 0 ;
    ret`CYC_ACTUAL_TRANSFER = 0 ;
    rty_count = 0 ;

    // check if task was called before previous call finished
    if ( in_use === 1 )
    begin
        $display("*E, wb_RMW_write routine re-entered! Time %t ", $time) ;
        ret`TB_ERROR_BIT = 1'b1 ;
        disable main ;
    end

    in_use = 1 ;

    retry = 1 ;

    while (retry === 1)
    begin
        // synchronize operation to clock
        //@(posedge CLK_I) ;
        ok = 1 ;
        if (rty_count !== 0)
            wbm_low_level.start_cycle(cab, 1'b1, ok) ;

        if ( ok !== 1 )
        begin
            $display("*E, Failed to initialize cycle! Routine wb_single_write, Time %t ", $time) ;
            ret`TB_ERROR_BIT = 1'b1 ;
            disable main ;
        end

        // first insert initial wait states
        cyc_count = write_flags`INIT_WAITS ;
        while ( cyc_count > 0 )
        begin
            @(posedge CLK_I) ;
            cyc_count = cyc_count - 1 ;
        end

        wbm_low_level.wbm_write(write_data, ret) ;

        if ( ret`CYC_ERR === 0 && ret`CYC_ACK === 0 && ret`CYC_RTY === 1 && write_flags`WB_TRANSFER_AUTO_RTY === 1 && ret`TB_ERROR_BIT === 0)
        begin
            if ( rty_count === `WB_TB_MAX_RTY )
            begin
                 $display("*E, maximum number of retries received - access will not be repeated anymore! Routine wb_single_write, Time %t ", $time) ;
                 retry = 0 ;
            end
            else
            begin
                retry     = 1 ;
                rty_count = rty_count + 1 ;
            end
        end
        else
            retry = 0 ;

        // if test bench error bit is set, there is no meaning in introducing subsequent wait states
        if ( ret`TB_ERROR_BIT !== 0 )
        begin
            @(posedge CLK_I) ;
            wbm_low_level.end_cycle ;
            disable main ;
        end

        cyc_count = write_flags`SUBSEQ_WAITS ;
        while ( cyc_count > 0 )
        begin
            @(posedge CLK_I) ;
            cyc_count = cyc_count - 1 ;
        end

        wbm_low_level.end_cycle ;
    end

    in_use = 0 ;

end //main
endtask // wb_RMW_write

task wb_block_write ;
    input  `WB_TRANSFER_FLAGS write_flags ;
    inout  `WRITE_RETURN_TYPE ret;

    reg in_use ;
    reg `WRITE_STIM_TYPE  current_write ;
    reg cab ;
    reg ok ;
    integer cyc_count ;
    integer rty_count ;
    reg end_blk ;
begin:main

    ret`CYC_ACTUAL_TRANSFER = 0 ;
    rty_count = 0 ;

    // check if task was called before previous call finished
    if ( in_use === 1 )
    begin
        $display("*E, wb_block_write routine re-entered! Time %t ", $time) ;
        ret`TB_ERROR_BIT = 1'b1 ;
        disable main ;
    end

    if (write_flags`WB_TRANSFER_SIZE > `MAX_BLK_SIZE)
    begin
        $display("*E, number of transfers passed to wb_block_write routine exceeds defined maximum transaction length! Time %t", $time) ;
        ret`TB_ERROR_BIT = 1'b1 ;
        disable main ;
    end

    in_use = 1 ;
    @(posedge CLK_I) ;
    cab = write_flags`WB_TRANSFER_CAB ;
    wbm_low_level.start_cycle(cab, 1'b1, ok) ;
    if ( ok !== 1 )
    begin
        $display("*E, Failed to initialize cycle! Routine wb_block_write, Time %t ", $time) ;
        ret`TB_ERROR_BIT = 1'b1 ;
        disable main ;
    end

    // insert initial wait states
    cyc_count = write_flags`INIT_WAITS ;
    while ( cyc_count > 0 )
    begin
        @(posedge CLK_I) ;
        cyc_count = cyc_count - 1 ;
    end

    end_blk = 0 ;
    while (end_blk === 0)
    begin
        // collect data for current data beat
        current_write = blk_write_data[ret`CYC_ACTUAL_TRANSFER] ;
        wbm_low_level.wbm_write(current_write, ret) ;

        // check result of write operation
        // check for severe test error
        if (ret`TB_ERROR_BIT !== 0)
        begin
           @(posedge CLK_I) ;
           wbm_low_level.end_cycle ;
           disable main ;
        end

        // slave returned error or error signal had invalid value
        if (ret`CYC_ERR !== 0)
            end_blk = 1 ;

        if (
            (ret`CYC_RTY !== 0) && (ret`CYC_RTY !== 1) ||
            (ret`CYC_ACK !== 0) && (ret`CYC_ACK !== 1) ||
            (ret`CYC_ERR !== 0) && (ret`CYC_ERR !== 1)
           )
        begin
            end_blk = 1 ;
            $display("*E, at least one slave response signal was invalid when cycle finished! Routine wb_block_write, Time %t ", $time) ;
            $display("ACK = %b \t RTY_O = %b \t ERR_O = %b \t", ret`CYC_ACK, ret`CYC_RTY, ret`CYC_ERR) ;
        end

        if ((ret`CYC_RTY === 1) && (write_flags`WB_TRANSFER_AUTO_RTY !== 1))
            end_blk = 1 ;

        if ((ret`CYC_RTY === 1) && (write_flags`WB_TRANSFER_AUTO_RTY === 1))
        begin
            if ( rty_count === `WB_TB_MAX_RTY )
            begin
                 $display("*E, maximum number of retries received - access will not be repeated anymore! Routine wb_block_write, Time %t ", $time) ;
                 end_blk = 1 ;
            end
            else
            begin
                rty_count = rty_count + 1 ;
            end
        end
        else
            rty_count = 0 ;

        // check if slave responded at all
        if (ret`CYC_RESPONSE === 0)
            end_blk = 1 ;

        // check if all intended data was transfered
        if (ret`CYC_ACTUAL_TRANSFER === write_flags`WB_TRANSFER_SIZE)
            end_blk = 1 ;

        // insert subsequent wait cycles, if transfer is supposed to continue
        if ( end_blk === 0 )
        begin
            cyc_count = write_flags`SUBSEQ_WAITS ;
            while ( cyc_count > 0 )
            begin
                @(posedge CLK_I) ;
                cyc_count = cyc_count - 1 ;
            end
        end

        if ( (end_blk === 0) && (ret`CYC_RTY === 1) )
        begin
            wbm_low_level.end_cycle ;
            @(posedge CLK_I) ;
            wbm_low_level.start_cycle(cab, 1'b1, ok) ;
            if ( ok !== 1 )
            begin
                $display("*E, Failed to initialize cycle! Routine wb_block_write, Time %t ", $time) ;
                ret`TB_ERROR_BIT = 1'b1 ;
                end_blk = 1 ;
            end
        end
    end //while

    wbm_low_level.end_cycle ;
    in_use = 0 ;
end //main
endtask //wb_block_write

task wb_block_read ;
    input  `WB_TRANSFER_FLAGS      read_flags ;
    inout `READ_RETURN_TYPE       ret;

    reg in_use ;
    reg `READ_STIM_TYPE  current_read ;
    reg cab ;
    reg ok ;
    integer cyc_count ;
    integer rty_count ;
    reg end_blk ;
    integer transfered ;
begin:main

    ret`CYC_ACTUAL_TRANSFER = 0 ;
    transfered = 0 ;
    rty_count = 0 ;

    // check if task was called before previous call finished
    if ( in_use === 1 )
    begin
        $display("*E, wb_block_read routine re-entered! Time %t ", $time) ;
        ret`TB_ERROR_BIT = 1'b1 ;
        disable main ;
    end

    if (read_flags`WB_TRANSFER_SIZE > `MAX_BLK_SIZE)
    begin
        $display("*E, number of transfers passed to wb_block_read routine exceeds defined maximum transaction length! Time %t", $time) ;
        ret`TB_ERROR_BIT = 1'b1 ;
        disable main ;
    end

    in_use = 1 ;
    @(posedge CLK_I) ;
    cab = read_flags`WB_TRANSFER_CAB ;

    wbm_low_level.start_cycle(cab, 1'b0, ok) ;

    if ( ok !== 1 )
    begin
        $display("*E, Failed to initialize cycle! Routine wb_block_read, Time %t ", $time) ;
        ret`TB_ERROR_BIT = 1'b1 ;
        disable main ;
    end

    // insert initial wait states
    cyc_count = read_flags`INIT_WAITS ;
    while ( cyc_count > 0 )
    begin
        @(posedge CLK_I) ;
        cyc_count = cyc_count - 1 ;
    end

    end_blk = 0 ;
    while (end_blk === 0)
    begin
        // collect data for current data beat
        current_read = blk_read_data_in[ret`CYC_ACTUAL_TRANSFER] ;

        wbm_low_level.wbm_read(current_read, ret) ;

        if ( transfered !== ret`CYC_ACTUAL_TRANSFER )
        begin
            blk_read_data_out[transfered] = ret;
            transfered = ret`CYC_ACTUAL_TRANSFER ;
        end

        // check result of read operation
        // check for severe test error
        if (ret`TB_ERROR_BIT !== 0)
        begin
           @(posedge CLK_I) ;
           wbm_low_level.end_cycle ;
           disable main ;
        end

        // slave returned error or error signal had invalid value
        if (ret`CYC_ERR !== 0)
            end_blk = 1 ;

        if (
            (ret`CYC_RTY !== 0) && (ret`CYC_RTY !== 1) ||
            (ret`CYC_ACK !== 0) && (ret`CYC_ACK !== 1) ||
            (ret`CYC_ERR !== 0) && (ret`CYC_ERR !== 1)
           )
        begin
            end_blk = 1 ;
            $display("*E, at least one slave response signal was invalid when cycle finished! Routine wb_block_read, Time %t ", $time) ;
            $display("ACK = %b \t RTY_O = %b \t ERR_O = %b \t", ret`CYC_ACK, ret`CYC_RTY, ret`CYC_ERR) ;
        end

        if ((ret`CYC_RTY === 1) && (read_flags`WB_TRANSFER_AUTO_RTY !== 1))
            end_blk = 1 ;

        if ((ret`CYC_RTY === 1) && (read_flags`WB_TRANSFER_AUTO_RTY === 1))
        begin
            if ( rty_count === `WB_TB_MAX_RTY )
            begin
                 $display("*E, maximum number of retries received - access will not be repeated anymore! Routine wb_block_read, Time %t ", $time) ;
                 end_blk = 1 ;
            end
            else
            begin
                rty_count = rty_count + 1 ;
            end
        end
        else
            rty_count = 0 ;

        // check if slave responded at all
        if (ret`CYC_RESPONSE === 0)
            end_blk = 1 ;

        // check if all intended data was transfered
        if (ret`CYC_ACTUAL_TRANSFER === read_flags`WB_TRANSFER_SIZE)
            end_blk = 1 ;

        // insert subsequent wait cycles, if transfer is supposed to continue
        if ( end_blk === 0 )
        begin
            cyc_count = read_flags`SUBSEQ_WAITS ;
            while ( cyc_count > 0 )
            begin
                @(posedge CLK_I) ;
                cyc_count = cyc_count - 1 ;
            end
        end

        if ( (end_blk === 0) && (ret`CYC_RTY === 1) )
        begin
            wbm_low_level.end_cycle ;
            @(posedge CLK_I) ;
            wbm_low_level.start_cycle(cab, 1'b0, ok) ;
            if ( ok !== 1 )
            begin
                $display("*E, Failed to initialize cycle! Routine wb_block_read, Time %t ", $time) ;
                ret`TB_ERROR_BIT = 1'b1 ;
                end_blk = 1 ;
            end
        end
    end //while

    wbm_low_level.end_cycle ;
    in_use = 0 ;
end //main
endtask //wb_block_read

endmodule

