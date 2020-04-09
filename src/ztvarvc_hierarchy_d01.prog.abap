
CLASS application DEFINITION DEFERRED.

* Wrapper for screens of the application
CLASS selection_screen DEFINITION ABSTRACT.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        app    TYPE REF TO application
        number TYPE sy-dynnr.

    METHODS call FINAL.

    METHODS init_before_call.

    METHODS pbo.

    METHODS pai
      IMPORTING
        ok_code TYPE sy-ucomm.

    METHODS on_exit
      IMPORTING
        ok_code TYPE sy-ucomm.

    METHODS on_f4
      IMPORTING
        screen_field TYPE csequence.

   PROTECTED SECTION.

    DATA: number             TYPE sy-dynnr,
          status_prog        TYPE sy-repid,
          status_name        TYPE sy-pfkey,
          excluded_functions TYPE STANDARD TABLE OF sy-ucomm,
          app                TYPE REF TO application,

          BEGIN OF position,
            col_from  TYPE i,
            col_to    TYPE i,
            row_from  TYPE i,
            row_to    TYPE i,
          END OF position.

ENDCLASS.

* Interface for screens doing individual tree node processing
INTERFACE if_node_handler_screen.
  DATA: node TYPE REF TO zif_tvarvc_hier_node.
ENDINTERFACE.

* Interface for screens doing individual tree node processing
INTERFACE if_variable_handler_screen.
  DATA: handler TYPE REF TO zif_tvarvc_variable_collection.
ENDINTERFACE.

* A set for screen adiministration
CLASS screen_collection DEFINITION.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        app TYPE REF TO application.

    METHODS get_screen
      IMPORTING
        number     TYPE sy-dynnr
      RETURNING
        VALUE(ref) TYPE REF TO selection_screen.

   PRIVATE SECTION.

    TYPES: BEGIN OF screen_t,
            number TYPE sy-dynnr,
            ref    TYPE REF TO selection_screen,
          END OF screen_t.

    TYPES: screens_t TYPE SORTED TABLE OF screen_t WITH UNIQUE KEY number.

    DATA: app     TYPE REF TO application,
          screens TYPE screens_t.

ENDCLASS.
