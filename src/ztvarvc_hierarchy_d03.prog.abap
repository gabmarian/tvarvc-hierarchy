
CLASS application DEFINITION FINAL.

  PUBLIC SECTION.

    CLASS-METHODS class_constructor.

    CLASS-METHODS run.

    CLASS-METHODS pbo.

    CLASS-METHODS pai.

    CLASS-METHODS on_exit.

    CLASS-METHODS on_f4
      IMPORTING
        screen_field TYPE csequence.

    METHODS constructor.

    METHODS save.

    METHODS switch_mode.

    METHODS in_edit_mode
      RETURNING
        VALUE(val) TYPE abap_bool.

    METHODS find.

    METHODS find_node_by_variable
      IMPORTING
        tvarvc_name TYPE csequence
        tvarvc_type TYPE tvarvc-type.

    METHODS toggle_text_columns.

    METHODS add_node.

    METHODS remove_node.

    METHODS expand_tree.

    METHODS maintain_attributes
      IMPORTING
        VALUE(node) TYPE REF TO zif_tvarvc_hier_node OPTIONAL.

    METHODS maintain_tvarvc_variable
      IMPORTING
        VALUE(node) TYPE REF TO zif_tvarvc_hier_node OPTIONAL.

    METHODS edit_documentation.

    METHODS refresh_hier_node_on_ui
      IMPORTING
        node TYPE REF TO zif_tvarvc_hier_node.

  PRIVATE SECTION.

    CLASS-DATA app TYPE REF TO application.

    TYPES BEGIN OF vari_preview_t.
    TYPES icon      TYPE icon-id.
    TYPES value     TYPE rvari_val_255.
    TYPES value_to  TYPE rvari_val_255.
    TYPES END OF vari_preview_t.

    TYPES: BEGIN OF selopt_icon_t,
             sign TYPE tvarvc-sign,
             opti TYPE tvarvc-opti,
             icon TYPE icon-id,
           END OF selopt_icon_t,

           selopt_icons_t TYPE HASHED TABLE OF selopt_icon_t WITH UNIQUE KEY sign opti.

    DATA: screens          TYPE REF TO screen_collection,
          hier_manager     TYPE REF TO zif_tvarvc_hier_manager,
          ui_tree          TYPE REF TO cl_column_tree_model,
          variable_handler TYPE REF TO zif_tvarvc_variable_collection,
          selopt_icons     TYPE selopt_icons_t,
          edit_mode_active TYPE abap_bool.

    METHODS handle_node_double_click FOR EVENT node_double_click OF cl_column_tree_model
      IMPORTING node_key.

    METHODS handle_link_click FOR EVENT link_click OF cl_column_tree_model
      IMPORTING node_key item_name.

    METHODS show_documentation
      IMPORTING
        node TYPE REF TO zif_tvarvc_hier_node.

    METHODS handle_expand_no_children FOR EVENT expand_no_children OF cl_column_tree_model
      IMPORTING node_key.

    METHODS init_ui_tree.

    METHODS get_node_by_key
      IMPORTING
        node_key    TYPE string
      RETURNING
        VALUE(node) TYPE REF TO zif_tvarvc_hier_node.

    METHODS get_selected_node
      RETURNING
        VALUE(node) TYPE REF TO zif_tvarvc_hier_node.

    METHODS expand_node
      IMPORTING
        node      TYPE REF TO zif_tvarvc_hier_node
        recursive TYPE abap_bool OPTIONAL.

    METHODS hier_node_to_item_table
      IMPORTING
        node              TYPE REF TO zif_tvarvc_hier_node
      RETURNING
        VALUE(item_table) TYPE treemcitab.

    METHODS has_pending_changes
      RETURNING
        VALUE(val) TYPE abap_bool.

    METHODS on_hier_node_changed FOR EVENT changed OF zif_tvarvc_hier_node
      IMPORTING sender.

    METHODS on_hier_node_created FOR EVENT created OF zif_tvarvc_hier_node
      IMPORTING sender.

    METHODS on_hier_node_deleted FOR EVENT deleted OF zif_tvarvc_hier_node
      IMPORTING sender.

    METHODS get_variable_preview
      IMPORTING
        node           TYPE REF TO zif_tvarvc_hier_node
      RETURNING
        VALUE(preview) TYPE vari_preview_t.

ENDCLASS.
