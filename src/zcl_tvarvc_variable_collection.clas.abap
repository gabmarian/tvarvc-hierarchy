class ZCL_TVARVC_VARIABLE_COLLECTION definition
  public
  final
  create public .

public section.

  interfaces ZIF_TVARVC_VARIABLE_COLLECTION .
  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: parameters     TYPE parameters_t,
          select_options TYPE select_options_t.

ENDCLASS.



CLASS ZCL_TVARVC_VARIABLE_COLLECTION IMPLEMENTATION.


  METHOD zif_tvarvc_variable_collection~get_parameter.

    TRY.

        value = parameters[ name = name ]-value.

      CATCH cx_sy_itab_line_not_found.

        SELECT SINGLE low
          FROM tvarvc
          INTO value
          WHERE name = name
            AND type = zcl_tvarvc=>kind-param
            AND numb = space.

        parameters = VALUE #( BASE parameters ( name = name value = value ) ).

    ENDTRY.

  ENDMETHOD.


  METHOD zif_tvarvc_variable_collection~get_select_option.

    TRY.

        values = select_options[ name = name ]-values.

      CATCH cx_sy_itab_line_not_found.

        SELECT sign opti low high
          FROM tvarvc
          INTO TABLE values
          WHERE name = name
            AND type = zcl_tvarvc=>kind-selopt.

        select_options = VALUE #( BASE select_options ( name = name values = values ) ).

    ENDTRY.

  ENDMETHOD.


  METHOD zif_tvarvc_variable_collection~has_pending_changes.

    LOOP AT parameters INTO DATA(parameter).
      IF parameter-edited = abap_true.
        val = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    LOOP AT select_options INTO DATA(select_option).
      IF select_option-edited = abap_true.
        val = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_tvarvc_variable_collection~save.

    DATA: tvarvc_grouping   TYPE tvarvc_grouping,
          entries_to_delete TYPE STANDARD TABLE OF tvarvc,
          entries_to_modify TYPE STANDARD TABLE OF tvarvc,
          entry             TYPE tvarvc,
          tvarvc_keys       TYPE zif_tvarvc_variable_collection=>tvarvc_keys,
          tvarvc_key        LIKE LINE OF tvarvc_keys.

    " Get lines for db modifications
    tvarvc_grouping = db_utility=>project_parameters( parameters ).
    INSERT LINES OF tvarvc_grouping-entries_to_modify INTO TABLE entries_to_modify.
    INSERT LINES OF tvarvc_grouping-entries_to_delete INTO TABLE entries_to_delete.

    tvarvc_grouping = db_utility=>project_select_options( select_options ).
    INSERT LINES OF tvarvc_grouping-entries_to_modify INTO TABLE entries_to_modify.
    INSERT LINES OF tvarvc_grouping-entries_to_delete INTO TABLE entries_to_delete.

    IF entries_to_modify IS INITIAL AND entries_to_delete IS INITIAL.
      RETURN.
    ENDIF.

    " Execute db operation
    DELETE tvarvc FROM TABLE entries_to_delete.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_tvarvc_operation_failure.
    ENDIF.

    MODIFY tvarvc FROM TABLE entries_to_modify.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_tvarvc_operation_failure.
    ENDIF.

    " Reset change flag
    LOOP AT parameters REFERENCE INTO DATA(parameter).
      parameter->edited = abap_false.
    ENDLOOP.

    LOOP AT select_options REFERENCE INTO DATA(select_option).
      select_option->edited = abap_false.
    ENDLOOP.

    " Get keys of affected lines and raise changed event
    LOOP AT entries_to_delete INTO entry.
      tvarvc_key = CORRESPONDING #( entry ).
      INSERT tvarvc_key INTO TABLE tvarvc_keys.
    ENDLOOP.

    LOOP AT entries_to_modify INTO entry.
      tvarvc_key = CORRESPONDING #( entry ).
      INSERT tvarvc_key INTO TABLE tvarvc_keys.
    ENDLOOP.

    RAISE EVENT zif_tvarvc_variable_collection~saved
      EXPORTING
        keys = tvarvc_keys.

  ENDMETHOD.


  METHOD zif_tvarvc_variable_collection~set_parameter.

    IF value <> zif_tvarvc_variable_collection~get_parameter( name = name ).

      parameters[ name = name ]-value  = value.
      parameters[ name = name ]-edited = abap_true.

    ENDIF.

  ENDMETHOD.


  METHOD zif_tvarvc_variable_collection~set_select_option.

    IF values <> zif_tvarvc_variable_collection~get_select_option( name = name ).

      select_options[ name = name ]-values = values.
      select_options[ name = name ]-edited = abap_true.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
