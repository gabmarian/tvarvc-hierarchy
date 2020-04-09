interface ZIF_TVARVC_HIER_NODE_ITERATOR
  public .


  types DEPTH type I .

  constants DEPTH_ALL_SUBNODES type DEPTH value 0 ##NO_TEXT.
  constants DEPTH_DIRECT_SUBNODES type DEPTH value 1 ##NO_TEXT.

  methods GET_NEXT
    returning
      value(NODE) type ref to ZIF_TVARVC_HIER_NODE .
  methods RESET .
endinterface.
