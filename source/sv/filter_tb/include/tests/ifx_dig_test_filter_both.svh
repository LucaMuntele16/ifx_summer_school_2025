class ifx_dig_test_filter_both extends ifx_dig_testbase;

    `uvm_component_utils(ifx_dig_test_filter_both)

    int filter_list[$]; // filters to be tested

    function new(string name = "ifx_dig_test_filter_both", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `TEST_INFO("Run phase started")
    endtask

    task main_phase(uvm_phase phase);
        phase.raise_objection(this);

        drive_reset(0,1,5);
        `TEST_INFO("Main phase started")

        for (int ifilt = 1; ifilt <= `FILT_NB; ifilt++) begin
            filter_list.push_back(ifilt);
        end
        filter_list.shuffle();

        foreach (filter_list[ifilt]) begin
            `TEST_INFO($sformatf("Testing filter: %0d with BOTH edge type", filter_list[ifilt]))

            configure_filter(
                .filt_idx(filter_list[ifilt]),
                .filter_type(FILT_BOTH),
                .int_en(1)
            );

            // ===================== RISING EDGE =====================
            `TEST_INFO($sformatf("Drive INVALID RISING pulse on filter: %0d", filter_list[ifilt]))
            pin_filter_generic_seq.drive_type = FILT_DRV_INVALID;
            pin_filter_generic_seq.filt_edge  = FILT_RISE_EDGE;
            pin_filter_generic_seq.start(dig_env.v_seqr.p_pin_filter_uvc_seqr[filter_list[ifilt] - 1]);
            `WAIT_NS($urandom_range(50,100))
            read_filter_status(0);
            clear_filter_status(filter_list[ifilt]);
            `WAIT_NS(100)

            `TEST_INFO($sformatf("Drive VALID RISING pulse on filter: %0d", filter_list[ifilt]))
        
            pin_filter_valid_pulse_seq.filt_edge = FILT_RISE_EDGE;
            pin_filter_valid_pulse_seq.start(dig_env.v_seqr.p_pin_filter_uvc_seqr[filter_list[ifilt] - 1]);
            `WAIT_NS($urandom_range(50,100))
            read_filter_status(0);
            clear_filter_status(filter_list[ifilt]);
            `WAIT_NS(100)

            // ===================== FALLING EDGE =====================
            `TEST_INFO($sformatf("Drive INVALID FALLING pulse on filter: %0d", filter_list[ifilt]))
            pin_filter_generic_seq.drive_type = FILT_DRV_INVALID;
            pin_filter_generic_seq.filt_edge  = FILT_FALL_EDGE;
            pin_filter_generic_seq.start(dig_env.v_seqr.p_pin_filter_uvc_seqr[filter_list[ifilt] - 1]);
            `WAIT_NS($urandom_range(50,100))
            read_filter_status(0);
            clear_filter_status(filter_list[ifilt]);
            `WAIT_NS(100)

            `TEST_INFO($sformatf("Drive VALID FALLING pulse on filter: %0d", filter_list[ifilt]))
            pin_filter_valid_pulse_seq.filt_edge = FILT_FALL_EDGE;
            pin_filter_valid_pulse_seq.start(dig_env.v_seqr.p_pin_filter_uvc_seqr[filter_list[ifilt] - 1]);
            `WAIT_NS($urandom_range(50,100))
            read_filter_status(0);
            clear_filter_status(filter_list[ifilt]);
            `WAIT_NS(100)

        end

        `TEST_INFO("\n\n\nPrinting Coverage results\n\n\n")
        `TEST_INFO($sformatf("\ncg_filter_ctrl coverage is = %f\n", dig_env.scoreboard.cg_filter_ctrl.get_coverage()))
        `TEST_INFO($sformatf("\ncg_int_status_read coverage is = %f\n", dig_env.scoreboard.cg_int_status_read.get_coverage()))

        phase.drop_objection(this);
    endtask

endclass