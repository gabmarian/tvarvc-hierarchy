
CLASS node_docu_viewer IMPLEMENTATION.

  METHOD constructor.

    me->node = node.

    css =
  ` <style type="text/css">             ` &&
  `     <!-- body {                     ` &&
  `         background-color: #fefeee;  ` &&
  `         font-family: arial;         ` &&
  `         font-style: normal;         ` &&
  `         font-size: 0.8em;           ` &&
  `         color: #000000;             ` &&
  `     }                               ` &&
  `     h1 {                            ` &&
  `         font-size: 1.2em;           ` &&
  `         font-weight: bold;          ` &&
  `         color: #000080;             ` &&
  `     }  -->                          ` &&
  ` </style>                            `.

  ENDMETHOD.

  METHOD show.

    DATA: html_string TYPE string,
          heading     TYPE string,
          body_blocks TYPE STANDARD TABLE OF string,
          block       TYPE string,
          body        TYPE string.

    SPLIT node->get_documentation( ) AT cl_abap_char_utilities=>cr_lf INTO TABLE body_blocks.

    heading = COND #( WHEN node->get_attributes( )-description IS NOT INITIAL
                      THEN node->get_attributes( )-description
                      ELSE node->get_name( ) ).

    body = '<h1>' && heading && '</h1>'.

    LOOP AT body_blocks INTO block.
      body = body && '<p>' && escape( val = block format = cl_abap_format=>e_html_text ) && '</p>'.
    ENDLOOP.

    html_string = '<html><head>' && css && '</head><body>' && body && '</body></html>'.

    cl_abap_browser=>show_html( html_string = html_string ).

  ENDMETHOD.

ENDCLASS.
