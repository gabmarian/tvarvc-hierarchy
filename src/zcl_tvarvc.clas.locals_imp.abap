*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS range_tools DEFINITION FINAL
                             CREATE PRIVATE.

  PUBLIC SECTION.

    CLASS-METHODS fix_values
      IMPORTING
        scanned_range      TYPE zcl_tvarvc=>generic_range
      RETURNING
        VALUE(fixed_range) TYPE zcl_tvarvc=>generic_range.

    CLASS-METHODS get_false_range
      RETURNING
        VALUE(false_range) TYPE zcl_tvarvc=>generic_range.

ENDCLASS.

CLASS range_tools IMPLEMENTATION.

  METHOD fix_values.

* Values can be saved in an incomplete form via transaciton STVARV with missing SIGN and/or OPTION
* This requires a fix, otherwise a dump is raised when the range is used in a comparison

    fixed_range = VALUE #( FOR line IN scanned_range (

      sign = COND #(
        WHEN line-sign IS NOT INITIAL
          THEN line-sign
          ELSE zcl_tvarvc=>sign-in )

      option = COND #(
        WHEN line-option IS NOT INITIAL
          THEN line-option
        WHEN line-option IS INITIAL AND line-high IS INITIAL
          THEN zcl_tvarvc=>opti-eq
        WHEN line-option IS INITIAL AND line-high IS NOT INITIAL
          THEN zcl_tvarvc=>opti-bt )

      low = line-low high = line-high

    ) ).

  ENDMETHOD.

  METHOD get_false_range.

* Build a range always returning false in conjunction with operator IN

    false_range = VALUE #(
      ( sign   = zcl_tvarvc=>sign-ex
        option = zcl_tvarvc=>opti-cp
        low    = '*' )
    ).

  ENDMETHOD.

ENDCLASS.
