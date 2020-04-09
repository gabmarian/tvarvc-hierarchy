INTERFACE zif_tvarvc_hier_node
  PUBLIC .

  TYPES:
    status(1) TYPE c.

  CONSTANTS BEGIN OF statuses.
  CONSTANTS saved    TYPE status VALUE ' '.
  CONSTANTS created  TYPE status VALUE 'C'.
  CONSTANTS modified TYPE status VALUE 'M'.
  CONSTANTS deleted  TYPE status VALUE 'D'.
  CONSTANTS END OF statuses.

  EVENTS created .
  EVENTS changed .
  EVENTS deleted .

  METHODS add_child
    IMPORTING
      !node TYPE REF TO zif_tvarvc_hier_node
    RAISING
      zcx_tvarvc_error .
  METHODS count_subnodes
    IMPORTING
      !depth       TYPE zif_tvarvc_hier_node_iterator=>depth DEFAULT zif_tvarvc_hier_node_iterator=>depth_all_subnodes
    RETURNING
      VALUE(count) TYPE i .
  METHODS create_child
    IMPORTING
      !name        TYPE ztvarvc_hier-node_name
      !attributes  TYPE ztvarvc_node_attributes OPTIONAL
    RETURNING
      VALUE(child) TYPE REF TO zif_tvarvc_hier_node
    RAISING
      zcx_tvarvc_error .
  METHODS create_iterator
    IMPORTING
      !depth          TYPE zif_tvarvc_hier_node_iterator=>depth DEFAULT zif_tvarvc_hier_node_iterator=>depth_all_subnodes
    RETURNING
      VALUE(iterator) TYPE REF TO zif_tvarvc_hier_node_iterator .
  METHODS get_attributes
    RETURNING
      VALUE(attributes) TYPE ztvarvc_node_attributes .
  METHODS get_modification_info
    RETURNING
      VALUE(history) TYPE ztvarvc_node_history.
  METHODS get_child
    IMPORTING
      !name        TYPE csequence OPTIONAL
      !index       TYPE i OPTIONAL
        PREFERRED PARAMETER index
    RETURNING
      VALUE(child) TYPE REF TO zif_tvarvc_hier_node .
  METHODS get_documentation
    RETURNING
      VALUE(text) TYPE string .
  METHODS get_documentation_raw
    RETURNING
      VALUE(docu_xstring) TYPE xstring .
  METHODS get_id
    RETURNING
      VALUE(id) TYPE string .
  METHODS get_name
    RETURNING
      VALUE(name) TYPE string .
  METHODS get_parent
    RETURNING
      VALUE(parent) TYPE REF TO zif_tvarvc_hier_node .
  METHODS get_status
    RETURNING
      VALUE(status) TYPE status.
  METHODS is_leaf
    RETURNING
      VALUE(leaf) TYPE abap_bool .
  METHODS remove_child
    IMPORTING
      !name  TYPE csequence OPTIONAL
      !index TYPE i OPTIONAL
        PREFERRED PARAMETER index
    RAISING
      zcx_tvarvc_error .
  METHODS rename
    IMPORTING
      !new_name   TYPE csequence
    RETURNING
      VALUE(self) TYPE REF TO zif_tvarvc_hier_node
    RAISING
      zcx_tvarvc_error .
  METHODS set_attributes
    IMPORTING
      !attributes TYPE ztvarvc_node_attributes
    RETURNING
      VALUE(self) TYPE REF TO zif_tvarvc_hier_node .
  METHODS set_documentation
    IMPORTING
      !text       TYPE string
    RETURNING
      VALUE(self) TYPE REF TO zif_tvarvc_hier_node .
ENDINTERFACE.
