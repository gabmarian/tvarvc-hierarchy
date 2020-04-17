
CLASS selection_screen IMPLEMENTATION.

  METHOD constructor.

    me->number = number.
    me->app    = app.

  ENDMETHOD.

  METHOD init_before_call.
    " To be implemented in subclasses where relevant
    " Prepare screen variables before calling the screen
  ENDMETHOD.

  METHOD call.

    " No redefinition allowed, do the initializaton in INIT_BEFORE_CALL

    init_before_call( ).

    IF position-col_to IS NOT INITIAL.

      CALL SELECTION-SCREEN number STARTING AT position-col_from
                                               position-row_from
                                     ENDING AT position-col_to
                                               position-row_to.

    ELSEIF position-col_from IS NOT INITIAL.

      CALL SELECTION-SCREEN number STARTING AT position-col_from
                                               position-row_from.

    ELSE.

      CALL SELECTION-SCREEN number.

    ENDIF.

  ENDMETHOD.

  METHOD pbo.
    " Redefinition is allowed but SUPER->PBO( ) call should also take place

    CALL FUNCTION 'RS_SET_SELSCREEN_STATUS'
      EXPORTING
        p_status  = status_name
        p_program = status_prog
      TABLES
        p_exclude = excluded_functions.

    IF app->in_edit_mode( ) = abap_false.
      LOOP AT SCREEN.
        screen-input = 0.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

  METHOD pai.
    " To be implemented in subclasses where relevant
  ENDMETHOD.

  METHOD on_exit.
    " To be implemented in subclasses where relevant
  ENDMETHOD.

  METHOD on_f4.
    " To be implemented in subclasses where relevant
  ENDMETHOD.

ENDCLASS.

CLASS screen_collection IMPLEMENTATION.

  METHOD constructor.
    me->app = app.
  ENDMETHOD.

  METHOD get_screen.

    TRY.

        ref = screens[ number = number ]-ref.

      CATCH cx_sy_itab_line_not_found.

        DATA(class_name) = |SCREEN_{ number ALPHA = IN }|.

        CREATE OBJECT ref TYPE (class_name)
          EXPORTING
            app = app.

        screens = VALUE #( BASE screens ( number = number ref = ref ) ).

    ENDTRY.

  ENDMETHOD.

ENDCLASS.
