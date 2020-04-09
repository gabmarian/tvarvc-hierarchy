CLASS screen_1100 IMPLEMENTATION.

  METHOD constructor.

    super->constructor( number = '1100' app = app ).

    status_name = 'HIER_MAINTENANCE'.

  ENDMETHOD.

  METHOD pbo.

    IF app->in_edit_mode( ).
      SET TITLEBAR 'HIER_MAINTENANCE'.
      excluded_functions = VALUE #( ).
    ELSE.
      SET TITLEBAR 'HIER_DISPLAY'.
      excluded_functions = VALUE #( ( '$SAVE' ) ( 'ADD' ) ( 'REMOVE' ) ( 'DOCUMENTATION' ) ).
    ENDIF.

    super->pbo( ).

  ENDMETHOD.

  METHOD pai.

    CASE ok_code.

      WHEN '$SAVE'.

        app->save( ).

      WHEN '$BACK' OR '$EXIT' OR '$CANCEL'.

        LEAVE PROGRAM.

      WHEN '$FIND'.

        app->find( ).

      WHEN 'TOGGLE'.

        app->switch_mode( ).

      WHEN 'COL_SWITCH'.

        app->toggle_text_columns( ).

      WHEN 'EXPAND'.

        app->expand_tree( ).

      WHEN 'ADD'.

        app->add_node( ).

      WHEN 'REMOVE'.

        app->remove_node( ).

      WHEN 'ATTRIBUTES'.

        app->maintain_attributes( ).

      WHEN 'VARIABLE'.

        app->maintain_tvarvc_variable( ).

      WHEN 'DOCUMENTATION'.

        app->edit_documentation( ).

    ENDCASE.

  ENDMETHOD.

ENDCLASS.


CLASS screen_1200 IMPLEMENTATION.

  METHOD constructor.

    super->constructor( number = '1200' app = app ).

    position-col_from = 10.
    position-row_from = 5.

    status_name = '%_CSP'.
    status_prog = 'RSSYSTDB'.
    excluded_functions = VALUE #( ( 'NONE' ) ( 'SPOS' ) ).

  ENDMETHOD.

  METHOD init_before_call.

    DATA: attributes TYPE ztvarvc_node_attributes.

    attributes = node->get_attributes( ).

    name    = node->get_name( ).
    descr   = attributes-description.
    appcomp = attributes-appl_component.
    xsel    = COND #( WHEN attributes-tvarv_type = 'S' THEN abap_true ELSE abap_false ).
    xpar    = xsdbool( xsel = abap_false ).
    varname = attributes-tvarv_name.

    cron = node->get_modification_info( )-created_on.
    crby = node->get_modification_info( )-created_by.
    chon = node->get_modification_info( )-changed_on.
    chby = node->get_modification_info( )-changed_by.

  ENDMETHOD.

  METHOD pbo.

    super->pbo( ).

    " Hide empty variable section in display mode
    IF app->in_edit_mode( ) = abap_false AND node->get_attributes( )-tvarv_name IS INITIAL.

      LOOP AT SCREEN.
        IF screen-group1 = 'VAR'.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.

    ENDIF.

    " Modification information is only for display
    LOOP AT SCREEN.
      IF screen-group1 = 'HIS'.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD pai.

    DATA: new_attributes TYPE ztvarvc_node_attributes.

    IF ok_code <> 'CRET'.
      RETURN.
    ENDIF.

    TRY.

        node->rename( name ).

      CATCH zcx_tvarvc_invalid_name.

        MESSAGE 'Use only letters, numbers and underscore for names' TYPE 'E'.

    ENDTRY.

    new_attributes = VALUE #(
      description    = descr
      appl_component = appcomp
      tvarv_name     = varname
      tvarv_type     = COND #( WHEN varname IS INITIAL THEN ' '
                               WHEN xpar = abap_true   THEN 'P'
                               WHEN xsel = abap_true   THEN 'S' ) ).

    node->set_attributes( new_attributes ).

  ENDMETHOD.

ENDCLASS.

CLASS screen_1300 IMPLEMENTATION.

  METHOD constructor.

    super->constructor( number = '1300' app = app ).

    position-col_from = 10.
    position-row_from = 5.
    status_name = '%_CSP'.
    status_prog = 'RSSYSTDB'.
    excluded_functions = VALUE #( ( 'NONE' ) ( 'SPOS' ) ).

  ENDMETHOD.

  METHOD init_before_call.

    CLEAR name.
    CLEAR descr.
    CLEAR appcomp.
    xsel = abap_true.
    xpar = abap_false.
    CLEAR varname.

  ENDMETHOD.


  METHOD pai.

    DATA: attributes TYPE ztvarvc_node_attributes.

    IF ok_code <> 'CRET'.
      RETURN.
    ENDIF.

    attributes = VALUE #(
      description    = descr
      appl_component = appcomp
      tvarv_name     = varname
      tvarv_type     = COND #( WHEN varname IS INITIAL THEN ' '
                               WHEN xpar = abap_true   THEN 'P'
                               WHEN xsel = abap_true   THEN 'S' ) ).

    TRY.

        node->create_child( name       = name
                            attributes = attributes ).

      CATCH zcx_tvarvc_invalid_name.

        MESSAGE 'Use only letters, numbers and underscore for names' TYPE 'E'.

      CATCH zcx_tvarvc_already_exists.

        MESSAGE 'Entry with that name already exists' TYPE 'E'.

    ENDTRY.

  ENDMETHOD.

ENDCLASS.


CLASS screen_1400 IMPLEMENTATION.

  METHOD constructor.

    super->constructor( number = '1400' app = app ).

    position-col_from = 10.
    position-row_from = 5.
    status_name = '%_CSP'.
    status_prog = 'RSSYSTDB'.
    excluded_functions = VALUE #( ( 'NONE' ) ( 'SPOS' ) ).

  ENDMETHOD.

  METHOD init_before_call.

    parname = node->get_attributes( )-tvarv_name.
    parval  = variable_handler->get_parameter( parname ).

  ENDMETHOD.

  METHOD pbo.

    super->pbo( ).

    LOOP AT SCREEN.

      IF screen-name = 'PARNAME'.
        screen-input = 0.
      ENDIF.

      MODIFY SCREEN.

    ENDLOOP.

  ENDMETHOD.

  METHOD pai.

    IF sscrfields-ucomm = 'CRET'.
      variable_handler->set_parameter( name = parname value = parval ).
      app->refresh_hier_node_on_ui( node ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS screen_1500 IMPLEMENTATION.

  METHOD constructor.

    super->constructor( number = '1500' app = app ).

    position-col_from = 10.
    position-row_from = 5.
    status_name = '%_CSP'.
    status_prog = 'RSSYSTDB'.

    excluded_functions = VALUE #( ( 'NONE' ) ( 'SPOS' ) ).

  ENDMETHOD.

  METHOD init_before_call.

    selname = node->get_attributes( )-tvarv_name.
    selval[]  = variable_handler->get_select_option( selname ).

  ENDMETHOD.

  METHOD pbo.

    super->pbo( ).

    LOOP AT SCREEN.

      IF screen-name = 'SELNAME'.
        screen-input = 0.
      ENDIF.

      IF screen-name = '%_SELVAL_%_APP_%-VALU_PUSH'.
        screen-input = 1.
      ENDIF.

      MODIFY SCREEN.

    ENDLOOP.

  ENDMETHOD.

  METHOD pai.

    IF sscrfields-ucomm <> 'CRET'.
      RETURN.
    ENDIF.

    variable_handler->set_select_option( name = selname values = selval[] ).
    app->refresh_hier_node_on_ui( node ).

  ENDMETHOD.

ENDCLASS.

CLASS screen_1600 IMPLEMENTATION.

  METHOD constructor.

    super->constructor( number = '1600' app = app ).

    position-col_from = 10.
    position-row_from = 5.
    position-row_to   = 20.
    position-col_to   = 120.
    status_name = '%_CSP'.
    status_prog = 'RSSYSTDB'.
    excluded_functions = VALUE #( ( 'NONE' ) ( 'SPOS' ) ).

  ENDMETHOD.

  METHOD pbo.

    DATA: attributes TYPE ztvarvc_node_attributes.

    text_editor = NEW #( parent = cl_gui_container=>default_screen ).

    text = node->get_documentation( ).

    text_editor->set_textstream( text ).

    super->pbo( ).

  ENDMETHOD.

  METHOD pai.

    DATA: attributes  TYPE ztvarvc_node_attributes.

    text_editor->get_textstream(
      IMPORTING
        text = text ).

    cl_gui_cfw=>flush( ).

    node->set_documentation( text ).

    text_editor->free( ).

  ENDMETHOD.

  METHOD on_exit.
    text_editor->free( ).
  ENDMETHOD.

ENDCLASS.

CLASS screen_1700 IMPLEMENTATION.

  METHOD constructor.

    super->constructor( number = '1700' app = app ).

    position-col_from = 10.
    position-row_from = 5.
    status_name = '%_CSP'.
    status_prog = 'RSSYSTDB'.
    excluded_functions = VALUE #( ( 'NONE' ) ( 'SPOS' ) ).

  ENDMETHOD.

  METHOD init_before_call.

  ENDMETHOD.

  METHOD pbo.

    super->pbo( ).

    LOOP AT SCREEN.
      screen-input = 1.
      MODIFY SCREEN.
    ENDLOOP.

  ENDMETHOD.

  METHOD pai.

    IF sscrfields-ucomm <> 'CRET'.
      RETURN.
    ENDIF.

    app->find_node_by_variable( tvarvc_name = varname
                                tvarvc_type = COND #( WHEN xpar = abap_true   THEN 'P'
                                                      WHEN xsel = abap_true   THEN 'S' ) ).

  ENDMETHOD.

ENDCLASS.
