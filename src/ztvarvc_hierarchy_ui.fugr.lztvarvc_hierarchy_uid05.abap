
CLASS no_f4_help DEFINITION INHERITING FROM cx_static_check.
ENDCLASS.

CLASS variable_tools DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS f4
      IMPORTING
        node       TYPE REF TO zif_tvarvc_hier_node
      RETURNING
        VALUE(val) TYPE string
      RAISING
        no_f4_help.

    CLASS-METHODS get_field_length
      IMPORTING
        node          TYPE REF TO zif_tvarvc_hier_node
      RETURNING
        VALUE(length) TYPE i.

    CLASS-METHODS apply_input_conversion
      IMPORTING
        ext_val        TYPE any
        node           TYPE REF TO zif_tvarvc_hier_node
      RETURNING
        VALUE(int_val) TYPE rvari_val_255.

    CLASS-METHODS apply_output_conversion
      IMPORTING
        int_val        TYPE any
        node           TYPE REF TO zif_tvarvc_hier_node
      RETURNING
        VALUE(ext_val) TYPE rvari_val_255.

    CLASS-METHODS get_fieldinfo
      IMPORTING
        node          TYPE REF TO zif_tvarvc_hier_node
      RETURNING
        VALUE(fieldinfo) TYPE dfies.

ENDCLASS.
