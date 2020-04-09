
CLASS application IMPLEMENTATION.

  METHOD class_constructor.

    app = NEW #( ).

  ENDMETHOD.

  METHOD run.

    app->screens->get_screen( '1100' )->call( ).

  ENDMETHOD.

  METHOD pbo.

    app->screens->get_screen( sy-dynnr )->pbo( ).

  ENDMETHOD.

  METHOD pai.

    app->screens->get_screen( sy-dynnr )->pai( sscrfields-ucomm ).

  ENDMETHOD.

  METHOD on_exit.

    app->screens->get_screen( sy-dynnr )->on_exit( sscrfields-ucomm ).

  ENDMETHOD.

  METHOD on_f4.

    app->screens->get_screen( sy-dynnr )->on_f4( screen_field ).

  ENDMETHOD.

  METHOD constructor.

    screens = NEW screen_collection( me ).
    hier_manager = zcl_tvarvc_hier_manager=>get_instance( ).
    variable_handler = NEW zcl_tvarvc_variable_collection( ).

    SET HANDLER me->on_hier_node_created FOR ALL INSTANCES.
    SET HANDLER me->on_hier_node_changed FOR ALL INSTANCES.
    SET HANDLER me->on_hier_node_deleted FOR ALL INSTANCES.

    init_ui_tree( ).

  ENDMETHOD.

  METHOD init_ui_tree.

    ui_tree =  NEW #( node_selection_mode   = cl_column_tree_model=>node_sel_mode_single
                      item_selection        = abap_true
                      hierarchy_column_name = 'NAME'
                      hierarchy_header      = VALUE #( heading = 'Hierarchy' width = 60 ) ).

    ui_tree->add_column( name = 'DESCRIPTION'  disabled = abap_true  width = 50 header_text = 'Description' ).
    ui_tree->add_column( name = 'DOCU_POINTER' disabled = abap_false width = 12 header_text = 'Long Text' ).
    ui_tree->add_column( name = 'APPL_COMP'    disabled = abap_true  width = 24 header_text = 'Application Component' ).
    ui_tree->add_column( name = 'VARIABLE'     disabled = abap_false width = 40 header_text = 'Variable' ).
    ui_tree->add_column( name = 'OPTION'       disabled = abap_true  width = 4  header_text = 'Op' ).
    ui_tree->add_column( name = 'VALUE'        disabled = abap_true  width = 20 header_text = 'Value' ).
    ui_tree->add_column( name = 'VALUE_TO'     disabled = abap_true  width = 20 header_text = 'To Value' ).
    ui_tree->add_column( name = 'MULTI_VALUE'  disabled = abap_true  width = 4  header_text = 'Multi' ).

    ui_tree->set_registered_events(
      VALUE #(
        ( eventid = cl_column_tree_model=>eventid_node_double_click appl_event = abap_true )
        ( eventid = cl_column_tree_model=>eventid_link_click        appl_event = abap_true )
      )
    ).

    SET HANDLER handle_node_double_click  FOR ui_tree.
    SET HANDLER handle_link_click         FOR ui_tree.
    SET HANDLER handle_expand_no_children FOR ui_tree.

    ui_tree->create_tree_control( parent = cl_gui_container=>default_screen ).

    " Add root and first level
    DATA(root) = hier_manager->get_root( ).

    ui_tree->add_node(
        node_key    = root->get_id( )
        isfolder    = abap_true
        item_table  = hier_node_to_item_table( root )
        user_object = root ).

    expand_node( root ).

  ENDMETHOD.

  METHOD get_node_by_key.

    DATA user_object TYPE REF TO object.

    ui_tree->node_get_user_object(
      EXPORTING
        node_key    = node_key
      IMPORTING
        user_object = user_object
      EXCEPTIONS
        OTHERS      = 0 ).

    node ?= user_object.

  ENDMETHOD.

  METHOD get_selected_node.

    ui_tree->get_selected_node( IMPORTING node_key = DATA(node_key) ).
    node = get_node_by_key( node_key ).

  ENDMETHOD.

  METHOD expand_node.

    DATA(it) = node->create_iterator( zif_tvarvc_hier_node_iterator=>depth_direct_subnodes ).
    DATA(child) = it->get_next( ).

    WHILE child IS BOUND.

      IF ui_tree->node_key_in_tree( child->get_id( ) ) = abap_false.

        ui_tree->add_node(
          EXPORTING
            node_key          = child->get_id( )
            relative_node_key = child->get_parent( )->get_id( )
            relationship      = cl_tree_model=>relat_last_child
            isfolder          = xsdbool( NOT child->is_leaf( ) )
            item_table        = hier_node_to_item_table( child )
            expander          = xsdbool( NOT child->is_leaf( ) )
            user_object       = child ).
*          EXCEPTIONS
*            node_key_exists  = 0 ).

       ENDIF.

      IF recursive = abap_true.
        expand_node( node = child recursive = abap_true ).
      ENDIF.

      child = it->get_next( ).

    ENDWHILE.

    ui_tree->expand_node( node->get_id( ) ).

  ENDMETHOD.

  METHOD hier_node_to_item_table.

    DATA(preview) = get_variable_preview( node ).

    item_table = VALUE #(
      (
        item_name = 'NAME'
        class     = cl_column_tree_model=>item_class_text
        text      = node->get_name( )
      ) (
        item_name = 'DESCRIPTION'
        class     = cl_column_tree_model=>item_class_text
        text      = node->get_attributes( )-description
      ) (
        item_name = 'APPL_COMP'
        class     = cl_column_tree_model=>item_class_text
        text      = node->get_attributes( )-appl_component
      ) (
        item_name = 'DOCU_POINTER'
        class     = cl_column_tree_model=>item_class_link
        t_image   = icon_information
        hidden    = xsdbool( node->get_documentation( ) IS INITIAL )
      ) (
        item_name = 'VARIABLE'
        class     = cl_column_tree_model=>item_class_link
        text      = node->get_attributes( )-tvarv_name
        hidden    = xsdbool( node->get_attributes( )-tvarv_name IS INITIAL )
      ) (
        item_name = 'OPTION'
        class     = cl_column_tree_model=>item_class_text
        t_image   = preview-icon
      ) (
        item_name = 'VALUE'
        class     = cl_column_tree_model=>item_class_text
        text      = preview-value
      ) (
        item_name = 'VALUE_TO'
        class     = cl_column_tree_model=>item_class_text
        text      = preview-value_to
       ) (
        item_name = 'MULTI_VALUE'
        class     = cl_column_tree_model=>item_class_text
        t_image   = COND #( WHEN lines( variable_handler->get_select_option(
                                           node->get_attributes( )-tvarv_name ) ) > 1
                            THEN icon_display_more
                            ELSE icon_space )
        hidden    = xsdbool( NOT node->get_attributes( )-tvarv_type = zcl_tvarvc=>kind-selopt )
      )
    ).

  ENDMETHOD.

  METHOD handle_node_double_click.

    maintain_attributes( get_node_by_key( node_key ) ).

  ENDMETHOD.

  METHOD handle_link_click.

    CASE item_name.

      WHEN 'VARIABLE'.

        maintain_tvarvc_variable( get_node_by_key( node_key ) ).

      WHEN 'DOCU_POINTER'.

        show_documentation( get_node_by_key( node_key ) ).

    ENDCASE.

  ENDMETHOD.

  METHOD maintain_attributes.

    DATA: screen TYPE REF TO screen_1200.

    IF node IS NOT SUPPLIED.
      node = get_selected_node( ).
    ENDIF.

    IF node IS NOT BOUND.
      MESSAGE 'Select a node first' TYPE 'E'.
    ENDIF.

    IF node->get_id( ) = zcl_tvarvc_hier_node=>root_id.
      RETURN.
    ENDIF.

    screen ?= screens->get_screen( '1200' ).
    screen->node = node.
    screen->call( ).

  ENDMETHOD.

  METHOD maintain_tvarvc_variable.

    IF node IS NOT SUPPLIED.
      node = get_selected_node( ).
    ENDIF.

    IF node IS NOT BOUND.
      MESSAGE 'Select a node first' TYPE 'E'.
    ENDIF.

    IF node->get_id( ) = zcl_tvarvc_hier_node=>root_id.
      RETURN.
    ENDIF.

    IF node->get_attributes( )-tvarv_name IS INITIAL.
      MESSAGE 'No variable assignment exists' TYPE 'S'.
      RETURN.
    ENDIF.

    DATA(variable_type) = node->get_attributes( )-tvarv_type.

    DATA(screen) = screens->get_screen(
      SWITCH #( variable_type WHEN zcl_tvarvc=>kind-param  THEN '1400'
                              WHEN zcl_tvarvc=>kind-selopt THEN '1500' ) ).

    CAST if_node_handler_screen( screen )->node = node.
    CAST if_variable_handler_screen( screen )->handler = variable_handler.
    screen->call( ).

  ENDMETHOD.

  METHOD show_documentation.

    NEW node_docu_viewer( node )->show( ).

  ENDMETHOD.

  METHOD handle_expand_no_children.

    expand_node( get_node_by_key( node_key ) ).

  ENDMETHOD.

  METHOD refresh_hier_node_on_ui.

    DATA(preview) = get_variable_preview( node ).

    ui_tree->update_items(
      VALUE #(
        (
          node_key  = node->get_id( )
          item_name = 'NAME'
          text      = node->get_name( )
          u_text    = abap_true
        ) (
          node_key  = node->get_id( )
          item_name = 'DESCRIPTION'
          text      = node->get_attributes( )-description
          u_text    = abap_true
        ) (
          node_key  = node->get_id( )
          item_name = 'APPL_COMP'
          text      = node->get_attributes( )-appl_component
          u_text    = abap_true
        ) (
          node_key  = node->get_id( )
          item_name = 'DOCU_POINTER'
          hidden    = xsdbool( node->get_documentation( ) IS INITIAL )
          u_hidden  = abap_true
        ) (
          node_key  = node->get_id( )
          item_name = 'VARIABLE'
          text      = node->get_attributes( )-tvarv_name
          u_text    = abap_true
          hidden    = xsdbool( node->get_attributes( )-tvarv_name IS INITIAL )
          u_hidden  = abap_true
        ) (
          node_key  = node->get_id( )
          item_name = 'OPTION'
          t_image   = preview-icon
          u_t_image = abap_true
        ) (
          node_key  = node->get_id( )
          item_name = 'VALUE'
          text      = preview-value
          u_text    = abap_true
        ) (
          node_key  = node->get_id( )
          item_name = 'VALUE_TO'
          text      = preview-value_to
          u_text    = abap_true
       ) (
          item_name = 'MULTI_VALUE'
          node_key  = node->get_id( )
          t_image   = COND #( WHEN lines( variable_handler->get_select_option(
                                             node->get_attributes( )-tvarv_name ) ) > 1
                              THEN icon_display_more
                              ELSE icon_space )
          u_t_image = abap_true
          hidden    = xsdbool( NOT node->get_attributes( )-tvarv_type = zcl_tvarvc=>kind-selopt )
          u_hidden  = abap_true
      )
    ) ).

  ENDMETHOD.

  METHOD on_hier_node_changed.

    refresh_hier_node_on_ui( sender ).

  ENDMETHOD.

  METHOD on_hier_node_created.

    expand_node( sender->get_parent( ) ).

    IF sender->get_parent( )->count_subnodes( ) = 1.
      ui_tree->expand_node( sender->get_parent( )->get_id( ) ).
    ENDIF.

  ENDMETHOD.

  METHOD on_hier_node_deleted.

  ENDMETHOD.

  METHOD has_pending_changes.

    val = xsdbool( hier_manager->has_pending_changes( ) OR
                   variable_handler->has_pending_changes( ) ).

  ENDMETHOD.

  METHOD save.

    IF has_pending_changes( ) = abap_false.
      MESSAGE 'No changes were made' TYPE 'S'.
      RETURN.
    ENDIF.

    TRY.

        hier_manager->save( ).
        variable_handler->save( ).

      CATCH zcx_tvarvc_operation_failure.

        MESSAGE 'Saving of changes failed' TYPE 'E'.

    ENDTRY.

    MESSAGE 'Changes saved' TYPE 'S'.

  ENDMETHOD.

  METHOD switch_mode.

    IF in_edit_mode( ) AND has_pending_changes( ).
      MESSAGE 'Action not possible with unsaved data' TYPE 'E'.
    ENDIF.

    app->edit_mode_active = xsdbool( app->edit_mode_active = abap_false ).

  ENDMETHOD.

  METHOD in_edit_mode.
    val = edit_mode_active.
  ENDMETHOD.

  METHOD add_node.

    DATA: screen TYPE REF TO screen_1300,
          node   TYPE REF TO zif_tvarvc_hier_node.

    node = get_selected_node( ).

    IF node IS NOT BOUND.
      MESSAGE 'Select a node first' TYPE 'E'.
    ENDIF.

    screen ?= screens->get_screen( '1300' ).
    screen->node = node.
    screen->call( ).

  ENDMETHOD.

  METHOD remove_node.

    DATA: node TYPE REF TO zif_tvarvc_hier_node.

    node = get_selected_node( ).

    IF node IS NOT BOUND.
      MESSAGE 'Select a node first' TYPE 'E'.
    ENDIF.

    IF node->get_id( ) = zcl_tvarvc_hier_node=>root_id.
      MESSAGE 'Root cannot be removed' TYPE 'E'.
    ENDIF.

    node->get_parent( )->remove_child( name = node->get_name( ) ).
    ui_tree->delete_node( node->get_id( ) ).

  ENDMETHOD.

  METHOD expand_tree.

    DATA: node TYPE REF TO zif_tvarvc_hier_node.

    node = get_selected_node( ).

    IF node IS NOT BOUND.
      MESSAGE 'Select a node first' TYPE 'E'.
    ENDIF.

    expand_node( node = node recursive = abap_true ).

  ENDMETHOD.

  METHOD edit_documentation.

    DATA: screen TYPE REF TO screen_1600,
          node   TYPE REF TO zif_tvarvc_hier_node.

    node = get_selected_node( ).

    IF node IS NOT BOUND.
      MESSAGE 'Select a node first' TYPE 'E'.
    ENDIF.

    screen ?= screens->get_screen( '1600' ).
    screen->node = node.
    screen->call( ).

  ENDMETHOD.

  METHOD get_variable_preview.

    DATA: attributes TYPE ztvarvc_node_attributes,
          values     TYPE zcl_tvarvc=>generic_range,
          value      LIKE LINE OF values.

    IF selopt_icons IS INITIAL.

      selopt_icons = VALUE #(
        ( sign = ' ' opti = '  ' icon = icon_space                  )
        ( sign = 'I' opti = 'EQ' icon = icon_equal_green            )
        ( sign = 'I' opti = 'NE' icon = icon_not_equal_green        )
        ( sign = 'I' opti = 'BT' icon = icon_interval_include_green )
        ( sign = 'I' opti = 'NB' icon = icon_interval_exclude_green )
        ( sign = 'I' opti = 'GT' icon = icon_greater_green          )
        ( sign = 'I' opti = 'LT' icon = icon_less_green             )
        ( sign = 'I' opti = 'LE' icon = icon_less_equal_green       )
        ( sign = 'I' opti = 'GE' icon = icon_greater_equal_green    )
        ( sign = 'I' opti = 'CP' icon = icon_pattern_include_green  )
        ( sign = 'I' opti = 'NP' icon = icon_pattern_exclude_green  )
        ( sign = 'E' opti = 'EQ' icon = icon_equal_red              )
        ( sign = 'E' opti = 'NE' icon = icon_not_equal_red          )
        ( sign = 'E' opti = 'BT' icon = icon_interval_include_red   )
        ( sign = 'E' opti = 'NB' icon = icon_interval_exclude_red   )
        ( sign = 'E' opti = 'GT' icon = icon_greater_red            )
        ( sign = 'E' opti = 'LT' icon = icon_less_red               )
        ( sign = 'E' opti = 'LE' icon = icon_less_equal_red         )
        ( sign = 'E' opti = 'GE' icon = icon_greater_equal_red      )
        ( sign = 'E' opti = 'CP' icon = icon_pattern_include_red    )
        ( sign = 'E' opti = 'NP' icon = icon_pattern_exclude_red    )
      ).

    ENDIF.

    attributes = node->get_attributes( ).

    CASE attributes-tvarv_type.

      WHEN zcl_tvarvc=>kind-param.

        preview-value = variable_handler->get_parameter( attributes-tvarv_name ).
        preview-icon  = icon_equal_green.

      WHEN zcl_tvarvc=>kind-selopt.

        values = variable_handler->get_select_option( attributes-tvarv_name ).

        IF values IS NOT INITIAL.
          value = values[ 1 ].
        ENDIF.

        preview-value    = value-low.
        preview-value_to = value-high.
        preview-icon     = selopt_icons[ sign = value-sign opti = value-option ]-icon.

    ENDCASE.

  ENDMETHOD.

  METHOD toggle_text_columns.

    ui_tree->column_get_properties(
      EXPORTING
        column_name = 'DESCRIPTION'
      IMPORTING
        properties = DATA(properties) ).

    properties-hidden = xsdbool( NOT properties-hidden = abap_true ).

    ui_tree->update_column( name = 'DESCRIPTION'  hidden = properties-hidden update_hidden = abap_true ).
    ui_tree->update_column( name = 'DOCU_POINTER' hidden = properties-hidden update_hidden = abap_true ).
    ui_tree->update_column( name = 'APPL_COMP'    hidden = properties-hidden update_hidden = abap_true ).

  ENDMETHOD.

  METHOD find.

    DATA: screen TYPE REF TO screen_1700.

    screen ?= screens->get_screen( '1700' ).

    screen->call( ).

  ENDMETHOD.

  METHOD find_node_by_variable.

    DATA: node   TYPE REF TO zif_tvarvc_hier_node,
          branch LIKE STANDARD TABLE OF node.

    node = hier_manager->get( variable_name = tvarvc_name
                              variable_type = tvarvc_type ).

    IF node IS NOT BOUND.
      MESSAGE 'Requested variable is not in the tree' TYPE 'S'.
      RETURN.
    ENDIF.

    " Build the branch where the node is located
    WHILE node IS NOT INITIAL.
      INSERT node INTO branch INDEX 1.
      node = node->get_parent( ).
    ENDWHILE.

    " Make sure it is expanded, starting from the root
    LOOP AT branch INTO node.
      expand_node( node ).
    ENDLOOP.

    ui_tree->set_selected_node( node->get_id( ) ).

  ENDMETHOD.

ENDCLASS.
