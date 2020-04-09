*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

" Level order traversal
CLASS iterator DEFINITION.

  PUBLIC SECTION.

    INTERFACES zif_tvarvc_hier_node_iterator.

    METHODS constructor
      IMPORTING
        owner TYPE REF TO zif_tvarvc_hier_node
        depth TYPE i.

  PROTECTED SECTION.

    DATA owner             TYPE REF TO zif_tvarvc_hier_node.
    DATA depth             TYPE i.
    DATA nodes_to_process  TYPE STANDARD TABLE OF REF TO zif_tvarvc_hier_node WITH EMPTY KEY.

    METHODS add_children
      IMPORTING
        node TYPE REF TO zif_tvarvc_hier_node.

ENDCLASS.


CLASS iterator IMPLEMENTATION.

  METHOD constructor.

    me->owner = owner.
    me->depth = depth.

    zif_tvarvc_hier_node_iterator~reset( ).

  ENDMETHOD.

  METHOD zif_tvarvc_hier_node_iterator~get_next.

    IF nodes_to_process IS INITIAL.
      RETURN.
    ENDIF.

    node = nodes_to_process[ 1 ].
    DELETE nodes_to_process INDEX 1.

    IF depth = zif_tvarvc_hier_node_iterator=>depth_all_subnodes.
      add_children( node ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_tvarvc_hier_node_iterator~reset.

    CLEAR nodes_to_process.

    add_children( owner ).

  ENDMETHOD.

  METHOD add_children.

    DATA child TYPE REF TO zif_tvarvc_hier_node.

    DO.

      child = node->get_child( sy-index ).

      IF child IS NOT BOUND.
        EXIT.
      ENDIF.

      INSERT child INTO TABLE nodes_to_process.

    ENDDO.

  ENDMETHOD.

ENDCLASS.
