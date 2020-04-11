*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS db_utility DEFINITION FINAL.

  PUBLIC SECTION.

    CLASS-METHODS project_parameters
      IMPORTING
        parameters   TYPE parameters_t
      RETURNING
        VALUE(group) TYPE tvarvc_grouping.

    CLASS-METHODS project_select_options
      IMPORTING
        select_options TYPE select_options_t
      RETURNING
        VALUE(group)   TYPE tvarvc_grouping.

ENDCLASS.

CLASS db_utility IMPLEMENTATION.

  METHOD project_parameters.

    DATA entry TYPE tvarvc.

    LOOP AT parameters REFERENCE INTO DATA(parameter) WHERE edited = abap_true.

      CLEAR entry.

      entry-name = parameter->name.
      entry-sign = zcl_tvarvc=>sign-in.
      entry-opti = zcl_tvarvc=>opti-eq.
      entry-low  = parameter->value.

      IF parameter->value IS NOT INITIAL.
        INSERT entry INTO TABLE group-entries_to_modify.
      ELSE.
        INSERT entry INTO TABLE group-entries_to_delete.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD project_select_options.

    DATA: entry TYPE tvarvc,
          value TYPE LINE OF zcl_tvarvc=>generic_range.

    DATA(edited_select_options) = select_options.
    DELETE edited_select_options WHERE edited = abap_false.

    IF edited_select_options IS NOT INITIAL.

      SELECT *
        FROM tvarvc
        INTO TABLE group-entries_to_delete
        FOR ALL ENTRIES IN edited_select_options
        WHERE name = edited_select_options-name
          AND type = zcl_tvarvc=>kind-selopt.

    ENDIF.

    LOOP AT edited_select_options REFERENCE INTO DATA(select_option).

      CLEAR entry.

      entry-name = select_option->name.
      entry-type = zcl_tvarvc=>kind-selopt.

      LOOP AT select_option->values INTO value.

        entry-sign  = value-sign.
        entry-opti  = value-option.
        entry-low   = value-low.
        entry-high  = value-high.

        INSERT entry INTO TABLE group-entries_to_modify.

        entry-numb  = entry-numb + 1.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
