class ZCL_TVARVC_HIER_MANAGER definition
  public
  final
  create private .

public section.

  interfaces ZIF_TVARVC_HIER_MANAGER .

  class-methods GET_INSTANCE
    returning
      value(MANAGER) type ref to ZCL_TVARVC_HIER_MANAGER .
  methods CONSTRUCTOR .
  PROTECTED SECTION.

    TYPES BEGIN OF managed_node_t.
    TYPES id                TYPE string.
    TYPES variable_name(30) TYPE c.
    TYPES variable_type(30) TYPE c.
    TYPES ref               TYPE REF TO zif_tvarvc_hier_node.
    TYPES status            TYPE zif_tvarvc_hier_node=>status.
    TYPES END OF managed_node_t.

    TYPES managed_nodes_t TYPE HASHED TABLE OF managed_node_t WITH UNIQUE KEY id
                               WITH NON-UNIQUE SORTED KEY variable COMPONENTS variable_name
                                                                              variable_type.

    DATA: managed_nodes TYPE managed_nodes_t.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZCL_TVARVC_HIER_MANAGER IMPLEMENTATION.


  METHOD constructor.

    DATA: root     TYPE REF TO zcl_tvarvc_hier_node,
          children TYPE zcl_tvarvc_hier_node=>keys_t.

    SELECT node_name, node_id
      FROM ztvarvc_hier
      INTO TABLE @children
      WHERE parent_id = @zcl_tvarvc_hier_node=>root_id.

    root = NEW zcl_tvarvc_hier_node( id            = zcl_tvarvc_hier_node=>root_id
                                     name          = space
                                     parent_id     = space
                                     attributes    = VALUE #( )
                                     documentation = VALUE #( )
                                     history       = VALUE #( )
                                     manager       = me
                                     children      = children ).

    managed_nodes = VALUE #( ( id = zcl_tvarvc_hier_node=>root_id ref = root ) ).

  ENDMETHOD.


  METHOD get_instance.

    STATICS: instance TYPE REF TO zcl_tvarvc_hier_manager.

    IF instance IS NOT BOUND.
      instance = NEW #( ).
    ENDIF.

    manager = instance.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_manager~get.

    DATA: node_in_db TYPE ztvarvc_hier,
          children   TYPE zcl_tvarvc_hier_node=>keys_t.

    IF node_id IS NOT INITIAL.

      IF line_exists( managed_nodes[ id = node_id ] ).

        node = managed_nodes[ id = node_id ]-ref.
        RETURN.

      ENDIF.

      SELECT SINGLE *
        FROM ztvarvc_hier
        INTO @node_in_db
        WHERE node_id = @node_id.

    ELSEIF variable_name IS NOT INITIAL AND variable_type IS NOT INITIAL.

      IF line_exists( managed_nodes[ KEY variable COMPONENTS variable_name = variable_name
                                                             variable_type = variable_type ] ).

        node = managed_nodes[ KEY variable COMPONENTS variable_name = variable_name
                                                      variable_type = variable_type ]-ref.
        RETURN.

      ENDIF.

      SELECT *
        FROM ztvarvc_hier
        INTO @node_in_db
        UP TO 1 ROWS
        WHERE tvarv_type = @variable_type
          AND tvarv_name = @variable_name.
      ENDSELECT.

    ENDIF.

    IF node_in_db IS INITIAL.
      RETURN.
    ENDIF.

    SELECT node_name, node_id
      FROM ztvarvc_hier
      INTO TABLE @children
      WHERE parent_id = @node_in_db-node_id.

    node = NEW zcl_tvarvc_hier_node( id            = node_in_db-node_id
                                     name          = node_in_db-node_name
                                     parent_id     = node_in_db-parent_id
                                     attributes    = CORRESPONDING #( node_in_db )
                                     history       = CORRESPONDING #( node_in_db )
                                     documentation = node_in_db-documentation
                                     manager       = me
                                     children      = children ).

    managed_nodes = VALUE #( BASE managed_nodes (
      id            = node_in_db-node_id
      variable_name = node_in_db-tvarv_name
      variable_type = node_in_db-tvarv_type
      ref           = node
      status        = zif_tvarvc_hier_node=>statuses-saved ) ).

  ENDMETHOD.


  METHOD zif_tvarvc_hier_manager~get_root.

    root = zif_tvarvc_hier_manager~get( zcl_tvarvc_hier_node=>root_id ).

  ENDMETHOD.


  METHOD zif_tvarvc_hier_manager~get_status.

    TRY.

        status = managed_nodes[ id = node->get_id( ) ]-status.

      CATCH cx_sy_ref_is_initial
            cx_sy_itab_line_not_found.

        RAISE EXCEPTION TYPE zcx_tvarvc_not_exists.

    ENDTRY.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_manager~has_pending_changes.

    LOOP AT managed_nodes INTO DATA(node_rec).
      IF node_rec-status <> zif_tvarvc_hier_node=>statuses-saved.
        val = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_manager~on_change.

    DATA(rec) = REF #( managed_nodes[ id = sender->get_id( ) ] ).

    IF rec->status = zif_tvarvc_hier_node=>statuses-saved.
      rec->status = zif_tvarvc_hier_node=>statuses-modified.
    ENDIF.

    rec->variable_name = sender->get_attributes( )-tvarv_name.
    rec->variable_type = sender->get_attributes( )-tvarv_type.

  ENDMETHOD.


  METHOD zif_tvarvc_hier_manager~on_create.

    managed_nodes = VALUE #( BASE managed_nodes (
      id            = sender->get_id( )
      variable_name = sender->get_attributes( )-tvarv_name
      variable_type = sender->get_attributes( )-tvarv_type
      ref           = sender
      status        = zif_tvarvc_hier_node=>statuses-created ) ).

  ENDMETHOD.


  METHOD zif_tvarvc_hier_manager~on_delete.

    DATA(rec) = REF #( managed_nodes[ id = sender->get_id( ) ] ).

    CASE rec->status.

      WHEN zif_tvarvc_hier_node=>statuses-saved OR zif_tvarvc_hier_node=>statuses-modified.

        rec->status = zif_tvarvc_hier_node=>statuses-deleted.

      WHEN zif_tvarvc_hier_node=>statuses-created.

        " Node only exists in memory, no longer needed
        DELETE managed_nodes WHERE id = sender->get_id( ).

    ENDCASE.


  ENDMETHOD.


  METHOD zif_tvarvc_hier_manager~save.

    DATA: node_in_db      TYPE ztvarvc_hier,
          nodes_to_modify TYPE STANDARD TABLE OF ztvarvc_hier,
          nodes_to_delete TYPE STANDARD TABLE OF ztvarvc_hier,
          saved_node_ids  TYPE zif_tvarvc_hier_manager~node_ids,
          saved_node_id   LIKE LINE OF saved_node_ids,
          record          TYPE REF TO managed_node_t.

    LOOP AT managed_nodes REFERENCE INTO record WHERE status <> zif_tvarvc_hier_node=>statuses-saved.

      DATA(node) = record->ref.

      node_in_db-node_id       = node->get_id( ).
      node_in_db-node_name     = node->get_name( ).
      node_in_db-parent_id     = node->get_parent( )->get_id( ).
      node_in_db-documentation = node->get_documentation_raw( ).
      node_in_db = CORRESPONDING #( BASE ( node_in_db ) node->get_attributes( ) ).
      node_in_db = CORRESPONDING #( BASE ( node_in_db ) node->get_modification_info( ) ).

      CASE record->status.

        WHEN zif_tvarvc_hier_node=>statuses-created OR zif_tvarvc_hier_node=>statuses-modified.

          INSERT node_in_db INTO TABLE nodes_to_modify.

        WHEN zif_tvarvc_hier_node=>statuses-deleted.

          INSERT node_in_db INTO TABLE nodes_to_delete.

      ENDCASE.

    ENDLOOP.

    MODIFY ztvarvc_hier FROM TABLE nodes_to_modify.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_tvarvc_operation_failure.
    ENDIF.

    DELETE ztvarvc_hier FROM TABLE nodes_to_delete.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_tvarvc_operation_failure.
    ENDIF.

    LOOP AT managed_nodes REFERENCE INTO record WHERE status <> zif_tvarvc_hier_node=>statuses-saved.
      record->status = zif_tvarvc_hier_node=>statuses-saved.
      saved_node_id = record->id.
      INSERT saved_node_id INTO TABLE saved_node_ids.
    ENDLOOP.

    RAISE EVENT zif_tvarvc_hier_manager~saved
      EXPORTING
        node_ids = saved_node_ids.

  ENDMETHOD.
ENDCLASS.
