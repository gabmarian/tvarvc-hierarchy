
CLASS node_docu_viewer DEFINITION FINAL.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        node TYPE REF TO zif_tvarvc_hier_node.

    METHODS show.

  PRIVATE SECTION.

    DATA: css  TYPE string,
          node TYPE REF TO zif_tvarvc_hier_node.

ENDCLASS.
