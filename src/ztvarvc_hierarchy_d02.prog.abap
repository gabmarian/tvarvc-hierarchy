
* Full screen binding the hierarchy
CLASS screen_1100 DEFINITION
                  INHERITING FROM selection_screen.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        app TYPE REF TO application.

    METHODS pbo              REDEFINITION.
    METHODS pai              REDEFINITION.

ENDCLASS.


* Maintenance of node attributes
CLASS screen_1200 DEFINITION INHERITING FROM selection_screen.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        app TYPE REF TO application.

    METHODS init_before_call REDEFINITION.
    METHODS pbo              REDEFINITION.
    METHODS pai              REDEFINITION.

    INTERFACES if_node_handler_screen.
    ALIASES node FOR if_node_handler_screen~node.

ENDCLASS.

* New node
CLASS screen_1300 DEFINITION INHERITING FROM selection_screen.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        app TYPE REF TO application.

    METHODS init_before_call REDEFINITION.
    METHODS pai              REDEFINITION.

    INTERFACES if_node_handler_screen.
    ALIASES node FOR if_node_handler_screen~node.

ENDCLASS.

* TVARVC parameter assignment
CLASS screen_1400 DEFINITION INHERITING FROM selection_screen.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        app TYPE REF TO application.

    METHODS init_before_call REDEFINITION.
    METHODS pbo              REDEFINITION.
    METHODS pai              REDEFINITION.

    INTERFACES if_node_handler_screen.
    INTERFACES if_variable_handler_screen.

    ALIASES node             FOR if_node_handler_screen~node.
    ALIASES variable_handler FOR if_variable_handler_screen~handler.

ENDCLASS.

* TVARVC select option assignment
CLASS screen_1500 DEFINITION INHERITING FROM selection_screen.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        app TYPE REF TO application.

    METHODS init_before_call REDEFINITION.
    METHODS pbo              REDEFINITION.
    METHODS pai              REDEFINITION.

    INTERFACES if_node_handler_screen.
    INTERFACES if_variable_handler_screen.

    ALIASES node             FOR if_node_handler_screen~node.
    ALIASES variable_handler FOR if_variable_handler_screen~handler.

ENDCLASS.

* Documentation editor
CLASS screen_1600 DEFINITION INHERITING FROM selection_screen.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        app TYPE REF TO application.

    METHODS pbo     REDEFINITION.
    METHODS pai     REDEFINITION.
    METHODS on_exit REDEFINITION.

    INTERFACES if_node_handler_screen.
    ALIASES node FOR if_node_handler_screen~node.

  PRIVATE SECTION.

    DATA: text_editor TYPE REF TO cl_gui_textedit,
          text        TYPE string.

ENDCLASS.

* Search popup
CLASS screen_1700 DEFINITION INHERITING FROM selection_screen.

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        app TYPE REF TO application.

    METHODS init_before_call REDEFINITION.
    METHODS pbo              REDEFINITION.
    METHODS pai              REDEFINITION.

ENDCLASS.
