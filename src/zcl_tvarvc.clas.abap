class ZCL_TVARVC definition
  public
  final
  create private .

public section.

  types:
    value_list    TYPE SORTED TABLE OF rvari_val_255 WITH UNIQUE KEY table_line .
  types:
    generic_range TYPE RANGE OF rvari_val_255 .

  constants:
    BEGIN OF kind,
        param  TYPE rsscr_kind VALUE 'P',
        selopt TYPE rsscr_kind VALUE 'S',
      END OF kind .
  constants:
    BEGIN OF sign,
        in TYPE tvarv_sign VALUE 'I',
        ex TYPE tvarv_sign VALUE 'E',
      END OF sign .
  constants:
    BEGIN OF opti,
        eq TYPE tvarv_opti VALUE 'EQ',
        ne TYPE tvarv_opti VALUE 'NE',
        bt TYPE tvarv_opti VALUE 'BT',
        nb TYPE tvarv_opti VALUE 'NB',
        ge TYPE tvarv_opti VALUE 'GE',
        gt TYPE tvarv_opti VALUE 'GT',
        le TYPE tvarv_opti VALUE 'LE',
        lt TYPE tvarv_opti VALUE 'GT',
        cp TYPE tvarv_opti VALUE 'CP',
        np TYPE tvarv_opti VALUE 'NP',
      END OF opti .

  class-methods CLASS_CONSTRUCTOR.

  class-methods GET_PARAMETER
    importing
      !NAME type CSEQUENCE
    returning
      value(VAL) type RVARI_VAL_255 .
  class-methods GET_SELECT_OPTION
    importing
      !NAME type CSEQUENCE
      !ALLOW_EMPTY type ABAP_BOOL default ABAP_TRUE
    returning
      value(VAL) type GENERIC_RANGE .
  class-methods GET_LIST
    importing
      !NAME type CSEQUENCE
    returning
      value(VAL) type VALUE_LIST .
  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-DATA: variables TYPE REF TO ZIF_TVARVC_VARIABLE_COLLECTION.

ENDCLASS.


CLASS ZCL_TVARVC IMPLEMENTATION.

  METHOD class_constructor.
    variables = NEW zcl_tvarvc_variable_collection( ).
  ENDMETHOD.

  METHOD get_list.

    val = VALUE #( FOR line IN get_select_option( name )
                            WHERE ( sign = sign-in AND option = opti-eq )
                                  ( line-low ) ).

  ENDMETHOD.

  METHOD get_parameter.

    val = variables->get_parameter( name ).

  ENDMETHOD.

  METHOD get_select_option.

    val = range_tools=>fix_values( variables->get_select_option( name ) ).

    IF allow_empty = abap_false AND val IS INITIAL.
      val = range_tools=>get_false_range( ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
