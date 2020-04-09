CLASS zcl_tvarvc_hier_node DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_tvarvc_hier_node .

    TYPES:
      BEGIN OF key_t.
    TYPES name TYPE ztvarvc_hier-node_name.
    TYPES id   TYPE ztvarvc_hier-node_id.
    TYPES END OF key_t .
    TYPES:
      keys_t TYPE SORTED TABLE OF key_t WITH UNIQUE KEY name .

    CONSTANTS root_id TYPE ztvarvc_hier-node_id VALUE 'ROOT' ##NO_TEXT.

    METHODS constructor
      IMPORTING
        !id            TYPE ztvarvc_hier-node_id
        !name          TYPE ztvarvc_hier-node_name
        !parent_id     TYPE ztvarvc_hier-parent_id
        !attributes    TYPE ztvarvc_node_attributes
        !documentation TYPE ztvarvc_hier-documentation
        !history       TYPE ztvarvc_node_history
        !children      TYPE keys_t
        !manager       TYPE REF TO zif_tvarvc_hier_manager .
  PROTECTED SECTION.

    TYPES:
      BEGIN OF child_t.
    TYPES name TYPE ztvarvc_hier-node_name.
    TYPES id   TYPE ztvarvc_hier-node_id.
    TYPES ref  TYPE REF TO zcl_tvarvc_hier_node.
    TYPES END OF child_t .
    TYPES:
      children_t TYPE SORTED TABLE OF child_t WITH UNIQUE KEY name .

    CONSTANTS naming_pattern TYPE string VALUE '(^[A-Za-z0-9_]+$)' ##NO_TEXT.
    DATA parent TYPE REF TO zcl_tvarvc_hier_node .
    DATA children TYPE children_t .
    DATA id TYPE ztvarvc_hier-node_id .
    DATA name TYPE ztvarvc_hier-node_name .
    DATA parent_id TYPE ztvarvc_hier-parent_id .
    DATA attributes TYPE ztvarvc_node_attributes .
    DATA history TYPE ztvarvc_node_history .
    DATA docu_xstring TYPE ztvarvc_hier-documentation .
    DATA manager TYPE REF TO zif_tvarvc_hier_manager .

    METHODS fire_update
      IMPORTING
        !created TYPE abap_bool OPTIONAL
        !changed TYPE abap_bool OPTIONAL
        !deleted TYPE abap_bool OPTIONAL .

ENDCLASS.


CLASS zcl_tvarvc_hier_node IMPLEMENTATION.

  METHOD constructor.

    me->id           = id.
    me->name         = name.
    me->parent_id    = parent_id.
    me->attributes   = attributes.
    me->manager      = manager.
    me->docu_xstring = documentation.
    me->history      = history.
    me->children     = CORRESPONDING #( children ).

    SET HANDLER manager->on_create FOR me.
    SET HANDLER manager->on_change FOR me.
    SET HANDLER manager->on_delete FOR me.

  ENDMETHOD.

  METHOD fire_update.

    IF created = abap_true.
      RAISE EVENT zif_tvarvc_hier_node~created.
    ELSEIF changed = abap_true.
      RAISE EVENT zif_tvarvc_hier_node~changed.
    ELSEIF deleted = abap_true.
      RAISE EVENT zif_tvarvc_hier_node~deleted.
    ENDIF.

    IF zif_tvarvc_hier_node~get_status( ) = zif_tvarvc_hier_node=>statuses-created.
      history-created_by = sy-uname.
      history-created_on = sy-datum.
    ELSE.
      history-changed_by = sy-uname.
      history-changed_on = sy-datum.
    ENDIF.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~add_child.

    DATA: child TYPE REF TO zcl_tvarvc_hier_node.

    IF line_exists( children[ name = node->get_name( ) ] ).
      RAISE EXCEPTION TYPE zcx_tvarvc_operation_failure.
    ENDIF.

    child ?= node.

    children = VALUE #( BASE children ( id = child->id name = child->name ref = child ) ).

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~count_subnodes.

    DATA: iterator TYPE REF TO zif_tvarvc_hier_node_iterator.

    iterator = zif_tvarvc_hier_node~create_iterator( depth ).

    WHILE iterator->get_next( ) IS BOUND.
      count = count + 1.
    ENDWHILE.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~create_child.

    DATA: node   TYPE REF TO zcl_tvarvc_hier_node,
          new_id TYPE ztvarvc_hier-node_id.

    IF zif_tvarvc_hier_node~get_status( ) = zif_tvarvc_hier_node=>statuses-deleted.
      RAISE EXCEPTION TYPE zcx_tvarvc_not_exists.
    ENDIF.

    IF NOT cl_abap_matcher=>matches( pattern = naming_pattern text = name ).
      RAISE EXCEPTION TYPE zcx_tvarvc_invalid_name.
    ENDIF.

    IF line_exists( children[ name = name ] ).
      RAISE EXCEPTION TYPE zcx_tvarvc_already_exists.
    ENDIF.

    TRY.
        new_id = cl_system_uuid=>create_uuid_c26_static( ).
      CATCH cx_uuid_error.
        RAISE EXCEPTION TYPE zcx_tvarvc_operation_failure.
    ENDTRY.

    node = NEW #( id            = new_id
                  name          = name
                  parent_id     = me->id
                  attributes    = VALUE #( )
                  documentation = VALUE #( )
                  history       = VALUE #( )
                  children      = VALUE #( )
                  manager       = me->manager ).

    node->parent = me.
    node->attributes = attributes.

    children = VALUE #( BASE children ( id = node->id name = node->name ref = node ) ).

    node->fire_update( created = abap_true ).

    child = node.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~create_iterator.

    iterator = NEW iterator( owner = me
                             depth = depth ).

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~get_attributes.

    attributes = me->attributes.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~get_child.

    DATA child_rec TYPE REF TO child_t.

    TRY.

        IF index IS NOT INITIAL.
          child_rec = REF #( children[ index ] ).
        ELSE.
          child_rec = REF #( children[ name = name ] ).
        ENDIF.

        IF child_rec->ref IS NOT BOUND.
          child_rec->ref ?= manager->get( child_rec->id ).
        ENDIF.

        child = child_rec->ref.

      CATCH cx_sy_itab_line_not_found.

        " Soft handling, simply return null reference
        RETURN.

    ENDTRY.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~get_documentation.

    IF docu_xstring IS NOT INITIAL.

      TRY.

          IMPORT text = text
            FROM DATA BUFFER docu_xstring.

        CATCH cx_sy_import_format_error.

          " Fallback, if for any reason documentation gets corrupted
          CLEAR docu_xstring.

      ENDTRY.

    ENDIF.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~get_documentation_raw.
    docu_xstring = me->docu_xstring.
  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~get_id.
    id = me->id.
  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~get_modification_info.
    history = me->history.
  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~get_name.
    name = me->name.
  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~get_parent.

    IF me->parent IS NOT BOUND.
      me->parent ?= manager->get( parent_id ).
    ENDIF.

    parent = me->parent.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~get_status.

    status = manager->get_status( me ).

  ENDMETHOD.

  METHOD zif_tvarvc_hier_node~is_leaf.
    leaf = xsdbool( children IS INITIAL ).
  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~remove_child.

    DATA: node TYPE REF TO zcl_tvarvc_hier_node.

    node ?= zif_tvarvc_hier_node~get_child( name = name ).

    IF node IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_tvarvc_not_exists.
    ENDIF.

    DATA(iterator) = node->zif_tvarvc_hier_node~create_iterator( ).

    DELETE children WHERE name = node->name.

    node->fire_update( deleted = abap_true ).

    DO.

      node ?= iterator->get_next( ).

      IF node IS NOT BOUND.
        EXIT.
      ENDIF.

      node->fire_update( deleted = abap_true ).

    ENDDO.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~rename.

    DATA: child_rec TYPE child_t.

    IF name = new_name.
      RETURN.
    ENDIF.

    IF zif_tvarvc_hier_node~get_status( ) = zif_tvarvc_hier_node=>statuses-deleted.
      RAISE EXCEPTION TYPE zcx_tvarvc_operation_failure.
    ENDIF.

    IF NOT cl_abap_matcher=>matches( pattern = naming_pattern text = new_name ).
      RAISE EXCEPTION TYPE zcx_tvarvc_invalid_name.
    ENDIF.

    " Sibling exists with that name?
    IF line_exists( parent->children[ name = new_name ] ).
      RAISE EXCEPTION TYPE zcx_tvarvc_already_exists.
    ENDIF.

    " Rename in parent
    child_rec = parent->children[ name = name ].
    DELETE parent->children WHERE name = name.
    child_rec-name = new_name.
    INSERT child_rec INTO TABLE parent->children.

    " Rename in node and raise changed
    name = new_name.
    fire_update( changed = abap_true ).

    self = me.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~set_attributes.

    IF attributes <> me->attributes.
      me->attributes = attributes.
      fire_update( changed = abap_true ).
    ENDIF.

    self = me.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_node~set_documentation.

    DATA: docu_xstring TYPE xstring.

    IF text IS NOT INITIAL.

      EXPORT text = text
        TO DATA BUFFER docu_xstring
        COMPRESSION ON.

    ENDIF.

    IF me->docu_xstring <> docu_xstring.
      me->docu_xstring = docu_xstring.
      fire_update( changed = abap_true ).
    ENDIF.

    self = me.

  ENDMETHOD.
ENDCLASS.
