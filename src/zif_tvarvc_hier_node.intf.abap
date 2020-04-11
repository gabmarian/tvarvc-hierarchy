interface ZIF_TVARVC_HIER_NODE
  public .


  types:
    status(1) TYPE c .

  constants:
    BEGIN OF statuses.
  CONSTANTS saved    TYPE status VALUE ' '.
  CONSTANTS created  TYPE status VALUE 'C'.
  CONSTANTS modified TYPE status VALUE 'M'.
  CONSTANTS deleted  TYPE status VALUE 'D'.
  CONSTANTS END OF statuses .

  events CREATED .
  events CHANGED .
  events DELETED .

  methods COUNT_SUBNODES
    importing
      !DEPTH type ZIF_TVARVC_HIER_NODE_ITERATOR=>DEPTH default ZIF_TVARVC_HIER_NODE_ITERATOR=>DEPTH_ALL_SUBNODES
    returning
      value(COUNT) type I .
  methods CREATE_CHILD
    importing
      !NAME type ZTVARVC_HIER-NODE_NAME
      !ATTRIBUTES type ZTVARVC_NODE_ATTRIBUTES optional
    returning
      value(CHILD) type ref to ZIF_TVARVC_HIER_NODE
    raising
      ZCX_TVARVC_ERROR .
  methods CREATE_ITERATOR
    importing
      !DEPTH type ZIF_TVARVC_HIER_NODE_ITERATOR=>DEPTH default ZIF_TVARVC_HIER_NODE_ITERATOR=>DEPTH_ALL_SUBNODES
    returning
      value(ITERATOR) type ref to ZIF_TVARVC_HIER_NODE_ITERATOR .
  methods GET_ATTRIBUTES
    returning
      value(ATTRIBUTES) type ZTVARVC_NODE_ATTRIBUTES .
  methods GET_MODIFICATION_INFO
    returning
      value(HISTORY) type ZTVARVC_NODE_HISTORY .
  methods GET_CHILD
    importing
      !NAME type CSEQUENCE optional
      !INDEX type I optional
    preferred parameter INDEX
    returning
      value(CHILD) type ref to ZIF_TVARVC_HIER_NODE .
  methods GET_DOCUMENTATION
    returning
      value(TEXT) type STRING .
  methods GET_DOCUMENTATION_RAW
    returning
      value(DOCU_XSTRING) type XSTRING .
  methods GET_ID
    returning
      value(ID) type STRING .
  methods GET_NAME
    returning
      value(NAME) type STRING .
  methods GET_PARENT
    returning
      value(PARENT) type ref to ZIF_TVARVC_HIER_NODE .
  methods GET_STATUS
    returning
      value(STATUS) type STATUS .
  methods IS_LEAF
    returning
      value(LEAF) type ABAP_BOOL .
  methods REMOVE_CHILD
    importing
      !NAME type CSEQUENCE optional
      !INDEX type I optional
    preferred parameter INDEX
    raising
      ZCX_TVARVC_ERROR .
  methods RENAME
    importing
      !NEW_NAME type CSEQUENCE
    returning
      value(SELF) type ref to ZIF_TVARVC_HIER_NODE
    raising
      ZCX_TVARVC_ERROR .
  methods SET_ATTRIBUTES
    importing
      !ATTRIBUTES type ZTVARVC_NODE_ATTRIBUTES
    returning
      value(SELF) type ref to ZIF_TVARVC_HIER_NODE .
  methods SET_DOCUMENTATION
    importing
      !TEXT type STRING
    returning
      value(SELF) type ref to ZIF_TVARVC_HIER_NODE .
  methods SET_PARENT
    importing
      !NEW_PARENT type ref to ZIF_TVARVC_HIER_NODE
    returning
      value(SELF) type ref to ZIF_TVARVC_HIER_NODE
    raising
      ZCX_TVARVC_OPERATION_FAILURE .
endinterface.
