*"* use this source file for any type of declarations (class
*"* definitions, interfaces or type declarations) you need for
*"* components in the private section

TYPES BEGIN OF parameter_t.
TYPES name   TYPE tvarvc-name.
TYPES value  TYPE rvari_val_255.
TYPES edited TYPE abap_bool.
TYPES END OF parameter_t.

TYPES parameters_t TYPE HASHED TABLE OF parameter_t
  WITH UNIQUE KEY name.

TYPES BEGIN OF select_option_t.
TYPES name   TYPE tvarvc-name.
TYPES values TYPE zcl_tvarvc=>generic_range.
TYPES edited TYPE abap_bool.
TYPES END OF select_option_t.

TYPES select_options_t TYPE HASHED TABLE OF select_option_t
  WITH UNIQUE KEY name.

TYPES: BEGIN OF tvarvc_grouping,
         entries_to_delete TYPE STANDARD TABLE OF tvarvc WITH DEFAULT KEY,
         entries_to_modify TYPE STANDARD TABLE OF tvarvc WITH DEFAULT KEY,
       END OF tvarvc_grouping.
