CLASS zcl_tvarvc_variable_collection DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_tvarvc_variable_collection .
  PROTECTED SECTION.

  PRIVATE SECTION.

    TYPES BEGIN OF parameter_t.
    TYPES name   TYPE tvarvc-name.
    TYPES value  TYPE rvari_val_255.
    TYPES edited TYPE abap_bool.
    TYPES END OF parameter_t.

    TYPES parameters_t TYPE HASHED TABLE OF parameter_t
      WITH UNIQUE KEY name.

    TYPES BEGIN OF select_option_t.
    TYPES name   TYPE tvarvc-name.
    TYPES type   TYPE tvarvc-type.
    TYPES values TYPE zcl_tvarvc=>generic_range.
    TYPES edited TYPE abap_bool.
    TYPES END OF select_option_t.

    TYPES select_options_t TYPE HASHED TABLE OF select_option_t
      WITH UNIQUE KEY name.

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

    " Todo - refactor, raise changed event with deleted and new entries
    DATA: tvarvc TYPE tvarvc,
          value  TYPE LINE OF zcl_tvarvc=>generic_range.

    LOOP AT parameters REFERENCE INTO DATA(parameter).

      CHECK parameter->edited = abap_true.

      DELETE FROM tvarvc WHERE name = parameter->name
                           AND type = zcl_tvarvc=>kind-param.

      CLEAR tvarvc.

      tvarvc-name = parameter->name.
      tvarvc-sign = zcl_tvarvc=>sign-in.
      tvarvc-opti = zcl_tvarvc=>opti-eq.

      MODIFY tvarvc FROM tvarvc.

      parameter->edited = abap_false.

    ENDLOOP.

    LOOP AT select_options REFERENCE INTO DATA(select_option) WHERE edited = abap_true.

      CHECK select_option->edited = abap_true.

      DELETE FROM tvarvc WHERE name = select_option->name
                           AND type = zcl_tvarvc=>kind-selopt.

      CLEAR tvarvc.
      tvarvc-name = select_option->name.
      tvarvc-type = zcl_tvarvc=>kind-selopt.

      LOOP AT select_option->values INTO value.

        tvarvc-sign = value-sign.
        tvarvc-opti = value-option.
        tvarvc-low  = value-low.
        tvarvc-high = value-high.

        MODIFY tvarvc FROM tvarvc.

        tvarvc-numb = tvarvc-numb + 1.

      ENDLOOP.

      select_option->edited = abap_false.

    ENDLOOP.

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
