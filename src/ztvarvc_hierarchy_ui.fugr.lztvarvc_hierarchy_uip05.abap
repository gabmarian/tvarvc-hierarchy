
CLASS variable_tools IMPLEMENTATION.

  METHOD f4.

    DATA: attributes TYPE ztvarvc_node_attributes,
          fieldinfo  TYPE dfies,
          values     TYPE STANDARD TABLE OF ddshretval.

    fieldinfo = get_fieldinfo( node ).

    IF fieldinfo IS INITIAL.
      RAISE EXCEPTION TYPE no_f4_help.
    ENDIF.

    IF fieldinfo-f4availabl = abap_true.

      attributes = node->get_attributes( ).

      CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
        EXPORTING
          tabname    = attributes-tabname
          fieldname  = attributes-fieldname
        TABLES
          return_tab = values
        EXCEPTIONS
          OTHERS     = 1.

      IF values IS NOT INITIAL.
        val = values[ 1 ]-fieldval.
      ELSE.
        RAISE EXCEPTION TYPE no_f4_help.
      ENDIF.

    ELSEIF fieldinfo-domname IS NOT INITIAL.
      " TODO - retrieve values from value table if exists
    ELSE.
      RAISE EXCEPTION TYPE no_f4_help.
    ENDIF.

  ENDMETHOD.

  METHOD get_field_length.

    DATA(fieldinfo) = get_fieldinfo( node ).

    IF fieldinfo-outputlen > 0.
      length = fieldinfo-outputlen.
    ELSE.
      length = 255.
    ENDIF.

  ENDMETHOD.

  METHOD apply_input_conversion.

    DATA: function TYPE funcname VALUE 'CONVERSION_EXIT_$$$$_INPUT'.

    DATA(fieldinfo) = get_fieldinfo( node ).

    IF ext_val IS NOT INITIAL AND fieldinfo-convexit IS NOT INITIAL.

      function = replace( val = function sub = '$$$$' with = fieldinfo-convexit ).

      CALL FUNCTION function
        EXPORTING
          input  = ext_val
        IMPORTING
          output = int_val.

    ELSE.

      int_val = ext_val.

    ENDIF.

  ENDMETHOD.

  METHOD apply_output_conversion.

    DATA: function TYPE funcname VALUE 'CONVERSION_EXIT_$$$$_OUTPUT'.

    DATA(fieldinfo) = get_fieldinfo( node ).

    IF int_val IS NOT INITIAL AND fieldinfo-convexit IS NOT INITIAL.

      function = replace( val = function sub = '$$$$' with = fieldinfo-convexit ).

      CALL FUNCTION function
        EXPORTING
          input  = int_val
        IMPORTING
          output = ext_val.

    ELSE.

      ext_val = int_val.

    ENDIF.

  ENDMETHOD.

  METHOD get_fieldinfo.

    DATA: attributes TYPE ztvarvc_node_attributes.

    attributes = node->get_attributes( ).

    IF attributes-tabname   IS INITIAL OR
       attributes-fieldname IS INITIAL.
      RETURN.
    ENDIF.

    fieldinfo-lfieldname = attributes-fieldname.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname    = attributes-tabname
        lfieldname = fieldinfo-lfieldname
      IMPORTING
        dfies_wa   = fieldinfo
      EXCEPTIONS
        OTHERS     = 1.

    IF sy-subrc <> 0.
      CLEAR fieldinfo.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
